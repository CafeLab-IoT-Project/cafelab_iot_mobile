import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_scaffold.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/coffee_lot.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/create_coffee_lot_input.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/update_coffee_lot_input.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/presentation/coffee_lots_controller.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/supplier.dart';
import 'package:flutter/material.dart';

class CoffeeLotsPage extends StatefulWidget {
  const CoffeeLotsPage({super.key});

  @override
  State<CoffeeLotsPage> createState() => _CoffeeLotsPageState();
}

class _CoffeeLotsPageState extends State<CoffeeLotsPage> {
  static const double _tableWidth = 792;
  static const double _tableHeaderHeight = 56;
  static const double _tableRowHeight = 72;

  final CoffeeLotsController controller = CoffeeLotsController();
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

  Future<void> _reloadLots() async {
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

  void _showMissingSuppliersSnackBar() {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Registra tu primer proveedor para ingresar un lote'),
        ),
      );
  }

  Future<void> _openCreateDialog() async {
    if (!controller.hasSuppliers) {
      _showMissingSuppliersSnackBar();
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (_) => _CoffeeLotFormDialog(
        suppliers: controller.suppliers,
        title: 'Nuevo lote de cafe',
        submitLabel: 'Registrar lote de cafe',
        onSubmit: (value) async {
          final success = await controller.create(value.toCreateInput());
          if (success) {
            _showSuccessSnackBarIfNeeded();
            return null;
          }
          return controller.errorMessage ??
              'No se pudo registrar el lote de cafe.';
        },
      ),
    );
  }

  Future<void> _openEditDialog(CoffeeLot lot) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _CoffeeLotFormDialog(
        lot: lot,
        suppliers: controller.suppliers,
        title: 'Editar lote de cafe',
        submitLabel: 'Guardar lote de cafe',
        onSubmit: (value) async {
          final success = await controller.update(
            lot.id,
            value.toUpdateInput(),
          );
          if (success) {
            _showSuccessSnackBarIfNeeded();
            return null;
          }
          return controller.errorMessage ??
              'No se pudo actualizar el lote de cafe.';
        },
      ),
    );
  }

  Future<void> _openDetailDialog(CoffeeLot lot) async {
    controller.selectLot(lot);

    await showDialog<void>(
      context: context,
      builder: (_) => _CoffeeLotDetailDialog(
        lot: lot,
        supplierLabel: controller.supplierLabelFor(lot.supplierId),
      ),
    );
  }

  Future<void> _confirmDelete(CoffeeLot lot) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar lote de cafe'),
        content: Text('Deseas eliminar ${lot.lotName}?'),
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

    final success = await controller.delete(lot.id);
    if (success) {
      _showSuccessSnackBarIfNeeded();
    }
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
                      'Inicio > Lotes de cafe',
                      style: TextStyle(
                        color: Color(0xFF4E5342),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _CoffeeLotsToolbar(
                      searchController: _searchController,
                      isLoading: controller.isLoading,
                      canCreate: controller.hasSuppliers,
                      onCreatePressed: _openCreateDialog,
                    ),
                    const SizedBox(height: 16),
                    if (controller.isLoading)
                      const ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        child: LinearProgressIndicator(minHeight: 5),
                      ),
                    if (controller.isLoading) const SizedBox(height: 12),
                    if (controller.errorMessage != null) ...[
                      _MessageBanner(
                        message: controller.errorMessage!,
                        backgroundColor: const Color(0xFFF8D9D9),
                        foregroundColor: const Color(0xFF8C1D1D),
                        onRetry: _reloadLots,
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
      return const _EmptyStateCard(
        title: 'No se pudieron cargar los lotes',
        message: 'Intenta nuevamente en unos segundos.',
      );
    }

    if (!controller.hasSuppliers && controller.hasLoaded) {
      return const _EmptyStateCard(
        title: 'Aun no tienes proveedores registrados',
        message: 'Registra tu primer proveedor para ingresar un lote',
      );
    }

    if (!controller.hasItems && controller.hasLoaded) {
      return const _EmptyStateCard(
        title: 'Sin lotes de cafe',
        message: 'Registra tu primer lote para verlo en esta tabla.',
      );
    }

    if (controller.hasItems && controller.items.isEmpty) {
      return const _EmptyStateCard(
        title: 'Sin coincidencias',
        message: 'No encontramos lotes de cafe con ese criterio de busqueda.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemCount = controller.items.length;
        final separatorsHeight = itemCount > 0 ? itemCount - 1.0 : 0.0;
        final contentHeight =
            _tableHeaderHeight +
            (_tableRowHeight * itemCount) +
            separatorsHeight;
        final targetHeight = contentHeight.clamp(
          _tableHeaderHeight + _tableRowHeight,
          constraints.maxHeight,
        );
        final bodyHeight = targetHeight - _tableHeaderHeight;

        return Align(
          alignment: Alignment.topCenter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 18,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: SizedBox(
                height: targetHeight,
                child: Scrollbar(
                  controller: _horizontalTableController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    controller: _horizontalTableController,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: _tableWidth,
                      child: Column(
                        children: [
                          const _CoffeeLotsTableHeader(),
                          SizedBox(
                            height: bodyHeight,
                            child: Scrollbar(
                              controller: _verticalTableController,
                              thumbVisibility: itemCount > 1,
                              child: ListView.separated(
                                controller: _verticalTableController,
                                padding: EdgeInsets.zero,
                                itemCount: itemCount,
                                separatorBuilder: (_, __) => const Divider(
                                  height: 1,
                                  color: Color(0xFFDDD8D2),
                                ),
                                itemBuilder: (context, index) {
                                  final lot = controller.items[index];
                                  return _CoffeeLotRow(
                                    lot: lot,
                                    supplierLabel: controller.supplierLabelFor(
                                      lot.supplierId,
                                    ),
                                    onView: () => _openDetailDialog(lot),
                                    onEdit: () => _openEditDialog(lot),
                                    onDelete: () => _confirmDelete(lot),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CoffeeLotsToolbar extends StatelessWidget {
  const _CoffeeLotsToolbar({
    required this.searchController,
    required this.isLoading,
    required this.canCreate,
    required this.onCreatePressed,
  });

  final TextEditingController searchController;
  final bool isLoading;
  final bool canCreate;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isStacked = constraints.maxWidth < 620;
        final searchField = Expanded(
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              enabled: !isLoading,
              decoration: const InputDecoration(
                hintText: 'Buscar lote',
                prefixIcon: Icon(Icons.search_rounded),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 16,
                ),
              ),
            ),
          ),
        );

        final actionButton = SizedBox(
          width: isStacked ? double.infinity : 220,
          child: AuthPrimaryButton(
            label: 'Registrar Lote',
            onPressed: isLoading || !canCreate ? null : onCreatePressed,
          ),
        );

        if (isStacked) {
          return Column(
            children: [
              Row(children: [searchField]),
              const SizedBox(height: 12),
              actionButton,
            ],
          );
        }

        return Row(
          children: [searchField, const SizedBox(width: 14), actionButton],
        );
      },
    );
  }
}

class _CoffeeLotsTableHeader extends StatelessWidget {
  const _CoffeeLotsTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFA6C8C6),
      height: _CoffeeLotsPageState._tableHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: const Row(
        children: [
          _TableCell(label: 'Nombre', width: 170, isHeader: true),
          _TableCell(label: 'Tipo', width: 150, isHeader: true),
          _TableCell(label: 'Altitud', width: 120, isHeader: true),
          _TableCell(label: 'Proveedor', width: 170, isHeader: true),
          _TableCell(label: 'Acciones', width: 150, isHeader: true),
        ],
      ),
    );
  }
}

class _CoffeeLotRow extends StatelessWidget {
  const _CoffeeLotRow({
    required this.lot,
    required this.supplierLabel,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final CoffeeLot lot;
  final String supplierLabel;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onView,
        child: SizedBox(
          height: _CoffeeLotsPageState._tableRowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _TableCell(label: lot.lotName, width: 170),
                _TableCell(label: lot.coffeeType, width: 150),
                _TableCell(label: '${lot.altitude} msnm', width: 120),
                _TableCell(label: supplierLabel, width: 170),
                SizedBox(
                  width: 150,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ActionIconButton(
                        icon: Icons.visibility_outlined,
                        tooltip: 'Ver detalle',
                        onPressed: onView,
                      ),
                      _ActionIconButton(
                        icon: Icons.edit_outlined,
                        tooltip: 'Editar lote',
                        onPressed: onEdit,
                      ),
                      _ActionIconButton(
                        icon: Icons.delete_outline,
                        tooltip: 'Eliminar lote',
                        color: const Color(0xFFB83C3C),
                        onPressed: onDelete,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell({
    required this.label,
    required this.width,
    this.isHeader = false,
  });

  final String label;
  final double width;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Text(
        label,
        maxLines: isHeader ? 1 : 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isHeader ? Colors.white : const Color(0xFF3E4234),
          fontWeight: isHeader ? FontWeight.w700 : FontWeight.w500,
          fontSize: isHeader ? 15 : 14,
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.color = const Color(0xFF3E4234),
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      splashRadius: 20,
      tooltip: tooltip,
      icon: Icon(icon, color: color, size: 22),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({
    required this.message,
    required this.backgroundColor,
    required this.foregroundColor,
    this.onRetry,
  });

  final String message;
  final Color backgroundColor;
  final Color foregroundColor;
  final Future<void> Function()? onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: foregroundColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: foregroundColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.coffee_outlined,
              size: 42,
              color: AuthColors.primary,
            ),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3E4234),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF5D5D5D),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CoffeeLotDetailDialog extends StatelessWidget {
  const _CoffeeLotDetailDialog({
    required this.lot,
    required this.supplierLabel,
  });

  final CoffeeLot lot;
  final String supplierLabel;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 370),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 10),
              child: Text(
                'Lotes de cafe > ${lot.lotName}',
                style: const TextStyle(
                  color: Color(0xFF4E5342),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33000000),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Detalles',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3E4234),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(label: 'Nombre', value: lot.lotName),
                    _DetailRow(label: 'Tipo de cafe', value: lot.coffeeType),
                    _DetailRow(label: 'Proceso', value: lot.processingMethod),
                    _DetailRow(label: 'Origen', value: lot.origin),
                    _DetailRow(label: 'Altitud', value: '${lot.altitude} msnm'),
                    _DetailRow(label: 'Proveedor', value: supplierLabel),
                    _DetailRow(
                      label: 'Peso',
                      value: '${_formatWeight(lot.weight)} kg',
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Certificaciones',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E4234),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: lot.certifications.isEmpty
                          ? const [_TagChip(label: 'Sin certificaciones')]
                          : lot.certifications
                                .map((item) => _TagChip(label: item))
                                .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 98,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Color(0xFF3E4234),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF494949), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F2EF),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD6D1CA)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF5B5B5B),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _CoffeeLotFormDialog extends StatefulWidget {
  const _CoffeeLotFormDialog({
    required this.suppliers,
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    this.lot,
  });

  final CoffeeLot? lot;
  final List<Supplier> suppliers;
  final String title;
  final String submitLabel;
  final Future<String?> Function(_CoffeeLotFormValue value) onSubmit;

  @override
  State<_CoffeeLotFormDialog> createState() => _CoffeeLotFormDialogState();
}

class _CoffeeLotFormDialogState extends State<_CoffeeLotFormDialog> {
  static const List<String> _coffeeTypeOptions = <String>[
    'Arábica',
    'Robusta',
    'Mezcla',
  ];
  static const List<String> _processingMethodOptions = <String>[
    'Lavado',
    'Honey',
  ];

  late final TextEditingController _nameController;
  late final TextEditingController _originController;
  late final TextEditingController _altitudeController;
  late final TextEditingController _weightController;
  late final List<TextEditingController> _certificationControllers;
  int? _selectedSupplierId;
  String? _selectedCoffeeType;
  String? _selectedProcessingMethod;
  final Map<String, String> _fieldErrors = <String, String>{};
  String? _submitError;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final lot = widget.lot;
    _nameController = TextEditingController(text: lot?.lotName ?? '');
    _selectedCoffeeType = _resolveDropdownValue(
      currentValue: lot?.coffeeType,
      allowedValues: _coffeeTypeOptions,
    );
    _selectedProcessingMethod = _resolveDropdownValue(
      currentValue: lot?.processingMethod,
      allowedValues: _processingMethodOptions,
    );
    _originController = TextEditingController(text: lot?.origin ?? '');
    _altitudeController = TextEditingController(
      text: lot?.altitude.toString() ?? '',
    );
    _weightController = TextEditingController(
      text: lot == null ? '' : _formatWeight(lot.weight),
    );
    _selectedSupplierId = lot?.supplierId;
    final certifications = lot?.certifications ?? const <String>[];
    _certificationControllers = certifications.isEmpty
        ? <TextEditingController>[TextEditingController()]
        : certifications
              .map((item) => TextEditingController(text: item))
              .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originController.dispose();
    _altitudeController.dispose();
    _weightController.dispose();
    for (final controller in _certificationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addCertificationField() {
    setState(() {
      _certificationControllers.add(TextEditingController());
    });
  }

  void _removeCertificationField(int index) {
    if (_certificationControllers.length == 1) {
      _certificationControllers.first.clear();
      return;
    }

    setState(() {
      final controller = _certificationControllers.removeAt(index);
      controller.dispose();
    });
  }

  _CoffeeLotFormValue? _validateForm() {
    _fieldErrors.clear();

    final altitudeText = _altitudeController.text.trim();
    final weightText = _weightController.text.trim();
    final altitude = int.tryParse(altitudeText);
    final weight = double.tryParse(weightText);

    if (_nameController.text.trim().isEmpty) {
      _fieldErrors['name'] = 'Ingresa el nombre del lote.';
    }
    if (_selectedCoffeeType == null || _selectedCoffeeType!.isEmpty) {
      _fieldErrors['type'] = 'Selecciona el tipo de cafe.';
    }
    if (_selectedProcessingMethod == null ||
        _selectedProcessingMethod!.isEmpty) {
      _fieldErrors['process'] = 'Selecciona el proceso.';
    }
    if (_originController.text.trim().isEmpty) {
      _fieldErrors['origin'] = 'Ingresa el origen.';
    }
    if (altitudeText.isEmpty) {
      _fieldErrors['altitude'] = 'Ingresa la altitud.';
    } else if (altitude == null || altitude <= 0) {
      _fieldErrors['altitude'] = 'Ingresa una altitud numerica valida.';
    }
    if (weightText.isEmpty) {
      _fieldErrors['weight'] = 'Ingresa el peso.';
    } else if (weight == null || weight <= 0) {
      _fieldErrors['weight'] = 'Ingresa un peso numerico valido.';
    }
    if (_selectedSupplierId == null || _selectedSupplierId! <= 0) {
      _fieldErrors['supplier'] = 'Selecciona un proveedor.';
    }

    if (_fieldErrors.isNotEmpty || altitude == null || weight == null) {
      return null;
    }

    final certifications = _certificationControllers
        .map((controller) => controller.text.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    return _CoffeeLotFormValue(
      supplierId: _selectedSupplierId!,
      lotName: _nameController.text.trim(),
      coffeeType: _selectedCoffeeType!,
      processingMethod: _selectedProcessingMethod!,
      altitude: altitude,
      weight: weight,
      origin: _originController.text.trim(),
      certifications: certifications,
      status: widget.lot?.status ?? 'green',
    );
  }

  Future<void> _submit() async {
    final value = _validateForm();
    if (value == null) {
      setState(() {
        _submitError = null;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
    });

    final errorMessage = await widget.onSubmit(value);
    if (!mounted) {
      return;
    }

    if (errorMessage == null) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _isSubmitting = false;
      _submitError = errorMessage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(26),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: _isSubmitting
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 18,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E4234),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    'Informacion del Lote',
                    style: TextStyle(
                      color: Color(0xFF575757),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _CoffeeLotInputField(
                  label: 'Nombre',
                  controller: _nameController,
                  enabled: !_isSubmitting,
                  errorText: _fieldErrors['name'],
                ),
                const SizedBox(height: 14),
                _CoffeeLotSelectField(
                  label: 'Tipo de cafe',
                  value: _selectedCoffeeType,
                  options: _coffeeTypeOptions,
                  enabled: !_isSubmitting,
                  onChanged: (value) {
                    setState(() {
                      _selectedCoffeeType = value;
                    });
                  },
                  errorText: _fieldErrors['type'],
                ),
                const SizedBox(height: 14),
                _CoffeeLotSelectField(
                  label: 'Proceso',
                  value: _selectedProcessingMethod,
                  options: _processingMethodOptions,
                  enabled: !_isSubmitting,
                  onChanged: (value) {
                    setState(() {
                      _selectedProcessingMethod = value;
                    });
                  },
                  errorText: _fieldErrors['process'],
                ),
                const SizedBox(height: 14),
                _CoffeeLotInputField(
                  label: 'Origen',
                  controller: _originController,
                  enabled: !_isSubmitting,
                  errorText: _fieldErrors['origin'],
                ),
                const SizedBox(height: 14),
                _CoffeeLotInputField(
                  label: 'Altitud (msnm)',
                  controller: _altitudeController,
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.number,
                  errorText: _fieldErrors['altitude'],
                ),
                const SizedBox(height: 14),
                _CoffeeLotInputField(
                  label: 'Peso (kg)',
                  controller: _weightController,
                  enabled: !_isSubmitting,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  errorText: _fieldErrors['weight'],
                ),
                const SizedBox(height: 14),
                _CoffeeLotSupplierField(
                  label: 'Proveedor',
                  suppliers: widget.suppliers,
                  value: _selectedSupplierId,
                  enabled: !_isSubmitting,
                  isEditable: widget.lot == null,
                  onChanged: (value) {
                    setState(() {
                      _selectedSupplierId = value;
                    });
                  },
                  errorText: _fieldErrors['supplier'],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Certificaciones',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 10),
                ...List<Widget>.generate(
                  _certificationControllers.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index == _certificationControllers.length - 1
                          ? 10
                          : 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _CoffeeLotRoundedField(
                            controller: _certificationControllers[index],
                            enabled: !_isSubmitting,
                            hintText: 'Certificacion ${index + 1}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _isSubmitting
                              ? null
                              : () => _removeCertificationField(index),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E3DD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _certificationControllers.length == 1
                                  ? Icons.clear_rounded
                                  : Icons.remove_rounded,
                              color: AuthColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: _isSubmitting ? null : _addCertificationField,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    height: 34,
                    width: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0DBD6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.add, color: AuthColors.primary),
                  ),
                ),
                if (_submitError != null) ...[
                  const SizedBox(height: 14),
                  _MessageBanner(
                    message: _submitError!,
                    backgroundColor: const Color(0xFFF8D9D9),
                    foregroundColor: const Color(0xFF8C1D1D),
                  ),
                ],
                const SizedBox(height: 22),
                AuthPrimaryButton(
                  label: widget.submitLabel,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CoffeeLotSupplierField extends StatelessWidget {
  const _CoffeeLotSupplierField({
    required this.label,
    required this.suppliers,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.isEditable = true,
    this.errorText,
  });

  final String label;
  final List<Supplier> suppliers;
  final int? value;
  final ValueChanged<int?> onChanged;
  final bool enabled;
  final bool isEditable;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final selectedSupplier = suppliers.cast<Supplier?>().firstWhere(
      (supplier) => supplier?.id == value,
      orElse: () => null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E2E2E),
          ),
        ),
        const SizedBox(height: 8),
        if (isEditable)
          DropdownButtonFormField<int>(
            initialValue: value,
            items: suppliers
                .map(
                  (supplier) => DropdownMenuItem<int>(
                    value: supplier.id,
                    child: Text(supplier.name, overflow: TextOverflow.ellipsis),
                  ),
                )
                .toList(),
            onChanged: enabled ? onChanged : null,
            decoration: _roundedFieldDecoration(label),
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            borderRadius: BorderRadius.circular(18),
            dropdownColor: Colors.white,
          )
        else
          InputDecorator(
            decoration: _roundedFieldDecoration(label),
            child: Text(
              selectedSupplier?.name ?? 'Proveedor no disponible',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFFB3261E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _CoffeeLotSelectField extends StatelessWidget {
  const _CoffeeLotSelectField({
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.errorText,
  });

  final String label;
  final List<String> options;
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E2E2E),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          items: options
              .map(
                (option) => DropdownMenuItem<String>(
                  value: option,
                  child: Text(option, overflow: TextOverflow.ellipsis),
                ),
              )
              .toList(),
          onChanged: enabled ? onChanged : null,
          decoration: _roundedFieldDecoration(label),
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          borderRadius: BorderRadius.circular(18),
          dropdownColor: Colors.white,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFFB3261E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _CoffeeLotInputField extends StatelessWidget {
  const _CoffeeLotInputField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.enabled = true,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2E2E2E),
          ),
        ),
        const SizedBox(height: 8),
        _CoffeeLotRoundedField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          hintText: label,
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(
              color: Color(0xFFB3261E),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _CoffeeLotRoundedField extends StatelessWidget {
  const _CoffeeLotRoundedField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.enabled = true,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      decoration: _roundedFieldDecoration(hintText),
    );
  }
}

class _CoffeeLotFormValue {
  const _CoffeeLotFormValue({
    required this.supplierId,
    required this.lotName,
    required this.coffeeType,
    required this.processingMethod,
    required this.altitude,
    required this.weight,
    required this.origin,
    required this.certifications,
    required this.status,
  });

  final int supplierId;
  final String lotName;
  final String coffeeType;
  final String processingMethod;
  final int altitude;
  final double weight;
  final String origin;
  final List<String> certifications;
  final String status;

  CreateCoffeeLotInput toCreateInput() {
    return CreateCoffeeLotInput(
      supplierId: supplierId,
      lotName: lotName,
      coffeeType: coffeeType,
      processingMethod: processingMethod,
      altitude: altitude,
      weight: weight,
      origin: origin,
      status: status,
      certifications: certifications,
    );
  }

  UpdateCoffeeLotInput toUpdateInput() {
    return UpdateCoffeeLotInput(
      lotName: lotName,
      coffeeType: coffeeType,
      processingMethod: processingMethod,
      altitude: altitude,
      weight: weight,
      origin: origin,
      status: status,
      certifications: certifications,
    );
  }
}

String _formatWeight(double weight) {
  if (weight == weight.roundToDouble()) {
    return weight.toStringAsFixed(0);
  }

  return weight
      .toStringAsFixed(2)
      .replaceFirst(RegExp(r'0+$'), '')
      .replaceFirst(RegExp(r'\.$'), '');
}

String? _resolveDropdownValue({
  required String? currentValue,
  required List<String> allowedValues,
}) {
  if (currentValue == null || currentValue.isEmpty) {
    return null;
  }

  final exactMatch = allowedValues.where((value) => value == currentValue);
  if (exactMatch.isNotEmpty) {
    return exactMatch.first;
  }

  final normalizedCurrent = currentValue.toLowerCase();
  final normalizedMatch = allowedValues.where(
    (value) => value.toLowerCase() == normalizedCurrent,
  );
  if (normalizedMatch.isNotEmpty) {
    return normalizedMatch.first;
  }

  return null;
}

InputDecoration _roundedFieldDecoration(String hintText) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: const TextStyle(color: Color(0xFF9A958F)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFD7D1C9)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: Color(0xFFD7D1C9)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: const BorderSide(color: AuthColors.primary, width: 1.4),
    ),
  );
}
