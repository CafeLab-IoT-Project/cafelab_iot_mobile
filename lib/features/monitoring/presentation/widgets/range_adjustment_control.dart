import 'package:flutter/material.dart';

class RangeAdjustmentControl extends StatelessWidget {
  const RangeAdjustmentControl({
    super.key,
    required this.title,
    required this.subtitle,
    required this.minValue,
    required this.maxValue,
    required this.unit,
    required this.onMinChanged,
    required this.onMaxChanged,
  });

  final String title;
  final String subtitle;
  final double minValue;
  final double maxValue;
  final String unit;
  final ValueChanged<double> onMinChanged;
  final ValueChanged<double> onMaxChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown)),
            Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.grey)),
            const SizedBox(height: 20),
            _buildSelectorRow(context, 'Límite Mínimo', minValue, onMinChanged),
            const Divider(height: 32),
            _buildSelectorRow(context, 'Límite Máximo', maxValue, onMaxChanged),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorRow(BuildContext context, String label, double value, ValueChanged<double> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black87)),
            Text('${value.toStringAsFixed(1)} $unit', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown)),
          ],
        ),
        Row(
          children: [
            _buildRoundButton(icon: Icons.remove, onPressed: () => onChanged(value - 0.5)),
            const SizedBox(width: 12),
            _buildRoundButton(icon: Icons.add, onPressed: () => onChanged(value + 0.5)),
          ],
        ),
      ],
    );
  }

  Widget _buildRoundButton({required IconData icon, required VoidCallback onPressed}) {
    return Material(
      color: Colors.brown.shade50,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        icon: Icon(icon, color: Colors.brown),
        onPressed: onPressed,
      ),
    );
  }
}