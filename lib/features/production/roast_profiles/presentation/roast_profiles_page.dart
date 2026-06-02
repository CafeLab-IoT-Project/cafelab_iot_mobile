import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_scaffold.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/roast_profile.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/roast_profiles_controller.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/widgets/roast_profile_comparison_page.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/widgets/roast_profile_detail_dialog.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/widgets/roast_profile_form_dialog.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/widgets/roast_profiles_common.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/widgets/roast_profiles_table.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/widgets/roast_profiles_toolbar.dart';
import 'package:flutter/material.dart';

class RoastProfilesPage extends StatefulWidget {
  const RoastProfilesPage({super.key});

  @override
  State<RoastProfilesPage> createState() => _RoastProfilesPageState();
}

class _RoastProfilesPageState extends State<RoastProfilesPage> {
  final RoastProfilesController controller = RoastProfilesController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalTableController = ScrollController();
  final ScrollController _verticalTableController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    controller.loadAll();
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

  Future<void> _reloadProfiles() async {
    await controller.loadAll();
  }

  void _showSuccessSnackBarIfNeeded() {
    final message = controller.consumeActionMessage();
    if (!mounted || message == null || message.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _showMissingLotsSnackBar() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'Registra tu primer lote de cafe para crear un perfil de tueste',
          ),
        ),
      );
  }

  Future<void> _openCreateDialog() async {
    if (!controller.hasCoffeeLots) {
      _showMissingLotsSnackBar();
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => RoastProfileFormDialog(
        coffeeLots: controller.coffeeLots,
        title: 'Nuevo perfil de tueste',
        submitLabel: 'Registrar perfil de tueste',
        onSubmit: (value) async {
          final success = await controller.create(value.toCreateInput());
          if (success) {
            _showSuccessSnackBarIfNeeded();
            return null;
          }
          return controller.errorMessage ??
              'No se pudo registrar el perfil de tueste.';
        },
      ),
    );
  }

  Future<void> _openEditDialog(RoastProfile profile) async {
    await showDialog<void>(
      context: context,
      builder: (_) => RoastProfileFormDialog(
        profile: profile,
        coffeeLots: controller.coffeeLots,
        title: 'Editar perfil de tueste',
        submitLabel: 'Guardar perfil de tueste',
        onSubmit: (value) async {
          final success = await controller.update(
            profile.id,
            value.toUpdateInput(),
          );
          if (success) {
            _showSuccessSnackBarIfNeeded();
            return null;
          }
          return controller.errorMessage ??
              'No se pudo actualizar el perfil de tueste.';
        },
      ),
    );
  }

  Future<void> _openDetailDialog(RoastProfile profile) async {
    controller.selectProfile(profile);

    await showDialog<void>(
      context: context,
      builder: (_) => RoastProfileDetailDialog(
        profile: profile,
        lotLabel: controller.lotLabelFor(profile.coffeeLotId),
      ),
    );
  }

  Future<void> _confirmDelete(RoastProfile profile) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar perfil de tueste'),
        content: Text('Deseas eliminar ${profile.name}?'),
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

    final success = await controller.delete(profile.id);
    if (success) {
      _showSuccessSnackBarIfNeeded();
    }
  }

  Future<void> _toggleFavorite(RoastProfile profile) async {
    final success = await controller.toggleFavorite(profile);
    if (success) {
      _showSuccessSnackBarIfNeeded();
    }
  }

  Future<void> _openComparisonPage({
    RoastProfile? primary,
  }) async {
    final items = controller.items;
    if (items.length < 2) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Necesitas al menos dos perfiles para comparar.'),
          ),
        );
      return;
    }

    final left = primary ?? controller.compareLeft ?? items.first;
    final fallbackRight = items.firstWhere(
      (item) => item.id != left.id,
      orElse: () => items.last,
    );
    final right = controller.compareRight?.id == left.id
        ? fallbackRight
        : controller.compareRight ?? fallbackRight;

    controller.setComparisonProfiles(left: left, right: right);

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RoastProfileComparisonPage(
          profiles: controller.items,
          initialLeft: left,
          initialRight: right,
          controller: controller,
        ),
      ),
    );
  }

  Future<void> _openFilterSheet() async {
    String? pendingType = controller.typeFilter;
    bool pendingFavorites = controller.favoritesOnly;

    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filtrar perfiles',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3E4234),
                    ),
                  ),
                  const SizedBox(height: 18),
                  DropdownButtonFormField<String>(
                    initialValue: pendingType,
                    items: roastProfileTypeOptions
                        .map(
                          (option) => DropdownMenuItem<String>(
                            value: option,
                            child: Text(
                              option,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setModalState(() {
                        pendingType = value;
                      });
                    },
                    decoration: roundedFieldDecoration('Tipo de cafe'),
                    icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    borderRadius: BorderRadius.circular(18),
                    dropdownColor: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  SwitchListTile.adaptive(
                    value: pendingFavorites,
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Solo favoritos'),
                    activeThumbColor: AuthColors.primary,
                    onChanged: (value) {
                      setModalState(() {
                        pendingFavorites = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            controller.clearFilters();
                            Navigator.of(context).pop();
                          },
                          child: const Text('Limpiar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AuthPrimaryButton(
                          label: 'Aplicar',
                          onPressed: () {
                            controller.updateTypeFilter(pendingType);
                            controller.setFavoritesOnly(pendingFavorites);
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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
                      'Inicio > Perfiles de tueste',
                      style: TextStyle(
                        color: Color(0xFF4E5342),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    RoastProfilesToolbar(
                      searchController: _searchController,
                      isLoading: controller.isLoading,
                      canCreate: controller.hasCoffeeLots,
                      sortOldestFirst: controller.sortOldestFirst,
                      onCreatePressed: _openCreateDialog,
                      onFilterPressed: _openFilterSheet,
                      onSortPressed: controller.toggleSortOrder,
                      onComparePressed: _openComparisonPage,
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
                        onRetry: _reloadProfiles,
                      ),
                      const SizedBox(height: 12),
                    ],
                    Expanded(child: _buildContent()),
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
        title: 'No se pudieron cargar los perfiles',
        message: 'Intenta nuevamente en unos segundos.',
      );
    }

    if (!controller.hasCoffeeLots && controller.hasLoaded && !controller.hasItems) {
      return const EmptyStateCard(
        title: 'Aun no tienes lotes registrados',
        message: 'Registra tu primer lote de cafe para crear un perfil de tueste',
      );
    }

    if (!controller.hasItems && controller.hasLoaded) {
      return const EmptyStateCard(
        title: 'Aun no tienes perfiles registrados',
        message: 'Registra tu primer perfil de tueste para verlo en esta tabla.',
      );
    }

    if (controller.hasItems && controller.items.isEmpty) {
      return const EmptyStateCard(
        title: 'Sin coincidencias',
        message: 'No encontramos perfiles de tueste con ese criterio de busqueda.',
      );
    }

    return RoastProfilesTable(
      items: controller.items,
      horizontalController: _horizontalTableController,
      verticalController: _verticalTableController,
      lotLabelBuilder: controller.lotLabelFor,
      onFavorite: _toggleFavorite,
      onView: _openDetailDialog,
      onEdit: _openEditDialog,
      onCompare: (profile) => _openComparisonPage(primary: profile),
      onDelete: _confirmDelete,
    );
  }
}
