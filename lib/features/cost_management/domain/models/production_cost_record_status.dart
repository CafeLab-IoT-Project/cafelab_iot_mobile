enum ProductionCostRecordStatus {
  registrado,
  anulado,
}

extension ProductionCostRecordStatusX on ProductionCostRecordStatus {
  static ProductionCostRecordStatus fromApi(String? raw) {
    final value = (raw ?? 'registrado').toLowerCase();
    return value == 'anulado'
        ? ProductionCostRecordStatus.anulado
        : ProductionCostRecordStatus.registrado;
  }

  String get apiValue => name;

  String get displayLabel => switch (this) {
        ProductionCostRecordStatus.registrado => 'Registrado',
        ProductionCostRecordStatus.anulado => 'Anulado',
      };
}
