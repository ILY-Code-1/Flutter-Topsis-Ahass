# Rangkuman Pengetahuan TOPSIS — Sistem Pengambilan Keputusan Prioritas Restock Sparepart AHASS

Dokumen ini merangkum seluruh implementasi metode **TOPSIS (Technique for Order Preference by Similarity to Ideal Solution)** pada aplikasi *Flutter-Topsis-Ahass*. Disusun sebagai bahan referensi untuk penulisan skripsi.

---

## 1. Latar Belakang & Tujuan Sistem

Sistem dibangun untuk membantu staff/admin bengkel AHASS dalam **menentukan prioritas pengadaan ulang (restock) sparepart** secara objektif. Pengambilan keputusan manual sering bersifat subjektif (berdasar perasaan / kebiasaan), sehingga rawan terjadi:

- *Stockout* pada barang yang sebenarnya laris.
- *Overstock* / *dead stock* pada barang yang permintaannya rendah.

Dengan TOPSIS, sistem menghasilkan **ranking barang** berdasarkan kedekatan terhadap solusi ideal positif dan negatif. **Rank 1 = barang paling prioritas untuk segera di-restock**.

---

## 2. Definisi Metode TOPSIS

TOPSIS adalah metode *Multi-Criteria Decision Making* (MCDM) yang memilih alternatif terbaik berdasarkan prinsip:

> *Alternatif terbaik adalah yang memiliki jarak terpendek terhadap solusi ideal positif (A⁺) dan jarak terjauh terhadap solusi ideal negatif (A⁻).*

- **Solusi Ideal Positif (A⁺)** → nilai terbaik untuk setiap kriteria.
- **Solusi Ideal Negatif (A⁻)** → nilai terburuk untuk setiap kriteria.

---

## 3. Kriteria, Tipe, dan Bobot

