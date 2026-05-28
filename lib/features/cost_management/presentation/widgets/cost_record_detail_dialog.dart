import 'package:cafelab_iot_mobile/features/cost_management/domain/models/production_cost_record.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/constants/cost_management_colors.dart';
import 'package:cafelab_iot_mobile/features/cost_management/presentation/widgets/cost_record_status_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CostRecordDetailDialog extends StatelessWidget {
  const CostRecordDetailDialog({super.key, required this.record});

  final ProductionCostRecord record;

  static String _formatMoney(String symbol, double value) {
    return '$symbol ${value.toStringAsFixed(2)}';
  }

  static String _formatDate(DateTime? date) {
    if (date == null) return '—';
    return DateFormat('d/M/yy, h:mm a').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final symbol = record.currencySymbol;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 560),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Detalle del registro',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: CostManagementColors.headerGreen,
                            fontWeight: FontWeight.w400,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
                child: Column(
                  children: [
                    _DetailRow(
                      label: 'Fecha',
                      value: _formatDate(record.createdAt),
                    ),
                    _DetailRow(
                      label: 'Estado',
                      valueWidget: CostRecordStatusBadge(status: record.status),
                    ),
                    if (record.isAnnulled)
                      _DetailRow(label: 'Motivo de anulación', value: record.reason),
                    _DetailRow(
                      label: 'Lote',
                      value: '${record.lotName} (${record.coffeeType})',
                    ),
                    _DetailRow(label: 'Moneda', value: record.currency),
                    _DetailRow(
                      label: 'Cantidad (kg)',
                      value: '${record.totalKg.toStringAsFixed(2)} kg',
                    ),
                    _DetailRow(
                      label: 'Margen (%)',
                      value: '${record.marginPercent.toStringAsFixed(2)}%',
                    ),
                    const _SectionTitle('Costos directos'),
                    _DetailRow(
                      label: 'Materia prima',
                      value: _formatMoney(symbol, record.rawMaterialsCost),
                    ),
                    _DetailRow(
                      label: 'Mano de obra directa',
                      value: _formatMoney(symbol, record.laborCost),
                    ),
                    _DetailRow(
                      label: 'Total directo',
                      value: _formatMoney(symbol, record.totalDirectCost),
                      emphasized: true,
                    ),
                    const _SectionTitle('Costos indirectos'),
                    _DetailRow(
                      label: 'Transporte',
                      value: _formatMoney(symbol, record.transportCost),
                    ),
                    _DetailRow(
                      label: 'Almacenamiento',
                      value: _formatMoney(symbol, record.storageCost),
                    ),
                    _DetailRow(
                      label: 'Procesamiento',
                      value: _formatMoney(symbol, record.processingCost),
                    ),
                    _DetailRow(
                      label: 'Otros',
                      value: _formatMoney(symbol, record.otherIndirectCosts),
                    ),
                    _DetailRow(
                      label: 'Total indirecto',
                      value: _formatMoney(symbol, record.totalIndirectCost),
                      emphasized: true,
                    ),
                    const _SectionTitle('Resumen'),
                    _DetailRow(
                      label: 'Costo total',
                      value: _formatMoney(symbol, record.totalCost),
                      emphasized: true,
                    ),
                    _DetailRow(
                      label: 'Costo por kg',
                      value: _formatMoney(symbol, record.costPerKg),
                    ),
                    _DetailRow(
                      label: 'Precio sugerido',
                      value: '${_formatMoney(symbol, record.suggestedPrice)}/kg',
                    ),
                    _DetailRow(
                      label: 'Margen potencial',
                      value: '${record.potentialMargin.toStringAsFixed(1)}%',
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: CostManagementColors.headerGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            color: CostManagementColors.headerGreen,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    this.value,
    this.valueWidget,
    this.emphasized = false,
  });

  final String label;
  final String? value;
  final Widget? valueWidget;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: valueWidget ??
                Text(
                  value ?? '',
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: emphasized ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
          ),
        ],
      ),
    );
  }
}
