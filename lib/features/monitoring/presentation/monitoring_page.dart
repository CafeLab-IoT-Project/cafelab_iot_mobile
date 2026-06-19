import 'dart:async';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/edit_profile_session_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_scaffold.dart';
import 'package:cafelab_iot_mobile/features/monitoring/domain/models/environment_threshold.dart';
import 'package:cafelab_iot_mobile/features/monitoring/domain/models/telemetry_record.dart';
import 'package:cafelab_iot_mobile/features/monitoring/presentation/monitoring_page_controller.dart';
import 'package:cafelab_iot_mobile/features/monitoring/presentation/widgets/monitoring_alerts_view.dart';
import 'package:cafelab_iot_mobile/features/monitoring/presentation/widgets/monitoring_form_view.dart';
import 'package:cafelab_iot_mobile/features/monitoring/presentation/widgets/monitoring_trend_chart.dart';

import 'package:flutter/material.dart';

enum _MonitoringMode { dashboard, settingsMenu, adjustTemp, adjustHumidity }

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key, required this.planType, this.coffeeLotId = 1});

  final SubscriptionPlanType planType;
  final int coffeeLotId;

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _LotsSelectionPageState {} 

class _MonitoringPageState extends State<MonitoringPage> {
  final _controller = MonitoringPageController();
  _MonitoringMode _currentMode = _MonitoringMode.dashboard;
  
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _controller.loadDashboardData(widget.coffeeLotId);

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentMode == _MonitoringMode.dashboard && !_controller.isLoading) {
        _controller.loadDashboardData(widget.coffeeLotId);
      }
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel(); 
    _controller.dispose();
    super.dispose();
  }

  void _goToDashboard() => Navigator.of(context).pop();

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EditProfileSessionPage()),
    );
  }

  void _backToDashboard() {
    setState(() => _currentMode = _MonitoringMode.dashboard);
    _controller.loadDashboardData(widget.coffeeLotId);
  }

  void _goToSettingsMenu() {
    setState(() => _currentMode = _MonitoringMode.settingsMenu);
  }

  Future<void> _handleSubmit(double min, double max) async {
    final updatedThreshold = EnvironmentThreshold(
      coffeeLotId: widget.coffeeLotId,
      minTemperature: _currentMode == _MonitoringMode.adjustTemp ? min : (_controller.threshold?.minTemperature ?? 18.0),
      maxTemperature: _currentMode == _MonitoringMode.adjustTemp ? max : (_controller.threshold?.maxTemperature ?? 28.0),
      minHumidity: _currentMode == _MonitoringMode.adjustHumidity ? min : (_controller.threshold?.minHumidity ?? 40.0),
      maxHumidity: _currentMode == _MonitoringMode.adjustHumidity ? max : (_controller.threshold?.maxHumidity ?? 70.0),
    );

    final success = await _controller.saveThreshold(widget.coffeeLotId, updatedThreshold);
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Configuración ambiental guardada correctamente.')),
      );
      _backToDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedScaffold(
      onFeatures: _goToDashboard,
      onProfile: _openProfile,
      body: ColoredBox(
        color: AuthColors.profileScreenBackground,
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (_, __) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: _buildBreadcrumb(),
                  ),
                  if (_controller.errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        color: const Color(0xFFFFEBEE),
                        child: Text(_controller.errorMessage!, style: const TextStyle(color: Color(0xFFC62828))),
                      ),
                    ),
                  Expanded(
                    child: _controller.isLoading && _controller.latestTelemetry == null
                        ? const Center(child: CircularProgressIndicator(color: Colors.brown))
                        : SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                            child: _buildCurrentView(),
                          ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBreadcrumb() {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      children: [
        GestureDetector(
          onTap: _goToDashboard,
          child: const Text('Inicio', style: TextStyle(decoration: TextDecoration.underline, color: Colors.black87)),
        ),
        const Text('>', style: TextStyle(color: Colors.black54)),
        if (_currentMode != _MonitoringMode.dashboard)
          GestureDetector(
            onTap: _backToDashboard,
            child: const Text('Monitoreo Lote', style: TextStyle(decoration: TextDecoration.underline, color: Colors.black87)),
          )
        else
          const Text('Monitoreo Lote', style: TextStyle(color: Colors.black87)),
        if (_currentMode == _MonitoringMode.settingsMenu) ...[
          const Text('>', style: TextStyle(color: Colors.black54)),
          const Text('Configuración', style: TextStyle(color: Colors.black87)),
        ],
        if (_currentMode == _MonitoringMode.adjustTemp) ...[
          const Text('>', style: TextStyle(color: Colors.black54)),
          GestureDetector(
            onTap: _goToSettingsMenu,
            child: const Text('Configuración', style: TextStyle(decoration: TextDecoration.underline, color: Colors.black87)),
          ),
          const Text('>', style: TextStyle(color: Colors.black54)),
          const Text('Temperatura', style: TextStyle(color: Colors.black87)),
        ],
        if (_currentMode == _MonitoringMode.adjustHumidity) ...[
          const Text('>', style: TextStyle(color: Colors.black54)),
          GestureDetector(
            onTap: _goToSettingsMenu,
            child: const Text('Configuración', style: TextStyle(decoration: TextDecoration.underline, color: Colors.black87)),
          ),
          const Text('>', style: TextStyle(color: Colors.black54)),
          const Text('Humedad', style: TextStyle(color: Colors.black87)),
        ],
      ],
    );
  }

  Widget _buildCurrentView() {
    switch (_currentMode) {
      case _MonitoringMode.dashboard:
        final t = _controller.latestTelemetry;
        final allHistory = _controller.telemetryHistory;
        final List<TelemetryRecord> historyData = allHistory.length > 10 
            ? allHistory.sublist(allHistory.length - 10) 
            : allHistory;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Monitoreo Ambiental Lote #${widget.coffeeLotId}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown)),
            const SizedBox(height: 16),
            
            _buildMetricCard(
              'Temperatura Actual', 
              t != null ? '${t.temperature.toStringAsFixed(1)}°C' : 'Sincronizando...', 
              Icons.thermostat, 
              Colors.orange
            ),
            const SizedBox(height: 12),
            _buildMetricCard(
              'Humedad Relativa Actual', 
              t != null ? '${t.humidity.toStringAsFixed(1)}%' : 'Sincronizando...', 
              Icons.water_drop, 
              Colors.blue
            ),
            
            const SizedBox(height: 16),
            MonitoringTrendChart(telemetryRecords: historyData),
            
            const SizedBox(height: 16),
            MonitoringAlertsView(alerts: _controller.alertsHistory),
            
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _goToSettingsMenu,
              icon: const Icon(Icons.tune),
              label: const Text('Ajustar Parámetros Críticos'),
              style: FilledButton.styleFrom(backgroundColor: Colors.brown, padding: const EdgeInsets.symmetric(vertical: 14)),
            )
          ],
        );

      case _MonitoringMode.settingsMenu:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Selecciona la variable ambiental a configurar:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            _buildMenuTile('Límites de Temperatura', 'Establecer umbrales térmicos para el grano.', Icons.thermostat, Colors.orange, () {
              setState(() => _currentMode = _MonitoringMode.adjustTemp);
            }),
            const SizedBox(height: 12),
            _buildMenuTile('Límites de Humedad', 'Control seguro contra el hongo de humedad.', Icons.water_drop, Colors.blue, () {
              setState(() => _currentMode = _MonitoringMode.adjustHumidity);
            }),
          ],
        );

      case _MonitoringMode.adjustTemp:
        return MonitoringFormView(
          isHumidity: false,
          initial: _controller.threshold,
          isSubmitting: _controller.isLoading,
          onSubmit: _handleSubmit,
          onCancel: _goToSettingsMenu,
        );

      case _MonitoringMode.adjustHumidity:
        return MonitoringFormView(
          isHumidity: true,
          initial: _controller.threshold,
          isSubmitting: _controller.isLoading,
          onSubmit: _handleSubmit,
          onCancel: _goToSettingsMenu,
        );
    }
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(8), 
        border: Border.all(color: Colors.grey.shade300)
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Icon(icon, color: color, size: 30), 
                const SizedBox(width: 12), 
                Expanded(
                  child: Text(
                    label, 
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis, 
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value, 
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown)
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile(String title, String sub, IconData icon, Color color, VoidCallback onTap) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade300)),
      leading: Icon(icon, color: color, size: 32),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(sub),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}