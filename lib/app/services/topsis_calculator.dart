import 'dart:math';

class TopsisCalculator {
  List<List<double>> normalizeMatrix(List<List<double>> matrix) {
    if (matrix.isEmpty) return [];
    final int colCount = matrix[0].length;
    final List<double> dividers = List.filled(colCount, 0.0);

    for (int j = 0; j < colCount; j++) {
      double sum = 0;
      for (int i = 0; i < matrix.length; i++) {
        sum += pow(matrix[i][j], 2);
      }
      dividers[j] = sqrt(sum);
      if (dividers[j] == 0) dividers[j] = 1.0;
    }

    return matrix
        .map(
          (row) => row
              .asMap()
              .map((j, value) => MapEntry(j, value / dividers[j]))
              .values
              .toList(),
        )
        .toList();
  }

  List<List<double>> applyWeights(
    List<List<double>> matrix,
    List<double> weights,
  ) {
    return matrix
        .map(
          (row) => row
              .asMap()
              .map((j, value) => MapEntry(j, value * weights[j]))
              .values
              .toList(),
        )
        .toList();
  }

  List<List<double>> getIdealSolutions(List<List<double>> matrix) {
    if (matrix.isEmpty) return [[], []];
    final int colCount = matrix[0].length;
    final positiveIdeal = List<double>.filled(colCount, 0.0);
    final negativeIdeal = List<double>.filled(colCount, 0.0);

    for (int j = 0; j < colCount; j++) {
      List<double> column = matrix.map((row) => row[j]).toList();
      if (j == 0) {
        positiveIdeal[j] = column.reduce(min);
        negativeIdeal[j] = column.reduce(max);
      } else {
        positiveIdeal[j] = column.reduce(max);
        negativeIdeal[j] = column.reduce(min);
      }
    }
    return [positiveIdeal, negativeIdeal];
  }

  List<List<double>> calculateDistances(
    List<List<double>> matrix,
    List<double> positiveIdeal,
    List<double> negativeIdeal,
  ) {
    return matrix.map((row) {
      double dPlus = 0;
      double dMinus = 0;
      for (int j = 0; j < row.length; j++) {
        dPlus += pow(row[j] - positiveIdeal[j], 2);
        dMinus += pow(row[j] - negativeIdeal[j], 2);
      }
      return [sqrt(dPlus), sqrt(dMinus)];
    }).toList();
  }

  List<double> calculatePreferenceValues(List<List<double>> distances) {
    return distances.map((d) {
      final dPlus = d[0];
      final dMinus = d[1];
      if ((dPlus + dMinus) == 0) return 0.0;
      return dMinus / (dPlus + dMinus);
    }).toList();
  }
}
