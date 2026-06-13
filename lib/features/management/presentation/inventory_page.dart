import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_scaffold.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/create_inventory_entry_request.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/inventory_controller.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/models/inventory_view_models.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/widgets/inventory_common.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/widgets/inventory_consumption_detail_dialog.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/widgets/inventory_consumption_form_dialog.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/widgets/inventory_history_table.dart';
import 'package:cafelab_iot_mobile/features/management/presentation/widgets/inventory_summary_card.dart';
import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final InventoryController controller = InventoryController();

  @override
  void initState() {
    super.initState();
    controller.loadAll();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _reloadData() async {
    await controller.loadAll();
  }

  void _showActionSnackBarIfNeeded() {
    final message = controller.consumeActionMessage();
    if (!mounted || message == null || message.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openRegisterDialog() async {
    if (controller.availableLotsForRegistration.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'No hay lotes con stock disponible para registrar consumo.',
            ),
          ),
        );
      return;
    }

    final registered = await showDialog<bool>(
      context: context,
      builder: (_) => InventoryConsumptionFormDialog(
        lots: controller.availableLotsForRegistration,
        movementsForLot: controller.previousMovementsForLot,
        onSubmit: (CreateInventoryEntryRequest request) async {
          final success = await controller.registerConsumption(request);
          if (success) {
            return null;
          }
          return controller.errorMessage ??
              'No se pudo registrar el consumo.';
        },
      ),
    );

    if (registered == true) {
      _showActionSnackBarIfNeeded();
    }
  }

  Future<void> _openDetailDialog(InventoryEntryRecord record) async {
    await showDialog<void>(
      context: context,
      builder: (_) => InventoryConsumptionDetailDialog(record: record),
    );
  }

  void _goBackToFeatures() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedScaffold(
      onFeatures: _goBackToFeatures,
      body: ColoredBox(
        color: AuthColors.profileScreenBackground,
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              if (controller.isLoading && !controller.hasLoaded) {
                return const Center(
                  child: CircularProgressIndicator(color: AuthColors.primary),
                );
              }

              return RefreshIndicator(
                color: AuthColors.primary,
                onRefresh: _reloadData,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                  children: [
                    const Text(
                      'Inicio > Inventario',
                      style: TextStyle(
                        color: Color(0xFF4E5342),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Seleccione el tipo de grano.',
                      style: TextStyle(
                        color: Color(0xFF2E2E2E),
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    InventoryGrainToggle(
                      value: controller.selectedGrainType,
                      onChanged: controller.selectGrainType,
                    ),
                    const SizedBox(height: 16),
                    if (controller.isLoading)
                      const ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        child: LinearProgressIndicator(minHeight: 5),
                      ),
                    if (controller.isLoading) const SizedBox(height: 12),
                    if (controller.errorMessage != null) ...[
                      InventoryMessageBanner(
                        message: controller.errorMessage!,
                        backgroundColor: const Color(0xFFF8D9D9),
                        foregroundColor: const Color(0xFF8C1D1D),
                        onRetry: _reloadData,
                      ),
                      const SizedBox(height: 12),
                    ],
                    InventorySummaryCard(
                      grainType: controller.selectedGrainType,
                      summary: controller.summary,
                      availableCoffeeTypes: controller.availableCoffeeTypes,
                      selectedCoffeeType: controller.selectedCoffeeType,
                      onCoffeeTypeChanged: controller.selectCoffeeType,
                      onRegisterPressed: _openRegisterDialog,
                      isRegisterEnabled:
                          controller.availableLotsForRegistration.isNotEmpty,
                      isLoading: false,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Historial de consumos',
                      style: TextStyle(
                        color: Color(0xFF3E4234),
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildHistorySection(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHistorySection() {
    if (controller.errorMessage != null && !controller.hasData) {
      return const InventoryEmptyStateCard(
        title: 'No se pudo cargar el inventario',
        message: 'Intenta nuevamente en unos segundos.',
      );
    }

    if (!controller.hasLots && controller.hasLoaded) {
      return const InventoryEmptyStateCard(
        title: 'Aun no tienes lotes registrados',
        message: 'Registra lotes de cafe para visualizar stock y consumos.',
      );
    }

    if (controller.historyItems.isEmpty) {
      return const InventoryEmptyStateCard(
        title: 'Sin consumos registrados',
        message: 'Cuando registres un consumo se mostrara en este historial.',
      );
    }

    return InventoryHistoryTable(
      items: controller.historyItems,
      onView: _openDetailDialog,
    );
  }
}
