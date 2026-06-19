import 'package:flutter/material.dart';
import 'package:cafelab_iot_mobile/features/monitoring/domain/models/monitoring_alert.dart';

class MonitoringAlertsView extends StatelessWidget {
  final List<MonitoringAlert> alerts;

  const MonitoringAlertsView({Key? key, required this.alerts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            "No se registran alertas ambientales en este lote.",
            style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 4.0),
          child: Text(
            "Historial de Alertas Críticas",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF4A2C11)),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: alerts.length > 5 ? 5 : alerts.length,
          itemBuilder: (context, index) {
            final alert = alerts[index];
            final isTemp = alert.metricType == "TEMPERATURE";

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              color: isTemp ? Colors.orange.shade50 : Colors.blue.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: isTemp ? Colors.orange.shade200 : Colors.blue.shade200),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isTemp ? Colors.orange : Colors.blue,
                  child: Icon(isTemp ? Icons.thermostat : Icons.water_drop, color: Colors.white),
                ),
                title: Text(
                  isTemp ? "Infracción de Temperatura" : "Infracción de Humedad",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4A2C11)),
                ),
                subtitle: Text(
                  "Valor: ${alert.currentValue} (Límite: ${alert.thresholdViolated})",
                  style: TextStyle(color: Colors.grey.shade800),
                ),
                trailing: Text(
                  "${alert.createdAt.hour}:${alert.createdAt.minute.toString().padLeft(2, '0')}",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}