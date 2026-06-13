abstract final class ProductionCostCalculator {
  static const expectedMarginPercent = 45.0;

  static double rawMaterialTotal({
    required double costPerKg,
    required double quantity,
  }) =>
      costPerKg * quantity;

  static double laborTotal({
    required double hoursWorked,
    required double costPerHour,
    required int numberOfWorkers,
  }) =>
      hoursWorked * costPerHour * numberOfWorkers;

  static double transportTotal({
    required double costPerKg,
    required double quantity,
  }) =>
      costPerKg * quantity;

  static double storageTotal({
    required int daysInStorage,
    required double dailyCost,
  }) =>
      daysInStorage * dailyCost;

  static double processingTotal({
    required double electricity,
    required double maintenance,
    required double supplies,
    required double water,
    required double depreciation,
  }) =>
      electricity + maintenance + supplies + water + depreciation;

  static double othersTotal({
    required double qualityControl,
    required double certifications,
    required double insurance,
    required double administrative,
  }) =>
      qualityControl + certifications + insurance + administrative;

  static double grandTotal({
    required double rawMaterialsCost,
    required double laborCost,
    required double transportCost,
    required double storageCost,
    required double processingCost,
    required double otherIndirectCosts,
  }) =>
      rawMaterialsCost +
      laborCost +
      transportCost +
      storageCost +
      processingCost +
      otherIndirectCosts;

  static double costPerKg({
    required double grandTotal,
    required double totalKg,
  }) =>
      totalKg > 0 ? grandTotal / totalKg : 0;

  static double suggestedPrice({
    required double costPerKg,
    double marginPercent = expectedMarginPercent,
  }) =>
      costPerKg * (1 + marginPercent / 100);

  static double potentialMargin({
    required double suggestedPrice,
    required double costPerKg,
  }) =>
      suggestedPrice > 0 ? ((suggestedPrice - costPerKg) / suggestedPrice) * 100 : 0;

  static String currencySymbol(String currency) =>
      currency.toUpperCase() == 'USD' ? r'$' : 'S/.';
}
