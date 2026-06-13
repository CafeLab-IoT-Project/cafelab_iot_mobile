import 'dart:convert';

class SensoryScores {
  const SensoryScores({
    this.aroma = 0,
    this.cuerpo = 0,
    this.acidez = 0,
    this.dulzor = 0,
    this.amargor = 0,
    this.postgusto = 0,
  });

  final double aroma;
  final double cuerpo;
  final double acidez;
  final double dulzor;
  final double amargor;
  final double postgusto;

  static const SensoryScores empty = SensoryScores();

  factory SensoryScores.fromResultsJson(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return empty;
    }

    try {
      final decoded = jsonDecode(raw);
      return SensoryScores.fromDynamic(decoded);
    } catch (_) {
      return empty;
    }
  }

  factory SensoryScores.fromDynamic(dynamic value) {
    if (value is String) {
      return SensoryScores.fromResultsJson(value);
    }

    if (value is! Map) {
      return empty;
    }

    final map = Map<String, dynamic>.from(value);
    return SensoryScores(
      aroma: _readScore(map, const ['aroma']),
      cuerpo: _readScore(map, const ['cuerpo', 'body']),
      acidez: _readScore(map, const ['acidez', 'acidity']),
      dulzor: _readScore(map, const ['dulzor', 'sweetness']),
      amargor: _readScore(map, const ['amargor', 'bitterness']),
      postgusto: _readScore(map, const ['postgusto', 'aftertaste']),
    );
  }

  static double _readScore(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final exact = map[key];
      if (exact != null) {
        return _clampScore(exact);
      }

      final normalizedEntry = map.entries.cast<MapEntry<String, dynamic>?>().firstWhere(
        (entry) => entry?.key.toLowerCase() == key.toLowerCase(),
        orElse: () => null,
      );
      if (normalizedEntry != null) {
        return _clampScore(normalizedEntry.value);
      }
    }
    return 0;
  }

  static double _clampScore(dynamic raw) {
    final parsed = switch (raw) {
      num _ => raw.toDouble(),
      String _ => double.tryParse(raw.replaceAll(',', '.')),
      _ => null,
    };
    if (parsed == null) {
      return 0;
    }
    if (parsed < 0) return 0;
    if (parsed > 10) return 10;
    return parsed;
  }

  SensoryScores copyWith({
    double? aroma,
    double? cuerpo,
    double? acidez,
    double? dulzor,
    double? amargor,
    double? postgusto,
  }) {
    return SensoryScores(
      aroma: aroma ?? this.aroma,
      cuerpo: cuerpo ?? this.cuerpo,
      acidez: acidez ?? this.acidez,
      dulzor: dulzor ?? this.dulzor,
      amargor: amargor ?? this.amargor,
      postgusto: postgusto ?? this.postgusto,
    );
  }

  Map<String, double> toMap() {
    return {
      'aroma': aroma,
      'cuerpo': cuerpo,
      'acidez': acidez,
      'dulzor': dulzor,
      'amargor': amargor,
      'postgusto': postgusto,
    };
  }

  String toResultsJson() => jsonEncode(toMap());

  List<double> toChartValues() {
    return [aroma, cuerpo, acidez, dulzor, amargor, postgusto];
  }

  bool get isValid => toChartValues().every((value) => value >= 0 && value <= 10);
}
