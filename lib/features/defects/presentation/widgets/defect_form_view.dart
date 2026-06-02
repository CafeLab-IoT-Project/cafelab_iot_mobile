import 'package:cafelab_iot_mobile/features/cost_management/presentation/constants/cost_management_colors.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/models/create_defect_request.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DefectFormView extends StatefulWidget {
  const DefectFormView({
    super.key,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onCancel,
  });

  final bool isSubmitting;
  final Future<void> Function(CreateDefectRequest request) onSubmit;
  final VoidCallback onCancel;

  @override
  State<DefectFormView> createState() => _DefectFormViewState();
}

class _DefectFormViewState extends State<DefectFormView> {
  final _formKey = GlobalKey<FormState>();
  final _coffeeDisplayNameCtrl = TextEditingController();
  final _coffeeRegionCtrl = TextEditingController();
  final _coffeeVarietyCtrl = TextEditingController();
  final _coffeeTotalWeightCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _defectTypeCtrl = TextEditingController();
  final _defectWeightCtrl = TextEditingController();
  final _percentageCtrl = TextEditingController();
  final _probableCauseCtrl = TextEditingController();
  final _suggestedSolutionCtrl = TextEditingController();

  @override
  void dispose() {
    _coffeeDisplayNameCtrl.dispose();
    _coffeeRegionCtrl.dispose();
    _coffeeVarietyCtrl.dispose();
    _coffeeTotalWeightCtrl.dispose();
    _nameCtrl.dispose();
    _defectTypeCtrl.dispose();
    _defectWeightCtrl.dispose();
    _percentageCtrl.dispose();
    _probableCauseCtrl.dispose();
    _suggestedSolutionCtrl.dispose();
    super.dispose();
  }

  double? _parseOptionalWeight(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed.replaceAll(',', '.'));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final defectWeight =
        double.tryParse(_defectWeightCtrl.text.trim().replaceAll(',', '.'));
    final percentage =
        double.tryParse(_percentageCtrl.text.trim().replaceAll(',', '.'));

    if (defectWeight == null || defectWeight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El peso del defecto debe ser mayor que cero.'),
        ),
      );
      return;
    }

    if (percentage == null || percentage < 0 || percentage > 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El porcentaje debe estar entre 0 y 100.'),
        ),
      );
      return;
    }

    final coffeeTotalWeight = _parseOptionalWeight(_coffeeTotalWeightCtrl.text);
    if (coffeeTotalWeight != null && coffeeTotalWeight < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El peso total del café no puede ser negativo.'),
        ),
      );
      return;
    }

    await widget.onSubmit(
      CreateDefectRequest(
        coffeeDisplayName: _coffeeDisplayNameCtrl.text.trim(),
        coffeeRegion: _coffeeRegionCtrl.text.trim(),
        coffeeVariety: _coffeeVarietyCtrl.text.trim(),
        coffeeTotalWeight: coffeeTotalWeight,
        name: _nameCtrl.text.trim(),
        defectType: _defectTypeCtrl.text.trim(),
        defectWeight: defectWeight,
        percentage: percentage,
        probableCause: _probableCauseCtrl.text.trim(),
        suggestedSolution: _suggestedSolutionCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Registrar defecto',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: CostManagementColors.headerGreen,
                  fontWeight: FontWeight.w400,
                ),
          ),
          const SizedBox(height: 16),
          _FormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Datos del café',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _coffeeDisplayNameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del café *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _coffeeRegionCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Región',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _coffeeVarietyCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Variedad',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _coffeeTotalWeightCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Peso total del café (g)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _FormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Datos del defecto',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del defecto *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _defectTypeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de defecto *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _defectWeightCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Peso del defecto (g) *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _percentageCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Porcentaje (%) *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _probableCauseCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Causa probable *',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _suggestedSolutionCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Solución sugerida *',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Campo obligatorio' : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: widget.isSubmitting ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: CostManagementColors.headerGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: widget.isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Guardar'),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: widget.isSubmitting ? null : widget.onCancel,
              child: const Text('Cancelar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _FormCard extends StatelessWidget {
  const _FormCard({required this.child});

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
      child: child,
    );
  }
}
