class AnnulProductionCostRecordRequestDto {
  const AnnulProductionCostRecordRequestDto({required this.reason});

  final String reason;

  Map<String, dynamic> toJson() => {'reason': reason};
}
