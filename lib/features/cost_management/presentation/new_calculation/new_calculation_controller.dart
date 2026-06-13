import 'package:cafelab_iot_mobile/features/cost_management/domain/models/create_production_cost_record_input.dart';
import 'package:cafelab_iot_mobile/features/cost_management/domain/utils/production_cost_calculator.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/data/coffee_lots_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/coffee_lot.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/coffee_lots_repository.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/material.dart';

class NewCalculationController extends ChangeNotifier {
  NewCalculationController({CoffeeLotsRepository? coffeeLotsRepository})
      : _coffeeLotsRepository = coffeeLotsRepository ?? CoffeeLotsRepositoryImpl();

  final CoffeeLotsRepository _coffeeLotsRepository;

  static const totalSteps = 4;

  int currentStep = 0;
  bool isLoadingLots = false;
  bool isSubmitting = false;
  String? errorMessage;
  List<CoffeeLot> lots = [];

  int? selectedLotId;
  String currency = 'PEN';

  final rawCostPerKg = TextEditingController();
  final rawQuantity = TextEditingController();
  final hoursWorked = TextEditingController();
  final costPerHour = TextEditingController();
  final numberOfWorkers = TextEditingController(text: '1');

  final transportCostPerKg = TextEditingController();
  final transportQuantity = TextEditingController();
  final daysInStorage = TextEditingController();
  final dailyCost = TextEditingController();

  final electricity = TextEditingController(text: '0');
  final maintenance = TextEditingController(text: '0');
  final supplies = TextEditingController(text: '0');
  final water = TextEditingController(text: '0');
  final depreciation = TextEditingController(text: '0');

  final qualityControl = TextEditingController(text: '0');
  final certifications = TextEditingController(text: '0');
  final insurance = TextEditingController(text: '0');
  final administrative = TextEditingController(text: '0');

  String get currencySymbol => ProductionCostCalculator.currencySymbol(currency);

  CoffeeLot? get selectedLot {
    if (selectedLotId == null) return null;
    for (final lot in lots) {
      if (lot.id == selectedLotId) return lot;
    }
    return null;
  }

  double _parse(String text) => double.tryParse(text.trim().replaceAll(',', '.')) ?? 0;
  int _parseInt(String text) => int.tryParse(text.trim()) ?? 0;

  double get rawMaterialTotal => ProductionCostCalculator.rawMaterialTotal(
        costPerKg: _parse(rawCostPerKg.text),
        quantity: _parse(rawQuantity.text),
      );

  double get laborTotal => ProductionCostCalculator.laborTotal(
        hoursWorked: _parse(hoursWorked.text),
        costPerHour: _parse(costPerHour.text),
        numberOfWorkers: _parseInt(numberOfWorkers.text),
      );

  double get transportTotal => ProductionCostCalculator.transportTotal(
        costPerKg: _parse(transportCostPerKg.text),
        quantity: _parse(transportQuantity.text),
      );

  double get storageTotal => ProductionCostCalculator.storageTotal(
        daysInStorage: _parseInt(daysInStorage.text),
        dailyCost: _parse(dailyCost.text),
      );

  double get processingTotal => ProductionCostCalculator.processingTotal(
        electricity: _parse(electricity.text),
        maintenance: _parse(maintenance.text),
        supplies: _parse(supplies.text),
        water: _parse(water.text),
        depreciation: _parse(depreciation.text),
      );

  double get othersTotal => ProductionCostCalculator.othersTotal(
        qualityControl: _parse(qualityControl.text),
        certifications: _parse(certifications.text),
        insurance: _parse(insurance.text),
        administrative: _parse(administrative.text),
      );

  double get totalDirectCosts => rawMaterialTotal + laborTotal;

  double get totalIndirectCosts =>
      transportTotal + storageTotal + processingTotal + othersTotal;

  double get grandTotal => ProductionCostCalculator.grandTotal(
        rawMaterialsCost: rawMaterialTotal,
        laborCost: laborTotal,
        transportCost: transportTotal,
        storageCost: storageTotal,
        processingCost: processingTotal,
        otherIndirectCosts: othersTotal,
      );

  double get totalKg => _parse(rawQuantity.text);

  double get costPerKg => ProductionCostCalculator.costPerKg(
        grandTotal: grandTotal,
        totalKg: totalKg,
      );

  double get suggestedPrice => ProductionCostCalculator.suggestedPrice(
        costPerKg: costPerKg,
      );

  double get potentialMargin => ProductionCostCalculator.potentialMargin(
        suggestedPrice: suggestedPrice,
        costPerKg: costPerKg,
      );

  Future<void> loadLots() async {
    isLoadingLots = true;
    errorMessage = null;
    notifyListeners();
    try {
      lots = await _coffeeLotsRepository.getAll();
    } on ProductionApiException catch (e) {
      errorMessage = e.userMessage;
    } catch (e) {
      errorMessage = 'No se pudieron cargar los lotes: $e';
    } finally {
      isLoadingLots = false;
      notifyListeners();
    }
  }

  void reset() {
    currentStep = 0;
    isSubmitting = false;
    errorMessage = null;
    selectedLotId = null;
    currency = 'PEN';

    rawCostPerKg.clear();
    rawQuantity.clear();
    hoursWorked.clear();
    costPerHour.clear();
    numberOfWorkers.text = '1';

    transportCostPerKg.clear();
    transportQuantity.clear();
    daysInStorage.clear();
    dailyCost.clear();

    for (final c in [
      electricity,
      maintenance,
      supplies,
      water,
      depreciation,
      qualityControl,
      certifications,
      insurance,
      administrative,
    ]) {
      c.text = '0';
    }
    notifyListeners();
  }

  void setStep(int step) {
    currentStep = step.clamp(0, totalSteps - 1);
    notifyListeners();
  }

  void setLot(int? lotId) {
    selectedLotId = lotId;
    notifyListeners();
  }

  void setCurrency(String value) {
    currency = value;
    notifyListeners();
  }

  void onFieldChanged() => notifyListeners();

  CreateProductionCostRecordInput? buildCreateInput() {
    if (selectedLotId == null || totalKg <= 0) return null;
    return CreateProductionCostRecordInput(
      coffeeLotId: selectedLotId!,
      currency: currency,
      totalKg: totalKg,
      marginPercent: ProductionCostCalculator.expectedMarginPercent,
      rawMaterialsCost: rawMaterialTotal,
      laborCost: laborTotal,
      transportCost: transportTotal,
      storageCost: storageTotal,
      processingCost: processingTotal,
      otherIndirectCosts: othersTotal,
    );
  }

  @override
  void dispose() {
    rawCostPerKg.dispose();
    rawQuantity.dispose();
    hoursWorked.dispose();
    costPerHour.dispose();
    numberOfWorkers.dispose();
    transportCostPerKg.dispose();
    transportQuantity.dispose();
    daysInStorage.dispose();
    dailyCost.dispose();
    electricity.dispose();
    maintenance.dispose();
    supplies.dispose();
    water.dispose();
    depreciation.dispose();
    qualityControl.dispose();
    certifications.dispose();
    insurance.dispose();
    administrative.dispose();
    super.dispose();
  }
}
