class CreateProductionCostRecordInput {
  const CreateProductionCostRecordInput({
    required this.coffeeLotId,
    required this.currency,
    required this.totalKg,
    required this.marginPercent,
    required this.rawMaterialsCost,
    required this.laborCost,
    required this.transportCost,
    required this.storageCost,
    required this.processingCost,
    required this.otherIndirectCosts,
  });

  final int coffeeLotId;
  final String currency;
  final double totalKg;
  final double marginPercent;
  final double rawMaterialsCost;
  final double laborCost;
  final double transportCost;
  final double storageCost;
  final double processingCost;
  final double otherIndirectCosts;
}
