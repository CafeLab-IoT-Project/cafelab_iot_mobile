import 'package:flutter/material.dart';
import 'package:cafelab_iot_mobile/features/monitoring/domain/models/environment_threshold.dart';

class MonitoringFormView extends StatefulWidget {
  const MonitoringFormView({
    super.key,
    required this.isHumidity,
    this.initial,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onCancel,
  });

  final bool isHumidity;
  final EnvironmentThreshold? initial;
  final bool isSubmitting;
  final Future<void> Function(double min, double max) onSubmit;
  final VoidCallback onCancel;

  @override
  State<MonitoringFormView> createState() => _MonitoringFormViewState();
}

class _MonitoringFormViewState extends State<MonitoringFormView> {
  late double _currentMin;
  late double _currentMax;

  @override
  void initState() {
    super.initState();
    if (widget.isHumidity) {
      _currentMin = widget.initial?.minHumidity ?? 40.0;
      _currentMax = widget.initial?.maxHumidity ?? 70.0;
    } else {
      _currentMin = widget.initial?.minTemperature ?? 18.0;
      _currentMax = widget.initial?.maxTemperature ?? 28.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final unit = widget.isHumidity ? '%' : '°C';
    final variableName = widget.isHumidity ? 'Humedad' : 'Temperatura';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCounterRow('Límite Mínimo Seguro', _currentMin, unit, (val) => setState(() => _currentMin = val)),
        const SizedBox(height: 24),
        _buildCounterRow('Límite Máximo Seguro', _currentMax, unit, (val) => setState(() => _currentMax = val)),
        const SizedBox(height: 40),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: widget.isSubmitting ? null : widget.onCancel,
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
              child: const Text('Cancelar', style: TextStyle(color: Colors.black87)),
            ),
            const SizedBox(width: 12),
            FilledButton(
              onPressed: widget.isSubmitting ? null : () => widget.onSubmit(_currentMin, _currentMax),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32), 
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: widget.isSubmitting
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : Text('Confirmar $variableName'),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildCounterRow(String title, double value, String unit, ValueChanged<double> onChanged) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              const SizedBox(height: 4),
              Text('${value.toStringAsFixed(1)} $unit', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.brown)),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline, size: 36, color: Colors.brown),
                onPressed: () => onChanged(value - 0.5),
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, size: 36, color: Colors.brown),
                onPressed: () => onChanged(value + 0.5),
              ),
            ],
          )
        ],
      ),
    );
  }
}