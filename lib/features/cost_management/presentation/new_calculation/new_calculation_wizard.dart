import 'package:cafelab_iot_mobile/features/cost_management/domain/validators/cost_calculation_validators.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/constants/cost_management_colors.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/cost_management_controller.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/new_calculation/new_calculation_controller.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/new_calculation/widgets/cost_metrics_card.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/coffee_lot.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewCalculationWizard extends StatefulWidget {
  const NewCalculationWizard({
    super.key,
    required this.listController,
    required this.onBackToList,
    required this.onGoHome,
  });

  final CostManagementController listController;
  final VoidCallback onBackToList;
  final VoidCallback onGoHome;

  @override
  State<NewCalculationWizard> createState() => _NewCalculationWizardState();
}

class _NewCalculationWizardState extends State<NewCalculationWizard> {
  final _wizard = NewCalculationController();
  final _step0Key = GlobalKey<FormState>();
  final _step1Key = GlobalKey<FormState>();
  final _step2Key = GlobalKey<FormState>();

  bool _isSuccess = false;

  static const _stepTitles = [
    'Selección de lote',
    'Costos directos',
    'Costos indirectos',
    'Resumen',
  ];

  @override
  void initState() {
    super.initState();
    _wizard.loadLots();
    for (final c in _allFieldControllers) {
      c.addListener(_wizard.onFieldChanged);
    }
  }

  List<TextEditingController> get _allFieldControllers => [
        _wizard.rawCostPerKg,
        _wizard.rawQuantity,
        _wizard.hoursWorked,
        _wizard.costPerHour,
        _wizard.numberOfWorkers,
        _wizard.transportCostPerKg,
        _wizard.transportQuantity,
        _wizard.daysInStorage,
        _wizard.dailyCost,
        _wizard.electricity,
        _wizard.maintenance,
        _wizard.supplies,
        _wizard.water,
        _wizard.depreciation,
        _wizard.qualityControl,
        _wizard.certifications,
        _wizard.insurance,
        _wizard.administrative,
      ];

  @override
  void dispose() {
    for (final c in _allFieldControllers) {
      c.removeListener(_wizard.onFieldChanged);
    }
    _wizard.dispose();
    super.dispose();
  }

  bool _validateCurrentStep() {
    return switch (_wizard.currentStep) {
      0 => _step0Key.currentState?.validate() ?? false,
      1 => _step1Key.currentState?.validate() ?? false,
      2 => _step2Key.currentState?.validate() ?? false,
      // En resumen los formularios de pasos anteriores no están montados.
      _ => _areAllStepsValidByValue(),
    };
  }

  bool _areAllStepsValidByValue() {
    return _isStep0ValidByValue() &&
        _isStep1ValidByValue() &&
        _isStep2ValidByValue();
  }

  int _firstInvalidStepIndex() {
    if (!_isStep0ValidByValue()) return 0;
    if (!_isStep1ValidByValue()) return 1;
    if (!_isStep2ValidByValue()) return 2;
    return -1;
  }

  bool _isStep0ValidByValue() {
    return _wizard.selectedLotId != null && _wizard.currency.isNotEmpty;
  }

  bool _isStep1ValidByValue() {
    final v1 = CostCalculationValidators.decimalInRange(
      _wizard.rawCostPerKg.text,
      label: 'Costo por kg',
      min: 0.01,
      max: 100,
    );
    final v2 = CostCalculationValidators.decimalInRange(
      _wizard.rawQuantity.text,
      label: 'Cantidad',
      min: 0.01,
      max: 70,
    );
    final v3 = CostCalculationValidators.integerInRange(
      _wizard.hoursWorked.text,
      label: 'Tiempo',
      min: 1,
      max: 60,
    );
    final v4 = CostCalculationValidators.decimalInRange(
      _wizard.costPerHour.text,
      label: 'Costo por hora',
      min: 0.1,
      max: 100,
    );
    final v5 = CostCalculationValidators.integerInRange(
      _wizard.numberOfWorkers.text,
      label: 'Trabajadores',
      min: 1,
      max: 10,
    );
    return v1 == null && v2 == null && v3 == null && v4 == null && v5 == null;
  }

