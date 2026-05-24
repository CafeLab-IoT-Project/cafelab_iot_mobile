import 'dart:convert';

class DefectModel {
  final int id;
  final String? title;
  final String? description;
  final String? severity;
  final String? location;
  final Map<String, dynamic> raw;

  const DefectModel({
    required this.id,
    required this.raw,
    this.title,
    this.description,
    this.severity,
    this.location,
  });

  factory DefectModel.fromJson(Map<String, dynamic> json) {
    return DefectModel(
      id: (json['id'] as num?)?.toInt() ?? -1,
      title: json['title'] as String?,
      description: json['description'] as String?,
      severity: json['severity'] as String?,
      location: json['location'] as String?,
      raw: json,
    );
  }

  String prettyJson() => const JsonEncoder.withIndent('  ').convert(raw);
}
