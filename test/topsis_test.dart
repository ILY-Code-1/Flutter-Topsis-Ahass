import 'dart:convert';
import 'dart:io';
import '../lib/app/services/topsis_calculator.dart';

void main() {
  print('========================================');
  print('TOPSIS Calculation Test Suite');
  print('========================================\n');

  // Load data
  final alternatifFile = File('alternatif.json');
  final expectedFile = File('topsis_expected_results.json');

  if (!alternatifFile.existsSync()) {
    print('ERROR: alternatif.json not found');
    return;
  }
  if (!expectedFile.existsSync()) {
    print('ERROR: topsis_expected_results.json not found');
    return;
  }

  final alternatifJson = json.decode(alternatifFile.readAsStringSync()) as List<dynamic>;
  final expectedJson = json.decode(expectedFile.readAsStringSync()) as Map<String, dynamic>;

  // Build matrix from alternatif.json
  final names = alternatifJson.map((e) => e['alternatif'] as String).toList();
  final matrix = alternatifJson.map((e) => [
    (e['C1'] as int).toDouble(),
    (e['C2'] as int).toDouble(),
    (e['C3'] as int).toDouble(),
  ]).toList();

  final calc = TopsisCalculator();
  final weights = [0.30, 0.45, 0.25];

  int passed = 0;
  int failed = 0;

  // Helper functions
  Map<String, dynamic> findExpected(List<dynamic> list, String name) {
    return list.firstWhere((e) => e['alternatif'] == name) as Map<String, dynamic>;
  }

  bool approxEqual(double a, double b) => (a - b).abs() < 1e-4;

  void check(String step, String name, String field, double actual, double expected) {
    if (approxEqual(actual, expected)) {
      passed++;
    } else {
      failed++;
      print('[FAIL] $step | $name | $field: actual=$actual, expected=$expected, diff=${(actual - expected).abs().toStringAsExponential(3)}');
    }
  }

  // Step 1: Normalization
  print('STEP 1: Normalisasi');
  print('-' * 40);
  final normalized = calc.normalizeMatrix(matrix);
  final expectedNormalized = expectedJson['step1_normalized_matrix'] as List<dynamic>;
  for (int i = 0; i < names.length; i++) {
    final exp = findExpected(expectedNormalized, names[i]);
    check('Step1', names[i], 'C1', normalized[i][0], exp['C1'] as double);
    check('Step1', names[i], 'C2', normalized[i][1], exp['C2'] as double);
    check('Step1', names[i], 'C3', normalized[i][2], exp['C3'] as double);
  }
  print('Step 1 completed: ${names.length * 3} checks\n');

  // Step 2: Weighted normalization
  print('STEP 2: Normalisasi Terbobot');
  print('-' * 40);
  final weighted = calc.applyWeights(normalized, weights);
  final expectedWeighted = expectedJson['step2_weighted_normalized_matrix'] as List<dynamic>;
  for (int i = 0; i < names.length; i++) {
    final exp = findExpected(expectedWeighted, names[i]);
    check('Step2', names[i], 'C1', weighted[i][0], exp['C1'] as double);
    check('Step2', names[i], 'C2', weighted[i][1], exp['C2'] as double);
    check('Step2', names[i], 'C3', weighted[i][2], exp['C3'] as double);
  }
  print('Step 2 completed: ${names.length * 3} checks\n');

  // Step 3: Ideal solutions
  print('STEP 3: Solusi Ideal');
  print('-' * 40);
  final ideals = calc.getIdealSolutions(weighted);
  final expectedIdeal = expectedJson['step3_ideal_solutions'] as Map<String, dynamic>;
  final expectedAPlus = expectedIdeal['A_plus'] as Map<String, dynamic>;
  final expectedAMinus = expectedIdeal['A_minus'] as Map<String, dynamic>;
  check('Step3', 'A+', 'C1', ideals[0][0], expectedAPlus['C1'] as double);
  check('Step3', 'A+', 'C2', ideals[0][1], expectedAPlus['C2'] as double);
  check('Step3', 'A+', 'C3', ideals[0][2], expectedAPlus['C3'] as double);
  check('Step3', 'A-', 'C1', ideals[1][0], expectedAMinus['C1'] as double);
  check('Step3', 'A-', 'C2', ideals[1][1], expectedAMinus['C2'] as double);
  check('Step3', 'A-', 'C3', ideals[1][2], expectedAMinus['C3'] as double);
  print('Step 3 completed: 6 checks\n');

  // Step 4: Distances
  print('STEP 4: Jarak');
  print('-' * 40);
  final distances = calc.calculateDistances(weighted, ideals[0], ideals[1]);
  final expectedDistances = expectedJson['step4_distances'] as List<dynamic>;
  for (int i = 0; i < names.length; i++) {
    final exp = findExpected(expectedDistances, names[i]);
    check('Step4', names[i], 'D+', distances[i][0], exp['D_plus'] as double);
    check('Step4', names[i], 'D-', distances[i][1], exp['D_minus'] as double);
  }
  print('Step 4 completed: ${names.length * 2} checks\n');

  // Step 5: Preference values
  print('STEP 5: Nilai Preferensi');
  print('-' * 40);
  final preferences = calc.calculatePreferenceValues(distances);
  final expectedPrefs = expectedJson['step5_preference_value'] as List<dynamic>;
  for (int i = 0; i < names.length; i++) {
    final exp = findExpected(expectedPrefs, names[i]);
    check('Step5', names[i], 'Ci', preferences[i], exp['Ci'] as double);
  }
  print('Step 5 completed: ${names.length} checks\n');

  // Step 6: Ranking
  print('STEP 6: Perankingan');
  print('-' * 40);
  final ranked = <Map<String, dynamic>>[];
  for (int i = 0; i < names.length; i++) {
    ranked.add({'alternatif': names[i], 'Ci': preferences[i]});
  }
  ranked.sort((a, b) => (b['Ci'] as double).compareTo(a['Ci'] as double));
  for (int i = 0; i < ranked.length; i++) {
    ranked[i]['rank'] = i + 1;
  }

  final expectedRanking = expectedJson['step6_ranking'] as List<dynamic>;
  for (int i = 0; i < expectedRanking.length; i++) {
    final exp = expectedRanking[i] as Map<String, dynamic>;
    final actual = ranked.firstWhere((e) => e['alternatif'] == exp['alternatif']);
    final expectedRank = exp['rank'] as int;
    final actualRank = actual['rank'] as int;
    if (expectedRank == actualRank) {
      passed++;
    } else {
      failed++;
      print('[FAIL] Step6 | ${exp['alternatif']} | actual rank=$actualRank, expected=$expectedRank');
    }
  }
  print('Step 6 completed: ${names.length} checks\n');

  // Summary
  print('========================================');
  print('SUMMARY');
  print('========================================');
  print('Total checks: ${passed + failed}');
  print('Passed: $passed');
  print('Failed: $failed');
  if (passed + failed > 0) {
    print('Success Rate: ${((passed / (passed + failed)) * 100).toStringAsFixed(1)}%');
  }
  print('========================================');

  if (failed == 0) {
    print('\n✓ ALL TESTS PASSED!');
  } else {
    print('\n✗ $failed TESTS FAILED');
  }
}