  bool _isStep2ValidByValue() {
    final checks = [
      CostCalculationValidators.decimalInRange(
        _wizard.transportCostPerKg.text,
        label: 'Costo por kg',
        min: 0.1,
        max: 100,
      ),
      CostCalculationValidators.decimalInRange(
        _wizard.transportQuantity.text,
        label: 'Cantidad',
        min: 1,
        max: 200,
      ),
      CostCalculationValidators.integerInRange(
        _wizard.daysInStorage.text,
        label: 'Días',
        min: 1,
        max: 30,
      ),
      CostCalculationValidators.decimalInRange(
        _wizard.dailyCost.text,
        label: 'Costo diario',
        min: 0.1,
        max: 100,
      ),
      CostCalculationValidators.decimalInRange(
        _wizard.electricity.text,
        label: 'Electricidad',
        min: 0,
        max: 200,
      ),
      CostCalculationValidators.decimalInRange(
        _wizard.maintenance.text,
        label: 'Mantenimiento',
        min: 0,
        max: 200,
      ),
      CostCalculationValidators.decimalInRange(
        _wizard.supplies.text,
        label: 'Insumos',
        min: 0,
        max: 200,
      ),
      CostCalculationValidators.decimalInRange(
        _wizard.water.text,
        label: 'Agua',
        min: 0,
        max: 200,
      ),
      CostCalculationValidators.decimalInRange(
        _wizard.depreciation.text,
        label: 'Depreciación',
        min: 0,
        max: 200,
      ),
      CostCalculationValidators.decimalInRange(
        _wizard.qualityControl.text,
        label: 'Control de calidad',
        min: 0,
        max: 200,
      ),
      CostCalculationValidators.decimalInRange(
        _wizard.certifications.text,
        label: 'Certificaciones',
        min: 0,
        max: 200,
      ),
      CostCalculationValidators.decimalInRange(
        _wizard.insurance.text,
        label: 'Seguros',
        min: 0,
        max: 200,
      ),
      CostCalculationValidators.decimalInRange(
        _wizard.administrative.text,
        label: 'Administrativos',
        min: 0,
        max: 200,
      ),
    ];

    return checks.every((e) => e == null);
  }

  void _goNext() {
    if (!_validateCurrentStep()) return;
    if (_wizard.currentStep < NewCalculationController.totalSteps - 1) {
      _wizard.setStep(_wizard.currentStep + 1);
    }
  }

  void _goBack() {
    if (_wizard.currentStep > 0) {
      _wizard.setStep(_wizard.currentStep - 1);
    }
  }

  Future<void> _requestSave() async {
    _step0Key.currentState?.validate();
    _step1Key.currentState?.validate();
    _step2Key.currentState?.validate();
    if (!_validateCurrentStep()) {
      final firstInvalidStep = _firstInvalidStepIndex();
      setState(() {
        _wizard.errorMessage = 'Complete todos los campos obligatorios.';
        if (firstInvalidStep >= 0) {
          _wizard.setStep(firstInvalidStep);
        }
      });
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar registro'),
        content: const Text(
          'Al confirmar, se registrará el cálculo de costos con los valores ingresados. '
          'Revise el resumen antes de continuar.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: CostManagementColors.headerGreen,
            ),
            child: const Text('Confirmar y guardar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    await _save();
  }

  Future<void> _save() async {
    final input = _wizard.buildCreateInput();
    if (input == null) {
      setState(() => _wizard.errorMessage = 'Lote o cantidad (kg) inválidos.');
      return;
    }

    setState(() => _wizard.isSubmitting = true);
    final saved = await widget.listController.createRecord(input);
    if (!mounted) return;

    setState(() {
      _wizard.isSubmitting = false;
      if (saved != null) {
        _isSuccess = true;
        _wizard.errorMessage = null;
      } else {
        _wizard.errorMessage =
            widget.listController.errorMessage ?? 'Error al guardar.';
      }
    });
  }

  void _cancelWizard() {
    _wizard.reset();
    widget.onBackToList();
  }

  void _startAnother() {
    setState(() {
      _isSuccess = false;
      _wizard.reset();
    });
    _wizard.loadLots();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_wizard, widget.listController]),
      builder: (_, __) {
        if (_wizard.isLoadingLots) {
          return const Center(child: CircularProgressIndicator());
        }

        if (_isSuccess) {
          return _SuccessView(
            costPerKg: _wizard.costPerKg,
            potentialMargin: _wizard.potentialMargin,
            suggestedPrice: _wizard.suggestedPrice,
            currencySymbol: _wizard.currencySymbol,
            onBackToList: widget.onBackToList,
            onNewCalculation: _startAnother,
            onGoHome: widget.onGoHome,
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _WizardStepIndicator(
                currentStep: _wizard.currentStep,
                titles: _stepTitles,
              ),
              if (_wizard.errorMessage != null) ...[
                const SizedBox(height: 12),
                _ErrorBanner(message: _wizard.errorMessage!),
              ],
              const SizedBox(height: 16),
              _buildStepContent(),
              const SizedBox(height: 20),
              _buildNavigationButtons(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepContent() {
    return switch (_wizard.currentStep) {
      0 => _StepLotSelection(formKey: _step0Key, wizard: _wizard),
      1 => _StepDirectCosts(formKey: _step1Key, wizard: _wizard),
      2 => _StepIndirectCosts(formKey: _step2Key, wizard: _wizard),
      _ => _StepSummary(wizard: _wizard, onEditStep: _wizard.setStep),
    };
  }

  Widget _buildNavigationButtons() {
    final isLast = _wizard.currentStep == NewCalculationController.totalSteps - 1;

    return Column(
      children: [
        if (_wizard.currentStep > 0 && !isLast)
          TextButton(
            onPressed: _wizard.isSubmitting ? null : _goBack,
            child: const Text('Anterior'),
          ),
        if (isLast) ...[
          TextButton(
            onPressed: _wizard.isSubmitting ? null : _goBack,
            child: const Text('Anterior'),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _wizard.isSubmitting ? null : _requestSave,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.blue.shade800,
                side: BorderSide(color: Colors.blue.shade800),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _wizard.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Ver resultado'),
            ),
          ),
        ] else if (_wizard.currentStep == 0) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _goNext,
              style: _primaryButtonStyle,
              child: const Text('Continuar'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _cancelWizard,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Cancelar'),
            ),
          ),
        ] else
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _goNext,
              style: _primaryButtonStyle,
              child: const Text('Continuar'),
            ),
          ),
      ],
    );
  }

