import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cafelab_iot_mobile/features/monitoring/domain/models/telemetry_record.dart';

class MonitoringTrendChart extends StatelessWidget {
  // 🚀 Cambiado de List<dynamic> a List<TelemetryRecord> para hacer match perfecto con el controller
  final List<TelemetryRecord> telemetryRecords; 

  const MonitoringTrendChart({Key? key, required this.telemetryRecords}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (telemetryRecords.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const Text(
          "Esperando datos históricos para graficar...",
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 4.0),
          child: Text(
            "Análisis de Tendencia Temporal",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A2C11)),
          ),
        ),
        Container(
          height: 220,
          padding: const EdgeInsets.only(top: 24, right: 20, left: 10, bottom: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 35)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                // 🌡️ Línea de Temperatura
                LineChartBarData(
                  spots: telemetryRecords.asMap().entries.map((entry) {
                    // 🚀 Leemos la propiedad directamente del objeto tipado
                    return FlSpot(entry.key.toDouble(), entry.value.temperature);
                  }).toList(),
                  isCurved: true,
                  color: const Color(0xFFD27D2D),
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: const Color(0xFFD27D2D).withOpacity(0.08)),
                ),
                // 💧 Línea de Humedad
                LineChartBarData(
                  spots: telemetryRecords.asMap().entries.map((entry) {
                    // 🚀 Leemos la propiedad directamente del objeto tipado
                    return FlSpot(entry.key.toDouble(), entry.value.humidity);
                  }).toList(),
                  isCurved: true,
                  color: Colors.blue.shade400,
                  barWidth: 3,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(show: true, color: Colors.blue.withOpacity(0.08)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegend(const Color(0xFFD27D2D), "Temp (°C)"),
            const SizedBox(width: 24),
            _buildLegend(Colors.blue.shade400, "Humedad (%)"),
          ],
        ),
      ],
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}