Sistem menggunakan **3 kriteria** yang didefinisikan langsung pada [topsis_controller.dart:113-117](lib/app/modules/topsis/controllers/topsis_controller.dart#L113-L117):

| Kode | Nama Kriteria       | Tipe    | Bobot (W) | Justifikasi                                                                                              |
| ---- | ------------------- | ------- | --------- | -------------------------------------------------------------------------------------------------------- |
| C1   | `stok_sekarang`     | Cost    | **0,30**  | Stok yang masih tersedia. Makin sedikit → makin mendesak di-restock.                                     |
| C2   | `total_keluar`      | Benefit | **0,45**  | Total kuantitas barang yang keluar dalam 1 bulan berjalan. Indikator utama *demand* → bobot terbesar.    |
| C3   | `frekuensi_keluar`  | Benefit | **0,25**  | Berapa kali transaksi `barang_keluar` terjadi dalam 1 bulan. Indikator keaktifan/permintaan barang.      |

**Total bobot = 0,30 + 0,45 + 0,25 = 1,00** ✅

### 3.1 Penjelasan Tipe Kriteria

- **Benefit** → Nilai semakin besar semakin baik (untuk konteks "prioritas restock"). Solusi ideal positif diambil dari nilai **maksimum** kolom.
- **Cost** → Nilai semakin kecil semakin baik. Solusi ideal positif diambil dari nilai **minimum** kolom.

Implementasi pemisahan cost vs benefit ada di [topsis_controller.dart:180-188](lib/app/modules/topsis/controllers/topsis_controller.dart#L180-L188):

```dart
if (j == 0) {
  // Cost criteria (stok_sekarang)
  positiveIdeal[j] = column.reduce(min);
  negativeIdeal[j] = column.reduce(max);
} else {
  // Benefit criteria (total_keluar, frekuensi_keluar)
  positiveIdeal[j] = column.reduce(max);
  negativeIdeal[j] = column.reduce(min);
}
```

---

## 4. Variabel & Sumber Data

### 4.1 Sumber Data (Firestore Collections)

| Collection         | Peran dalam TOPSIS                                                        |
| ------------------ | ------------------------------------------------------------------------- |
| `items`            | Sumber `stok_sekarang` untuk setiap sparepart (alternatif). `stok_minimum` juga disimpan di sini tetapi **bukan kriteria TOPSIS** — hanya dipakai untuk menghitung `status_stok`. |
| `barang_keluar`    | Sumber `total_keluar` dan `frekuensi_keluar` (di-agregasi per bulan).     |
| `stock_snapshot`   | Arsip kondisi stok bulanan (audit trail).                                 |
| `analisis_topsis`  | Penyimpanan hasil analisis (kriteria + bobot + ranking).                  |

### 4.2 Model Data — `ItemModel`

File: [item_model.dart](lib/app/models/item_model.dart)

| Field           | Tipe   | Peran                                          |
| --------------- | ------ | ---------------------------------------------- |
| `idBarang`      | String | Identitas unik sparepart.                      |
| `namaBarang`    | String | Nama sparepart (ditampilkan di hasil ranking). |
| `kategori`      | String | Kategorisasi (tidak digunakan dalam TOPSIS).   |
| `stokSekarang`  | int    | **C1 (cost)** — input matriks keputusan.       |
| `stokMinimum`   | int    | Bukan kriteria TOPSIS — hanya dipakai untuk menghitung `statusStok`. |
| `statusStok`    | String | `Aman` / `Menipis` / `Kritis` (auto-derived).  |
| `lastUpdate`    | Timestamp | Audit trail.                                |

> **Catatan:** `statusStok` dihitung dengan aturan ([item_model.dart:58-66](lib/app/models/item_model.dart#L58-L66)):
> - `stokSekarang > stokMinimum` → **Aman**
> - `stokSekarang == stokMinimum` → **Menipis**
> - `stokSekarang < stokMinimum` → **Kritis**

### 4.3 Model Data — `BarangKeluarModel`

File: [barang_keluar_model.dart](lib/app/models/barang_keluar_model.dart)

Setiap dokumen mewakili **1 transaksi** keluarnya barang:

| Field        | Tipe      | Peran                                                            |
| ------------ | --------- | ---------------------------------------------------------------- |
| `tanggal`    | Timestamp | Filter bulan berjalan (`>= awal_bulan && <= akhir_bulan`).       |
| `idBarang`   | String    | Foreign key ke `items`.                                          |
| `namaBarang` | String    | Cache nama barang.                                               |
| `jumlah`     | int       | Kuantitas keluar. **Dijumlahkan → `total_keluar` (C2)**.         |
| `inputOleh`  | String    | Audit (siapa input).                                             |

Agregasi: jumlah dokumen per `idBarang` → **`frekuensi_keluar` (C3)**.

### 4.4 Model Data — `AnalisisTopsisModel`

File: [analisis_topsis_model.dart](lib/app/models/analisis_topsis_model.dart)

Menyimpan hasil 1x run analisis:

| Field           | Tipe                          | Isi                                                          |
| --------------- | ----------------------------- | ------------------------------------------------------------ |
| `periodeBulan`  | int                           | Bulan analisis (1-12).                                       |
| `periodeTahun`  | int                           | Tahun analisis.                                              |
| `createdAt`     | Timestamp                     | Waktu eksekusi.                                              |
| `totalItems`    | int                           | Jumlah alternatif (n).                                       |
| `criteria`      | `List<Map<String, dynamic>>`  | Definisi kriteria + tipe + bobot.                            |
| `results`       | `List<Map<String, dynamic>>`  | Ranking hasil akhir + nilai preferensi tiap alternatif.      |

---

## 5. Notasi Matematis

| Notasi      | Arti                                                              |
| ----------- | ----------------------------------------------------------------- |
| `m`         | Jumlah alternatif (jumlah item barang).                           |
| `n`         | Jumlah kriteria = **3**.                                          |
| `x_ij`      | Nilai mentah alternatif ke-`i` pada kriteria ke-`j`.              |
| `r_ij`      | Nilai ternormalisasi.                                             |
| `w_j`       | Bobot kriteria ke-`j`. Σw_j = 1.                                  |
| `y_ij`      | Nilai ternormalisasi terbobot (`= w_j · r_ij`).                   |
| `A⁺`        | Solusi ideal positif = `{y_1⁺, y_2⁺, ..., y_n⁺}`.                 |
| `A⁻`        | Solusi ideal negatif = `{y_1⁻, y_2⁻, ..., y_n⁻}`.                 |
| `D_i⁺`      | Jarak Euclidean alternatif ke-`i` terhadap A⁺.                    |
| `D_i⁻`      | Jarak Euclidean alternatif ke-`i` terhadap A⁻.                    |
| `V_i`       | Nilai preferensi alternatif ke-`i`. **0 ≤ V_i ≤ 1**.              |

---

## 6. Tahapan Algoritma TOPSIS (10 Langkah)

Implementasi utama: [topsis_controller.dart](lib/app/modules/topsis/controllers/topsis_controller.dart) — fungsi `runAnalysis()`.

### Langkah 1 — Ambil Data Item Terkini
[topsis_controller.dart:25-29](lib/app/modules/topsis/controllers/topsis_controller.dart#L25-L29)

```dart
final currentItems = await _itemService.getItems();
```

Tujuan: memastikan stok yang dianalisis adalah **real-time**, bukan snapshot lama.

### Langkah 2 — Buat Snapshot Stok Bulanan (Audit)
[topsis_controller.dart:33](lib/app/modules/topsis/controllers/topsis_controller.dart#L33)

```dart
await _topsisService.createSnapshot(currentItems, month, year);
```

### Langkah 3 — Agregasi `total_keluar` & `frekuensi_keluar`
[topsis_controller.dart:36-62](lib/app/modules/topsis/controllers/topsis_controller.dart#L36-L62)

Query `barang_keluar` dengan rentang `[awal_bulan, akhir_bulan]`, lalu untuk tiap `idBarang`:

- **`total_keluar`** = Σ `jumlah` semua transaksi.
- **`frekuensi_keluar`** = banyaknya transaksi.

### Langkah 4 — Bangun Matriks Keputusan (X)
[topsis_controller.dart:69-80](lib/app/modules/topsis/controllers/topsis_controller.dart#L69-L80)

Matriks `X` berukuran **m × 3**:

$$
X = \begin{bmatrix}
x_{1,1} & x_{1,2} & x_{1,3} \\
x_{2,1} & x_{2,2} & x_{2,3} \\
\vdots & \vdots & \vdots \\
x_{m,1} & x_{m,2} & x_{m,3}
\end{bmatrix}
$$

Dengan kolom: `[stok_sekarang, total_keluar, frekuensi_keluar]`.

### Langkah 5 — Normalisasi Matriks (Vektor / Euclidean Norm)
[topsis_controller.dart:132-156](lib/app/modules/topsis/controllers/topsis_controller.dart#L132-L156)

$$
r_{ij} = \frac{x_{ij}}{\sqrt{\sum_{i=1}^{m} x_{ij}^2}}
$$

Pengaman pembagian-nol: jika divider = 0 maka di-set ke 1 ([topsis_controller.dart:144](lib/app/modules/topsis/controllers/topsis_controller.dart#L144)).

### Langkah 6 — Bobot Tertimbang
[topsis_controller.dart:158-171](lib/app/modules/topsis/controllers/topsis_controller.dart#L158-L171)

$$
y_{ij} = w_j \cdot r_{ij}
$$

Vektor bobot yang digunakan:

```dart
final weights = [0.30, 0.45, 0.25];
```

### Langkah 7 — Tentukan Solusi Ideal Positif & Negatif
[topsis_controller.dart:173-192](lib/app/modules/topsis/controllers/topsis_controller.dart#L173-L192)

Untuk **benefit** (C2, C3):

$$
A^+_j = \max_i(y_{ij}) \qquad A^-_j = \min_i(y_{ij})
$$

Untuk **cost** (C1 — `stok_sekarang`):

$$
A^+_j = \min_i(y_{ij}) \qquad A^-_j = \max_i(y_{ij})
$$

### Langkah 8 — Hitung Jarak Euclidean
[topsis_controller.dart:194-208](lib/app/modules/topsis/controllers/topsis_controller.dart#L194-L208)

$$
D_i^+ = \sqrt{\sum_{j=1}^{n} (y_{ij} - A^+_j)^2}
$$

$$
D_i^- = \sqrt{\sum_{j=1}^{n} (y_{ij} - A^-_j)^2}
$$

### Langkah 9 — Hitung Nilai Preferensi (V)
[topsis_controller.dart:210-217](lib/app/modules/topsis/controllers/topsis_controller.dart#L210-L217)

$$
V_i = \frac{D_i^-}{D_i^- + D_i^+}
$$

Pengaman pembagian-nol: jika `D⁺ + D⁻ = 0` maka `V = 0` ([topsis_controller.dart:214](lib/app/modules/topsis/controllers/topsis_controller.dart#L214)).

Properti: `0 ≤ V_i ≤ 1`. Makin mendekati 1 → makin dekat dengan ideal positif → makin prioritas.

### Langkah 10 — Perangkingan
[topsis_controller.dart:219-255](lib/app/modules/topsis/controllers/topsis_controller.dart#L219-L255)

Sort `descending` berdasar `V_i`, lalu beri `rank = 1..m`.

---

## 7. Struktur Output (Hasil Ranking)

Setiap entry pada `results` berisi ([topsis_controller.dart:229-237](lib/app/modules/topsis/controllers/topsis_controller.dart#L229-L237)):

| Field               | Sumber                         | Keterangan                                  |
| ------------------- | ------------------------------ | ------------------------------------------- |
| `id_barang`         | `ItemModel.idBarang`           | Identitas sparepart.                        |
| `nama_barang`       | `ItemModel.namaBarang`         | Nama sparepart.                             |
| `nilai_preferensi`  | Hasil V_i                      | Skor TOPSIS (0..1).                         |
| `stok_sekarang`     | C1 mentah                      | Untuk transparansi.                         |
| `total_keluar`      | C2 mentah                      | Hasil agregasi.                             |
| `frekuensi_keluar`  | C3 mentah                      | Hasil agregasi.                             |
| `status_stok`       | `Aman` / `Menipis` / `Kritis`  | Status klasifikasi (derived dari stok_minimum). |
| `rank`              | Urutan setelah sort            | 1 = paling prioritas.                       |

---

## 8. Contoh Perhitungan Manual

Misalkan ada **4 sparepart** dengan data periode satu bulan:

| Alternatif  | stok_sekarang (C1) | total_keluar (C2) | frekuensi_keluar (C3) |
| ----------- | ------------------ | ----------------- | --------------------- |
| A1 (Oli)    | 5                  | 30                | 12                    |
| A2 (Busi)   | 20                 | 8                 | 4                     |
| A3 (Kampas) | 2                  | 25                | 10                    |
| A4 (Filter) | 15                 | 12                | 5                     |

### Step 1 — Hitung pembagi normalisasi tiap kolom

- C1: √(5² + 20² + 2² + 15²) = √(25 + 400 + 4 + 225) = √654 ≈ **25,5734**
- C2: √(30² + 8² + 25² + 12²) = √(900 + 64 + 625 + 144) = √1733 ≈ **41,6293**
- C3: √(12² + 4² + 10² + 5²) = √(144 + 16 + 100 + 25) = √285 ≈ **16,8819**

### Step 2 — Matriks ternormalisasi R

| A   | C1     | C2     | C3     |
| --- | ------ | ------ | ------ |
| A1  | 0,1955 | 0,7207 | 0,7108 |
| A2  | 0,7821 | 0,1922 | 0,2369 |
| A3  | 0,0782 | 0,6005 | 0,5923 |
| A4  | 0,5866 | 0,2882 | 0,2961 |

### Step 3 — Matriks tertimbang Y (bobot 0,30 / 0,45 / 0,25)

| A   | C1     | C2     | C3     |
| --- | ------ | ------ | ------ |
| A1  | 0,0587 | 0,3243 | 0,1777 |
| A2  | 0,2346 | 0,0865 | 0,0592 |
| A3  | 0,0235 | 0,2702 | 0,1481 |
| A4  | 0,1760 | 0,1297 | 0,0740 |

### Step 4 — A⁺ dan A⁻

- C1 (cost): A⁺ = min = **0,0235**; A⁻ = max = **0,2346**
- C2 (benefit): A⁺ = max = **0,3243**; A⁻ = min = **0,0865**
- C3 (benefit): A⁺ = max = **0,1777**; A⁻ = min = **0,0592**

### Step 5 — D⁺, D⁻, dan V

| A   | D⁺      | D⁻      | V = D⁻ / (D⁺ + D⁻) | Rank |
| --- | ------- | ------- | ------------------ | ---- |
| A1  | 0,0352  | 0,3187  | **0,9006**         | 1    |
| A2  | 0,3393  | 0,0000  | **0,0000**         | 4    |
| A3  | 0,0617  | 0,2936  | **0,8264**         | 2    |
| A4  | 0,2681  | 0,0743  | **0,2169**         | 3    |

**Interpretasi:**
- **A1 (Oli)** dan **A3 (Kampas)** berada di rank teratas — keduanya bercirikan stok rendah, demand tinggi, dan frekuensi keluar tinggi → memang seharusnya jadi prioritas restock.
- **A2 (Busi)** memperoleh V = 0 karena nilai terbobotnya **persis menjadi solusi ideal negatif** di seluruh kriteria (stok tertinggi → terburuk untuk cost; demand & frekuensi terendah → terburuk untuk benefit), sehingga D⁻ = 0. Ini perilaku TOPSIS yang benar — bukan bug.

---

## 9. Mapping Variabel Kode → Notasi Skripsi

Tabel ini berguna untuk konsistensi penulisan skripsi:

| Variabel di kode                              | Notasi matematis | Penjelasan                                |
| --------------------------------------------- | ---------------- | ----------------------------------------- |
| `matrix`                                      | X                | Matriks keputusan (raw)                   |
| `normalizedMatrix`                            | R                | Matriks ternormalisasi                    |
| `weights`                                     | W                | Vektor bobot                              |
| `weightedMatrix`                              | Y                | Matriks ternormalisasi terbobot           |
| `idealSolutions[0]` / `positiveIdeal`         | A⁺               | Solusi ideal positif                      |
| `idealSolutions[1]` / `negativeIdeal`         | A⁻               | Solusi ideal negatif                      |
| `distances[i][0]`                             | D_i⁺             | Jarak ke A⁺                               |
| `distances[i][1]`                             | D_i⁻             | Jarak ke A⁻                               |
| `preferenceValues[i]`                         | V_i              | Nilai preferensi alternatif ke-i          |
| `rankedItems`                                 | —                | Hasil sortir descending berdasarkan V_i   |

---

## 10. Asumsi & Batasan Sistem

1. **Periode analisis = bulan berjalan** (`DateTime.now().month`). Data `barang_keluar` di-filter dari tanggal 1 sampai akhir bulan ([topsis_controller.dart:36-49](lib/app/modules/topsis/controllers/topsis_controller.dart#L36-L49)).
2. **Bobot bersifat statis** (di-hardcode di controller). Belum ada fitur untuk admin mengubah bobot secara dinamis.
3. **Item yang tidak memiliki transaksi keluar** tetap diproses, dengan `total_keluar = 0` dan `frekuensi_keluar = 0` ([topsis_controller.dart:70](lib/app/modules/topsis/controllers/topsis_controller.dart#L70)).
4. **Hanya 1 kriteria yang bertipe cost** (yaitu `stok_sekarang`). Dua lainnya bertipe benefit.
5. **`stok_minimum` bukan kriteria TOPSIS** — field ini tetap disimpan di koleksi `items` karena dibutuhkan untuk menghitung `status_stok` (Aman/Menipis/Kritis), tetapi tidak masuk ke matriks keputusan.
6. **Solusi ideal bersifat dinamis** — A⁺ dan A⁻ dihitung dari nilai max/min aktual pada batch analisis saat itu (bukan nilai mutlak yang ditetapkan di awal).

---

## 11. Alur Eksekusi pada Aplikasi

```
[User klik "Run Analysis" di TopsisView]
        │
        ▼
TopsisController.runAnalysis()
        │
        ├─► ItemService.getItems()                      → ambil m item
        ├─► TopsisService.createSnapshot()              → arsip stok bulan ini
        ├─► Query barang_keluar (periode bulan ini)     → agregasi C2 & C3
        ├─► Build matriks X (m × 3)
        ├─► _normalizeMatrix(X)                         → R
        ├─► _applyWeights(R, W)                         → Y
        ├─► _getIdealSolutions(Y)                       → A⁺, A⁻
        ├─► _calculateDistances(Y, A⁺, A⁻)              → D⁺, D⁻
        ├─► _calculatePreferenceValues(D)               → V
        ├─► _rankItems(items, V, stats)                 → ranking
        └─► TopsisService.saveAnalysis(AnalisisTopsisModel)
                │
                ▼
        Firestore: analisis_topsis/{auto-id}
                │
                ▼
        Ditampilkan di TopsisDetailView (tabel ranking + top-3 panel + PDF export)
```

---

## 12. Referensi File Kunci

| File                                                                                                    | Peran                                              |
| ------------------------------------------------------------------------------------------------------- | -------------------------------------------------- |
| [lib/app/modules/topsis/controllers/topsis_controller.dart](lib/app/modules/topsis/controllers/topsis_controller.dart) | **Inti algoritma TOPSIS (10 langkah)**             |
| [lib/app/services/topsis_service.dart](lib/app/services/topsis_service.dart)                            | Akses Firestore (`stock_snapshot`, `analisis_topsis`) |
| [lib/app/models/analisis_topsis_model.dart](lib/app/models/analisis_topsis_model.dart)                  | Struktur hasil analisis                            |
| [lib/app/models/item_model.dart](lib/app/models/item_model.dart)                                        | Struktur alternatif (sparepart)                    |
| [lib/app/models/barang_keluar_model.dart](lib/app/models/barang_keluar_model.dart)                      | Sumber data C3 & C4                                |
| [lib/app/models/stock_snapshot_model.dart](lib/app/models/stock_snapshot_model.dart)                    | Arsip stok bulanan                                 |
| [lib/app/modules/topsis/views/topsis_view.dart](lib/app/modules/topsis/views/topsis_view.dart)          | Halaman trigger analisis                           |
| [lib/app/modules/topsis/views/topsis_detail_view.dart](lib/app/modules/topsis/views/topsis_detail_view.dart) | Halaman detail hasil + export PDF                  |

---

*Dokumen ini dihasilkan dari pembacaan langsung kode sumber proyek; setiap rumus, bobot, dan langkah dapat ditelusuri ke baris kode yang sudah ditautkan di atas.*
