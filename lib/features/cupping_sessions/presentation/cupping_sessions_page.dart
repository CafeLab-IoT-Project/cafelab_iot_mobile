import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_scaffold.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/cupping_session.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/cupping_session_detail_page.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/cupping_session_form_page.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/cupping_sessions_comparison_page.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/cupping_sessions_controller.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/widgets/cupping_sessions_filter_sheet.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/widgets/cupping_sessions_table.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/widgets/cupping_sessions_toolbar.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/widgets/roast_profiles_common.dart';
import 'package:flutter/material.dart';

class CuppingSessionsPage extends StatefulWidget {
  const CuppingSessionsPage({
    super.key,
    this.planType = SubscriptionPlanType.full,
  });

  final SubscriptionPlanType planType;

  @override
  State<CuppingSessionsPage> createState() => _CuppingSessionsPageState();
}

class _CuppingSessionsPageState extends State<CuppingSessionsPage> {
  final CuppingSessionsController controller = CuppingSessionsController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalTableController = ScrollController();
  final ScrollController _verticalTableController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    controller.loadSessions();
  }

  @override
  void dispose() {
    controller.dispose();
    _searchController
      ..removeListener(_handleSearchChanged)
      ..dispose();
    _horizontalTableController.dispose();
    _verticalTableController.dispose();
    super.dispose();
  }

  void _handleSearchChanged() {
    controller.updateSearchQuery(_searchController.text);
  }

  Future<void> _reloadSessions() async {
    await controller.loadSessions();
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

  Future<void> _openCreatePage() async {
    final created = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => CuppingSessionFormPage(planType: widget.planType),
      ),
    );

    if (created == true) {
      await controller.loadSessions();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Sesión de cata creada correctamente.')),
        );
    }
  }

  Future<void> _openDetailPage(CuppingSession session) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CuppingSessionDetailPage(
          sessionId: session.id,
          planType: widget.planType,
          onSessionUpdated: controller.replaceSession,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(CuppingSession session) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar sesión de cata'),
        content: Text('¿Deseas eliminar ${session.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD54545),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (shouldDelete != true) {
      return;
    }

    final success = await controller.delete(session.id);
    if (success) {
      _showActionSnackBarIfNeeded();
    }
  }

  Future<void> _toggleFavorite(CuppingSession session) async {
    final success = await controller.toggleFavorite(session);
    if (success) {
      _showActionSnackBarIfNeeded();
    }
  }

  Future<void> _openFilterSheet() async {
    final result = await showCuppingSessionsFilterSheet(
      context: context,
      initialFilter: controller.filters,
      origins: controller.availableOrigins,
      varieties: controller.availableVarieties,
      processingOptions: controller.availableProcessing,
    );
    if (result != null) {
      controller.updateFilters(result);
    }
  }

  Future<void> _openComparisonPage() async {
    if (controller.allItems.length < 2) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Necesitas al menos dos sesiones para comparar.'),
          ),
        );
      return;
    }

    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => CuppingSessionsComparisonPage(
          sessions: controller.allItems,
          planType: widget.planType,
        ),
      ),
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
              return Padding(
                padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Inicio > Sesiones de cata',
                      style: TextStyle(
                        color: Color(0xFF4E5342),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    CuppingSessionsToolbar(
                      searchController: _searchController,
                      sortOption: controller.sortOption,
                      favoritesOnly: controller.favoritesOnly,
                      isLoading: controller.isLoading,
                      onFilterPressed: _openFilterSheet,
                      onComparePressed: _openComparisonPage,
                      onSortChanged: (value) {
                        if (value != null) {
                          controller.updateSortOption(value);
                        }
                      },
                      onFavoritesChanged: controller.setFavoritesOnly,
                    ),
                    const SizedBox(height: 16),
                    if (controller.isLoading)
                      const ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        child: LinearProgressIndicator(minHeight: 5),
                      ),
                    if (controller.isLoading) const SizedBox(height: 12),
                    if (controller.errorMessage != null) ...[
                      MessageBanner(
                        message: controller.errorMessage!,
                        backgroundColor: const Color(0xFFF8D9D9),
                        foregroundColor: const Color(0xFF8C1D1D),
                        onRetry: _reloadSessions,
                      ),
                      const SizedBox(height: 12),
                    ],
                    Expanded(child: _buildContent()),
                    const SizedBox(height: 18),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 220,
                        child: AuthPrimaryButton(
                          label: 'Registrar nueva cata',
                          onPressed: controller.isLoading ? null : _openCreatePage,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (controller.isLoading && !controller.hasLoaded) {
      return const Center(
        child: CircularProgressIndicator(color: AuthColors.primary),
      );
    }

    if (controller.errorMessage != null && !controller.hasItems) {
      return const EmptyStateCard(
        title: 'No se pudieron cargar las sesiones',
        message: 'Intenta nuevamente en unos segundos.',
      );
    }

    if (!controller.hasItems && controller.hasLoaded) {
      return const EmptyStateCard(
        title: 'Aún no tienes sesiones registradas',
        message: 'Registra tu primera sesión de cata para verla en esta tabla.',
      );
    }

    if (controller.hasItems && controller.items.isEmpty) {
      return EmptyStateCard(
        title: 'Sin coincidencias',
        message: controller.filters.hasActiveFilters || controller.favoritesOnly
            ? 'No encontramos sesiones con esos filtros.'
            : 'No encontramos sesiones con ese criterio de búsqueda.',
      );
    }

    return CuppingSessionsTable(
      items: controller.items,
      horizontalController: _horizontalTableController,
      verticalController: _verticalTableController,
      onFavorite: _toggleFavorite,
      onView: _openDetailPage,
      onDelete: _confirmDelete,
    );
  }
}