  static ButtonStyle get _primaryButtonStyle => FilledButton.styleFrom(
        backgroundColor: CostManagementColors.headerGreen,
        foregroundColor: Colors.white,
        disabledBackgroundColor: Colors.grey.shade400,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      );
}

// --- Step indicator ---

class _WizardStepIndicator extends StatelessWidget {
  const _WizardStepIndicator({
    required this.currentStep,
    required this.titles,
  });

  final int currentStep;
  final List<String> titles;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(titles.length, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;
          return Padding(
            padding: EdgeInsets.only(right: index < titles.length - 1 ? 8 : 0),
            child: Container(
              width: 120,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isActive
                      ? CostManagementColors.headerGreen
                      : Colors.grey.shade300,
                  width: isActive ? 2 : 1,
                ),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: isActive || isCompleted
                        ? CostManagementColors.headerGreen
                        : Colors.grey.shade400,
                    child: isCompleted
                        ? const Icon(Icons.edit, size: 14, color: Colors.white)
                        : Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    titles[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// --- Step 0: Lot ---

class _StepLotSelection extends StatelessWidget {
  const _StepLotSelection({
    required this.formKey,
    required this.wizard,
  });

  final GlobalKey<FormState> formKey;
  final NewCalculationController wizard;

  @override
  Widget build(BuildContext context) {
    return _FormCard(
      title: 'Selección de lote',
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FormField<int>(
              initialValue: wizard.selectedLotId,
              validator: (value) =>
                  value == null ? 'Debe seleccionar un lote' : null,
              builder: (field) => InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Lote de café *',
                  border: const OutlineInputBorder(),
                  errorText: field.errorText,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    isExpanded: true,
                    value: wizard.selectedLotId,
                    hint: Text(
                      wizard.lots.isEmpty
                          ? 'No hay lotes disponibles'
                          : 'Seleccione un lote',
                    ),
                    items: wizard.lots
                        .map(
                          (CoffeeLot lot) => DropdownMenuItem(
                            value: lot.id,
                            child: Text(
                              '${lot.lotName} — ${lot.coffeeType} · '
                              '${lot.weight.toStringAsFixed(1)} kg · ${lot.origin}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: wizard.lots.isEmpty
                        ? null
                        : (value) {
                            wizard.setLot(value);
                            field.didChange(value);
                          },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            FormField<String>(
              initialValue: wizard.currency,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Seleccione moneda' : null,
              builder: (field) => InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Moneda del cálculo *',
                  border: const OutlineInputBorder(),
                  errorText: field.errorText,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: wizard.currency,
                    items: const [
                      DropdownMenuItem(
                        value: 'PEN',
                        child: Text('Sol peruano (S/.)'),
                      ),
                      DropdownMenuItem(
                        value: 'USD',
                        child: Text('Dólar (USD)'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      wizard.setCurrency(value);
                      field.didChange(value);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Step 1: Direct costs ---

class _StepDirectCosts extends StatelessWidget {
  const _StepDirectCosts({
    required this.formKey,
    required this.wizard,
  });

  final GlobalKey<FormState> formKey;
  final NewCalculationController wizard;

  @override
  Widget build(BuildContext context) {
    final sym = wizard.currencySymbol;
    return Form(
      key: formKey,
      child: Column(
        children: [
          _FormCard(
            title: 'Costos de materia prima',
            child: Column(
              children: [
                _CostTextField(
                  controller: wizard.rawCostPerKg,
                  label: 'Costo por kg de café verde *',
                  validator: (v) => CostCalculationValidators.decimalInRange(
                    v,
                    label: 'Costo por kg',
                    min: 0.01,
                    max: 100,
                  ),
                ),
                const SizedBox(height: 12),
                _CostTextField(
                  controller: wizard.rawQuantity,
                  label: 'Cantidad de café verde (kg) *',
                  validator: (v) => CostCalculationValidators.decimalInRange(
                    v,
                    label: 'Cantidad',
                    min: 0.01,
                    max: 70,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Total: $sym ${wizard.rawMaterialTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FormCard(
            title: 'Costos de mano de obra directa',
            child: Column(
              children: [
                _CostTextField(
                  controller: wizard.hoursWorked,
                  label: 'Tiempo (minutos u horas trabajadas) *',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => CostCalculationValidators.integerInRange(
                    v,
                    label: 'Tiempo',
                    min: 1,
                    max: 60,
                  ),
                ),
                const SizedBox(height: 12),
                _CostTextField(
                  controller: wizard.costPerHour,
                  label: 'Costo por hora *',
                  validator: (v) => CostCalculationValidators.decimalInRange(
                    v,
                    label: 'Costo por hora',
                    min: 0.1,
                    max: 100,
                  ),
                ),
                const SizedBox(height: 12),
                _CostTextField(
                  controller: wizard.numberOfWorkers,
                  label: 'Número de trabajadores *',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => CostCalculationValidators.integerInRange(
                    v,
                    label: 'Trabajadores',
                    min: 1,
                    max: 10,
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Total: $sym ${wizard.laborTotal.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Step 2: Indirect costs ---

class _StepIndirectCosts extends StatelessWidget {
  const _StepIndirectCosts({
    required this.formKey,
    required this.wizard,
  });

  final GlobalKey<FormState> formKey;
  final NewCalculationController wizard;

  @override
  Widget build(BuildContext context) {
    final sym = wizard.currencySymbol;
    return Form(
      key: formKey,
      child: Column(
        children: [
          _FormCard(
            title: 'Costos de Transporte',
            child: Column(
              children: [
                _CostTextField(
                  controller: wizard.transportCostPerKg,
                  label: 'Costo por kg *',
                  validator: (v) => CostCalculationValidators.decimalInRange(
                    v,
                    label: 'Costo por kg',
                    min: 0.1,
                    max: 100,
                  ),
                ),
                const SizedBox(height: 12),
                _CostTextField(
                  controller: wizard.transportQuantity,
                  label: 'Cantidad (kg) *',
                  validator: (v) => CostCalculationValidators.decimalInRange(
                    v,
                    label: 'Cantidad',
                    min: 1,
                    max: 200,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: $sym ${wizard.transportTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FormCard(
            title: 'Costos de Almacenamiento',
            child: Column(
              children: [
                _CostTextField(
                  controller: wizard.daysInStorage,
                  label: 'Días en almacén *',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) => CostCalculationValidators.integerInRange(
                    v,
                    label: 'Días',
                    min: 1,
                    max: 30,
                  ),
                ),
                const SizedBox(height: 12),
                _CostTextField(
                  controller: wizard.dailyCost,
                  label: 'Costo diario *',
                  validator: (v) => CostCalculationValidators.decimalInRange(
                    v,
                    label: 'Costo diario',
                    min: 0.1,
                    max: 100,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: $sym ${wizard.storageTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FormCard(
            title: 'Costos de Procesamiento',
            child: Column(
              children: [
                _CostTextField(
                  controller: wizard.electricity,
                  label: 'Electricidad *',
                  validator: (v) => CostCalculationValidators.decimalInRange(
                    v,
                    label: 'Electricidad',
                    min: 0,
                    max: 200,
                  ),
                ),
                const SizedBox(height: 12),
                _CostTextField(
                  controller: wizard.maintenance,
                  label: 'Mantenimiento *',
                  validator: (v) => CostCalculationValidators.decimalInRange(
                    v,
                    label: 'Mantenimiento',
                    min: 0,
                    max: 200,
                  ),
                ),
                const SizedBox(height: 12),
                _CostTextField(
                  controller: wizard.supplies,
                  label: 'Insumos *',
                  validator: (v) => CostCalculationValidators.decimalInRange(
                    v,
                    label: 'Insumos',
                    min: 0,
                    max: 200,
                  ),
                ),
                const SizedBox(height: 12),
                _CostTextField(
                  controller: wizard.water,
                  label: 'Agua *',
                  validator: (v) => CostCalculationValidators.decimalInRange(
                    v,
                    label: 'Agua',
                    min: 0,
                    max: 200,
                  ),
                ),
                const SizedBox(height: 12),
                _CostTextField(
                  controller: wizard.depreciation,
                  label: 'Depreciación *',
                  validator: (v) => CostCalculationValidators.decimalInRange(
                    v,
                    label: 'Depreciación',
                    min: 0,
                    max: 200,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: $sym ${wizard.processingTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FormCard(
            title: 'Otros costos indirectos',
            child: Column(
              children: [
                _CostTextField(
                  controller: wizard.qualityControl,
                  label: 'Control de calidad *',
                  validator: (v) => CostCalculationValidators.decimalInRange(
                    v,
                    label: 'Control de calidad',
                    min: 0,
                    max: 200,
                  ),
                ),
                const SizedBox(height: 12),
                _CostTextField(
                  controller: wizard.certifications,
                  label: 'Certificaciones *',
                  validator: (v) => CostCalculationValidators.decimalInRange(
                    v,
                    label: 'Certificaciones',
                    min: 0,
                    max: 200,
                  ),
                ),
                const SizedBox(height: 12),
                _CostTextField(
                  controller: wizard.insurance,
                  label: 'Seguros *',
                  validator: (v) => CostCalculationValidators.decimalInRange(
                    v,
                    label: 'Seguros',
                    min: 0,
                    max: 200,
                  ),
                ),
                const SizedBox(height: 12),
                _CostTextField(
                  controller: wizard.administrative,
                  label: 'Administrativos *',
                  validator: (v) => CostCalculationValidators.decimalInRange(
                    v,
                    label: 'Administrativos',
                    min: 0,
                    max: 200,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: $sym ${wizard.othersTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Step 3: Summary ---

class _StepSummary extends StatelessWidget {
  const _StepSummary({
    required this.wizard,
    required this.onEditStep,
  });

  final NewCalculationController wizard;
  final ValueChanged<int> onEditStep;

  @override
  Widget build(BuildContext context) {
    final sym = wizard.currencySymbol;
    final lot = wizard.selectedLot;

    final inputRows = [
      _SummaryRow('Lote de café', lot?.lotName ?? '—', 0),
      _SummaryRow('Moneda del cálculo', wizard.currency, 0),
      _SummaryRow(
        'Costo por kg de café verde',
        '$sym ${wizard.rawCostPerKg.text}',
        1,
      ),
      _SummaryRow(
        'Cantidad de café verde (kg)',
        '${wizard.rawQuantity.text} kg',
        1,
      ),
      _SummaryRow('Tiempo trabajado', wizard.hoursWorked.text, 1),
      _SummaryRow('Costo por hora', '$sym ${wizard.costPerHour.text}', 1),
      _SummaryRow('Número de trabajadores', wizard.numberOfWorkers.text, 1),
      _SummaryRow(
        'Costo por kg (transporte)',
        '$sym ${wizard.transportCostPerKg.text}',
        2,
      ),
      _SummaryRow(
        'Cantidad transporte (kg)',
        '${wizard.transportQuantity.text} kg',
        2,
      ),
      _SummaryRow('Días en almacén', wizard.daysInStorage.text, 2),
      _SummaryRow('Costo diario', '$sym ${wizard.dailyCost.text}', 2),
      _SummaryRow('Electricidad', '$sym ${wizard.electricity.text}', 2),
      _SummaryRow('Mantenimiento', '$sym ${wizard.maintenance.text}', 2),
      _SummaryRow('Insumos', '$sym ${wizard.supplies.text}', 2),
      _SummaryRow('Agua', '$sym ${wizard.water.text}', 2),
      _SummaryRow('Depreciación', '$sym ${wizard.depreciation.text}', 2),
      _SummaryRow(
        'Control de calidad',
        '$sym ${wizard.qualityControl.text}',
        2,
      ),
      _SummaryRow(
        'Certificaciones',
        '$sym ${wizard.certifications.text}',
        2,
      ),
      _SummaryRow('Seguros', '$sym ${wizard.insurance.text}', 2),
      _SummaryRow(
        'Administrativos',
        '$sym ${wizard.administrative.text}',
        2,
      ),
    ];

    final categoryRows = [
      ('Materia Prima', wizard.rawMaterialTotal),
      ('Mano de Obra Directa', wizard.laborTotal),
      ('Transporte', wizard.transportTotal),
      ('Almacenamiento', wizard.storageTotal),
      ('Procesamiento', wizard.processingTotal),
      ('Otros', wizard.othersTotal),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Valores ingresados (puede editar por sección)',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        _FormCard(
          child: Column(
            children: inputRows
                .map(
                  (row) => _SummaryListTile(
                    label: row.label,
                    value: row.value,
                    onEdit: () => onEditStep(row.stepIndex),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Resumen por categoría',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 12),
        _FormCard(
          child: Column(
            children: categoryRows
                .map(
                  (row) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      children: [
                        Expanded(child: Text(row.$1)),
                        Text(
                          '$sym ${row.$2.toStringAsFixed(2)}',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: 20),
        CostMetricsCard(
          costPerKg: wizard.costPerKg,
          potentialMargin: wizard.potentialMargin,
          suggestedPrice: wizard.suggestedPrice,
          currencySymbol: sym,
        ),
      ],
    );
  }
}

class _SummaryRow {
  const _SummaryRow(this.label, this.value, this.stepIndex);
  final String label;
  final String value;
  final int stepIndex;
}

// --- Success ---

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    required this.costPerKg,
    required this.potentialMargin,
    required this.suggestedPrice,
    required this.currencySymbol,
    required this.onBackToList,
    required this.onNewCalculation,
    required this.onGoHome,
  });

  final double costPerKg;
  final double potentialMargin;
  final double suggestedPrice;
  final String currencySymbol;
  final VoidCallback onBackToList;
  final VoidCallback onNewCalculation;
  final VoidCallback onGoHome;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 64),
          const SizedBox(height: 16),
          const Text(
            '¡Cálculo registrado exitosamente!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),
          CostMetricsCard(
            costPerKg: costPerKg,
            potentialMargin: potentialMargin,
            suggestedPrice: suggestedPrice,
            currencySymbol: currencySymbol,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onBackToList,
              style: FilledButton.styleFrom(
                backgroundColor: CostManagementColors.headerGreen,
              ),
              child: const Text('Volver a la lista'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onNewCalculation,
              child: const Text('Nuevo cálculo'),
            ),
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: onGoHome, child: const Text('Salir al inicio')),
        ],
      ),
    );
  }
}

// --- Shared widgets ---

class _FormCard extends StatelessWidget {
  const _FormCard({this.title, required this.child});

  final String? title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }
}

class _CostTextField extends StatelessWidget {
  const _CostTextField({
    required this.controller,
    required this.label,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
  });

  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType ?? const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: validator,
    );
  }
}

class _SummaryListTile extends StatelessWidget {
  const _SummaryListTile({
    required this.label,
    required this.value,
    required this.onEdit,
  });

  final String label;
  final String value;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
          ),
          Expanded(
            flex: 2,
            child: Text(value, textAlign: TextAlign.end),
          ),
          TextButton(onPressed: onEdit, child: const Text('Editar')),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        border: const Border(left: BorderSide(color: Color(0xFFC62828), width: 4)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(message, style: const TextStyle(color: Color(0xFFC62828))),
    );
  }
}
