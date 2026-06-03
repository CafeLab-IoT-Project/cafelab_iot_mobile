import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/create_inventory_entry_request.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/models/inventory_view_models.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/widgets/inventory_common.dart';
import 'package:flutter/material.dart';

class InventoryConsumptionFormDialog extends StatefulWidget {
  const InventoryConsumptionFormDialog({
    super.key,
    required this.lots,
    required this.movementsForLot,
    required this.onSubmit,
  });

  final List<InventoryLotSnapshot> lots;
  final List<InventoryEntryRecord> Function(int lotId) movementsForLot;
  final Future<String?> Function(CreateInventoryEntryRequest request) onSubmit;

  @override
  State<InventoryConsumptionFormDialog> createState() =>
      _InventoryConsumptionFormDialogState();
}

class _InventoryConsumptionFormDialogState
    extends State<InventoryConsumptionFormDialog> {
  late final TextEditingController _finalProductController;
  late final TextEditingController _quantityController;
  final Map<String, String> _fieldErrors = <String, String>{};

  DateTime _selectedDate = DateTime.now();
  int? _selectedLotId;
  String? _submitError;
  bool _isSubmitting = false;

  double? get _typedQuantity => double.tryParse(_quantityController.text.trim());

  double? get _projectedRemainingStock {
    final selectedLot = _selectedLot;
    if (selectedLot == null) {
      return null;
    }

    final quantity = _typedQuantity;
    if (quantity == null || quantity.isNaN || quantity.isNegative) {
      return selectedLot.currentStock;
    }

    final projected = selectedLot.currentStock - quantity;
    return projected < 0 ? 0 : projected;
  }

  InventoryLotSnapshot? get _selectedLot {
    final lotId = _selectedLotId;
    if (lotId == null) {
      return null;
    }

    for (final lot in widget.lots) {
      if (lot.lot.id == lotId) {
        return lot;
      }
    }
    return null;
  }

  List<InventoryEntryRecord> get _previousMovements {
    final lotId = _selectedLotId;
    if (lotId == null) {
      return const <InventoryEntryRecord>[];
    }

    return widget.movementsForLot(lotId);
  }

  @override
  void initState() {
    super.initState();
    _finalProductController = TextEditingController();
    _quantityController = TextEditingController();
    _quantityController.addListener(_handleQuantityChanged);
    if (widget.lots.isNotEmpty) {
      _selectedLotId = widget.lots.first.lot.id;
    }
  }

  @override
  void dispose() {
    _quantityController.removeListener(_handleQuantityChanged);
    _finalProductController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  void _handleQuantityChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: const Color(0xFF3E4234),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) {
      return;
    }

    setState(() {
      _selectedDate = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _selectedDate.hour,
        _selectedDate.minute,
      );
    });
  }

  CreateInventoryEntryRequest? _validateForm() {
    _fieldErrors.clear();

    final selectedLot = _selectedLot;
    final finalProduct = _finalProductController.text.trim();
    final quantityText = _quantityController.text.trim();
    final quantity = double.tryParse(quantityText);

    if (_selectedDate == DateTime(0)) {
      _fieldErrors['date'] = 'Selecciona la fecha de consumo.';
    }
    if (selectedLot == null) {
      _fieldErrors['lot'] = 'Selecciona un lote.';
    }
    if (finalProduct.isEmpty) {
      _fieldErrors['finalProduct'] = 'Ingresa el producto final.';
    }
    if (quantityText.isEmpty) {
      _fieldErrors['quantity'] = 'Ingresa la cantidad usada.';
    } else if (quantity == null || quantity <= 0) {
      _fieldErrors['quantity'] = 'Ingresa una cantidad numerica mayor a 0.';
    } else if (selectedLot != null && quantity > selectedLot.currentStock) {
      _fieldErrors['quantity'] =
          'La cantidad usada no puede superar el stock disponible.';
    }

    if (_fieldErrors.isNotEmpty || selectedLot == null || quantity == null) {
      return null;
    }

    return CreateInventoryEntryRequest(
      coffeeLotId: selectedLot.lot.id,
      quantityUsed: quantity,
      dateUsed: _selectedDate,
      finalProduct: finalProduct,
    );
  }

  Future<void> _submit() async {
    final request = _validateForm();
    setState(() {
      _submitError = null;
    });

    if (request == null) {
      setState(() {});
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final errorMessage = await widget.onSubmit(request);
    if (!mounted) {
      return;
    }

    if (errorMessage == null) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isSubmitting = false;
      _submitError = errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedLot = _selectedLot;
    final projectedRemainingStock = _projectedRemainingStock;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Registrar consumo',
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E4234),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _FormFieldLabel(
                  label: 'Fecha de consumo',
                  errorText: _fieldErrors['date'],
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: _isSubmitting ? null : _pickDate,
                  borderRadius: BorderRadius.circular(18),
                  child: InputDecorator(
                    decoration: inventoryRoundedFieldDecoration(
                      'Fecha de consumo',
                      suffixIcon: const Icon(Icons.calendar_today_outlined),
                    ),
                    child: Text(
                      formatInventoryDate(_selectedDate),
                      style: const TextStyle(
                        color: Color(0xFF2E2E2E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                _FormFieldLabel(
                  label: 'Lote',
                  errorText: _fieldErrors['lot'],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: _selectedLotId,
                  items: widget.lots
                      .map(
                        (lot) => DropdownMenuItem<int>(
                          value: lot.lot.id,
                          child: Text(
                            '${lot.lot.lotName} - ${lot.lot.coffeeType}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: _isSubmitting
                      ? null
                      : (value) {
                          setState(() {
                            _selectedLotId = value;
                          });
                        },
                  decoration: inventoryRoundedFieldDecoration('Lote'),
                  icon: const Icon(Icons.keyboard_arrow_down_rounded),
                  borderRadius: BorderRadius.circular(18),
                  dropdownColor: Colors.white,
                ),
                const SizedBox(height: 14),
                _InventoryTextField(
                  label: 'Producto final',
                  controller: _finalProductController,
                  enabled: !_isSubmitting,
                  errorText: _fieldErrors['finalProduct'],
                ),
                const SizedBox(height: 14),
                _InventoryTextField(
                  label: 'Cantidad usada (kg)',
                  controller: _quantityController,
                  enabled: !_isSubmitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _fieldErrors['quantity'],
                ),
                const SizedBox(height: 18),
                const Text(
                  'Resumen de lote',
                  style: TextStyle(
                    color: Color(0xFF2E2E2E),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF73A3A0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: selectedLot == null
                      ? const Text(
                          'Selecciona un lote para ver su resumen.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SummaryInfoRow(
                              label: 'Tipo de cafe',
                              value: selectedLot.lot.coffeeType,
                            ),
                            _SummaryInfoRow(
                              label: 'Lote',
                              value: selectedLot.lot.lotName,
                            ),
                            _SummaryInfoRow(
                              label: 'Origen',
                              value: selectedLot.lot.origin,
                            ),
                            _SummaryInfoRow(
                              label: 'Stock disponible (kg)',
                              value: formatInventoryWeight(
                                selectedLot.currentStock,
                              ),
                            ),
                            _SummaryInfoRow(
                              label: 'Stock restante (kg)',
                              value: projectedRemainingStock == null
                                  ? 'N/A'
                                  : formatInventoryWeight(
                                      projectedRemainingStock,
                                    ),
                            ),
                            const _SummaryInfoRow(
                              label: 'Fecha de entrada',
                              value: 'N/A',
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'Movimientos anteriores',
                  style: TextStyle(
                    color: Color(0xFF2E2E2E),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6F9B98),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: _previousMovements.isEmpty
                      ? const Text(
                          'No hay movimientos previos para este lote.',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _previousMovements.take(4).map((record) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                '${formatInventoryDate(record.entry.dateUsed)} - '
                                '${formatInventoryWeight(record.entry.quantityUsed)} kg '
                                '${record.entry.finalProduct}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                  height: 1.25,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                ),
                if (_submitError != null) ...[
                  const SizedBox(height: 14),
                  InventoryMessageBanner(
                    message: _submitError!,
                    backgroundColor: const Color(0xFFF8D9D9),
                    foregroundColor: const Color(0xFF8C1D1D),
                  ),
                ],
                const SizedBox(height: 22),
                AuthPrimaryButton(
                  label: 'Registrar consumo',
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FormFieldLabel extends StatelessWidget {
  const _FormFieldLabel({
    required this.label,
    this.errorText,
  });

  final String label;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E2E2E),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFFB3261E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _InventoryTextField extends StatelessWidget {
  const _InventoryTextField({
    required this.label,
    required this.controller,
    this.enabled = true,
    this.keyboardType,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E2E2E),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          decoration: inventoryRoundedFieldDecoration(label),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFFB3261E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _SummaryInfoRow extends StatelessWidget {
  const _SummaryInfoRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              '$label:',
              style: const TextStyle(
                color: Color(0xFF173332),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
