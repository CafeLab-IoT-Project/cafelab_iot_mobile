import 'package:cafelab_iot_mobile/features/cost_management/domain/models/production_cost_record.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/constants/cost_management_colors.dart';
import 'package:flutter/material.dart';

const _reasonMaxLength = 25;

const _predefinedReasons = [
  'Datos erróneos',
  'Lote equivocado',
  'Registro duplicado',
  'Costos incompletos',
  'Cancelación operativa',
  'Proveedor no disponible',
  'Error de cálculo',
  'Error de transporte',
];

class CostRecordAnnulDialog extends StatefulWidget {
  const CostRecordAnnulDialog({super.key, required this.record});

  final ProductionCostRecord record;

  @override
  State<CostRecordAnnulDialog> createState() => _CostRecordAnnulDialogState();
}

class _CostRecordAnnulDialogState extends State<CostRecordAnnulDialog> {
  String? _selectedReason;
  final _customReasonController = TextEditingController();
  String? _error;

  bool get _isOtherSelected => _selectedReason == '__OTHER__';

  @override
  void dispose() {
    _customReasonController.dispose();
    super.dispose();
  }

  String? _resolveReason() {
    if (_selectedReason == null || _selectedReason!.isEmpty) return null;
    if (!_isOtherSelected) return _selectedReason;
    final custom = _customReasonController.text.trim();
    if (custom.isEmpty) return null;
    return custom.length > _reasonMaxLength
        ? custom.substring(0, _reasonMaxLength)
        : custom;
  }

  void _confirm() {
    final reason = _resolveReason();
    if (reason == null) {
      setState(() => _error = 'Selecciona o escribe un motivo de anulación.');
      return;
    }
    Navigator.of(context).pop(reason);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Anular registro'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF4E5),
                border: const Border(
                  left: BorderSide(color: Color(0xFFF59E0B), width: 4),
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Esta acción marcará el registro como anulado. No se eliminará del historial.',
                style: TextStyle(color: Color(0xFF8A4B00)),
              ),
            ),
            const SizedBox(height: 12),
            Text('Lote: ${widget.record.lotName}'),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Motivo de anulación',
                border: OutlineInputBorder(),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedReason,
                  hint: const Text('Selecciona un motivo'),
                  items: [
                    ..._predefinedReasons.map(
                      (reason) => DropdownMenuItem(
                        value: reason,
                        child: Text(reason),
                      ),
                    ),
                    const DropdownMenuItem(
                      value: '__OTHER__',
                      child: Text('Otro'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedReason = value;
                      _error = null;
                    });
                  },
                ),
              ),
            ),
            if (_isOtherSelected) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _customReasonController,
                maxLength: _reasonMaxLength,
                decoration: const InputDecoration(
                  labelText: 'Motivo personalizado',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => setState(() => _error = null),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: CostManagementColors.annulConfirmRed,
          ),
          onPressed: _confirm,
          child: const Text('Confirmar anulación'),
        ),
      ],
    );
  }
}
