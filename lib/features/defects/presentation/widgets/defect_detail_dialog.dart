import 'package:cafelab_iot_mobile/features/cost_management/presentation/constants/cost_management_colors.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/models/defect_model.dart';
import 'package:flutter/material.dart';

enum _DefectDetailPanel { main, causes, solutions }

class DefectDetailDialog extends StatefulWidget {
  const DefectDetailDialog({super.key, required this.defect});

  final DefectModel defect;

  @override
  State<DefectDetailDialog> createState() => _DefectDetailDialogState();
}

class _DefectDetailDialogState extends State<DefectDetailDialog> {
  _DefectDetailPanel _panel = _DefectDetailPanel.main;

  @override
  Widget build(BuildContext context) {
    final defect = widget.defect;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Detalle del defecto',
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
                padding: const EdgeInsets.all(24),
                child: switch (_panel) {
                  _DefectDetailPanel.main => _MainPanel(
                      defect: defect,
                      onCauses: () =>
                          setState(() => _panel = _DefectDetailPanel.causes),
                      onSolutions: () =>
                          setState(() => _panel = _DefectDetailPanel.solutions),
                    ),
                  _DefectDetailPanel.causes => _TextPanel(
                      title: 'Causas probables',
                      body: defect.probableCause,
                      onBack: () =>
                          setState(() => _panel = _DefectDetailPanel.main),
                    ),
                  _DefectDetailPanel.solutions => _TextPanel(
                      title: 'Soluciones sugeridas',
                      body: defect.suggestedSolution,
                      onBack: () =>
                          setState(() => _panel = _DefectDetailPanel.main),
                    ),
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: CostManagementColors.headerGreen,
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

class _MainPanel extends StatelessWidget {
  const _MainPanel({
    required this.defect,
    required this.onCauses,
    required this.onSolutions,
  });

  final DefectModel defect;
  final VoidCallback onCauses;
  final VoidCallback onSolutions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _DetailRow('Café', defect.coffeeDisplayName),
        if (defect.coffeeRegion != null)
          _DetailRow('Región', defect.coffeeRegion!),
        if (defect.coffeeVariety != null)
          _DetailRow('Variedad', defect.coffeeVariety!),
        if (defect.coffeeTotalWeight != null)
          _DetailRow('Peso total café', defect.coffeeTotalWeight.toString()),
        _DetailRow('Defecto', defect.name),
        _DetailRow('Tipo', defect.defectType),
        _DetailRow('Peso defecto', defect.defectWeight.toString()),
        _DetailRow('Porcentaje', '${defect.percentage}%'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCauses,
                icon: const Icon(Icons.chevron_left),
                label: const Text('Causas'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                onPressed: onSolutions,
                style: FilledButton.styleFrom(
                  backgroundColor: CostManagementColors.headerGreen,
                ),
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.chevron_right),
                label: const Text('Soluciones'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _TextPanel extends StatelessWidget {
  const _TextPanel({
    required this.title,
    required this.body,
    required this.onBack,
  });

  final String title;
  final String body;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.chevron_left),
            tooltip: 'Volver',
          ),
        ),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: CostManagementColors.headerGreen,
              ),
        ),
        const SizedBox(height: 12),
        Text(body),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
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
            child: Text(value, textAlign: TextAlign.end),
          ),
        ],
      ),
    );
  }
}
