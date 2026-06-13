import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/edit_profile_session_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_scaffold.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/data/coffee_lots_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/coffee_lots_repository.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/coffee_lot.dart';
import 'package:cafelab_iot_mobile/features/monitoring/presentation/monitoring_page.dart';
import 'package:flutter/material.dart';

class LotsSelectionPage extends StatefulWidget {
  const LotsSelectionPage({super.key, required this.planType});

  final SubscriptionPlanType planType;

  @override
  State<LotsSelectionPage> createState() => _LotsSelectionPageState();
}

class _LotsSelectionPageState extends State<LotsSelectionPage> {
  final CoffeeLotsRepository _coffeeLotsRepository = CoffeeLotsRepositoryImpl();

  bool _isLoading = true;
  String? _errorMessage;
  List<CoffeeLot> _userLots = [];

  @override
  void initState() {
    super.initState();
    _loadUserLots();
  }

  Future<void> _loadUserLots() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final lots = await _coffeeLotsRepository.getByProfileId();
      setState(() => _userLots = lots);
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToDashboard() => Navigator.of(context).pop();

  void _openProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const EditProfileSessionPage()),
    );
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _goToDashboard,
                      child: const Text('Inicio', style: TextStyle(decoration: TextDecoration.underline, color: Colors.black87)),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4),
                      child: Text('>', style: TextStyle(color: Colors.black54)),
                    ),
                    const Text('Selección de Lote IoT', style: TextStyle(color: Colors.black87)),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text(
                  'Panel de Monitoreo IoT',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.brown),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Selecciona uno de tus lotes de café activos para configurar sus parámetros de control ambiental o visualizar lecturas en vivo.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.brown))
                    : _errorMessage != null
                        ? Center(child: Text('Error al cargar lotes: $_errorMessage', style: const TextStyle(color: Colors.red)))
                        : _userLots.isEmpty
                            ? const Center(child: Text('No tienes lotes registrados en producción.'))
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                itemCount: _userLots.length,
                                itemBuilder: (context, index) {
                                  final lot = _userLots[index];
                                  return _buildLotItemTile(lot);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLotItemTile(CoffeeLot lot) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: Colors.brown.shade50,
          child: const Icon(Icons.inventory_2, color: Colors.brown),
        ),
        title: Text(lot.lotName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Tipo: ${lot.coffeeType} | Método: ${lot.processingMethod}'),
            Text('Estado de producción: ${lot.status}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MonitoringPage(
                planType: widget.planType,
                coffeeLotId: lot.id,
              ),
            ),
          );
        },
      ),
    );
  }
}