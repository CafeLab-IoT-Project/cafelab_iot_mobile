import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_scaffold.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/create_supplier_input.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/supplier.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/domain/models/update_supplier_input.dart';
import 'package:cafelab_iot_mobile/features/production/suppliers/presentation/suppliers_controller.dart';
import 'package:flutter/material.dart';

class SuppliersPage extends StatefulWidget {
  const SuppliersPage({super.key});

  @override
  State<SuppliersPage> createState() => _SuppliersPageState();
}

class _SuppliersPageState extends State<SuppliersPage> {
  static const double _tableWidth = 862;
  static const double _tableHeaderHeight = 56;
  static const double _tableRowHeight = 72;

  final SuppliersController controller = SuppliersController();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _horizontalTableController = ScrollController();
  final ScrollController _verticalTableController = ScrollController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_handleSearchChanged);
    controller.loadSuppliers();
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

  Future<void> _reloadSuppliers() async {
    await controller.loadSuppliers();
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

  Future<void> _openCreateDialog() async {
    await showDialog<void>(
      context: context,
      builder: (_) => _SupplierFormDialog(
        title: 'Nuevo proveedor',
        submitLabel: 'Registrar proveedor',
        onSubmit: (value) async {
          final success = await controller.createSupplier(
            value.toCreateInput(),
          );
          if (success) {
            _showSuccessSnackBarIfNeeded();
            return null;
          }
          return controller.errorMessage ??
              'No se pudo registrar el proveedor.';
        },
      ),
    );
  }

  Future<void> _openEditDialog(Supplier supplier) async {
    await showDialog<void>(
      context: context,
      builder: (_) => _SupplierFormDialog(
        supplier: supplier,
        title: 'Editar proveedor',
        submitLabel: 'Guardar proveedor',
        onSubmit: (value) async {
          final success = await controller.updateSupplier(
            supplier.id,
            value.toUpdateInput(),
          );
          if (success) {
            _showSuccessSnackBarIfNeeded();
            return null;
          }
          return controller.errorMessage ??
              'No se pudo actualizar el proveedor.';
        },
      ),
    );
  }

  Future<void> _openDetailDialog(Supplier supplier) async {
    controller.selectSupplier(supplier);

    await showDialog<void>(
      context: context,
      builder: (_) => _SupplierDetailDialog(supplier: supplier),
    );
  }

  Future<void> _confirmDelete(Supplier supplier) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar proveedor'),
        content: Text('Deseas eliminar a ${supplier.name}?'),
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

    final success = await controller.deleteSupplier(supplier.id);
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
                      'Inicio > Proveedores',
                      style: TextStyle(
                        color: Color(0xFF4E5342),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SupplierToolbar(
                      searchController: _searchController,
                      isLoading: controller.isLoading,
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
                        onRetry: _reloadSuppliers,
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
        title: 'No se pudieron cargar los proveedores',
        message: 'Intenta nuevamente en unos segundos.',
      );
    }

    if (!controller.hasItems && controller.hasLoaded) {
      return _EmptyStateCard(
        title: 'Sin proveedores',
        message: 'Registra tu primer proveedor para verlo en esta tabla.',
      );
    }

    if (controller.hasItems && controller.items.isEmpty) {
      return _EmptyStateCard(
        title: 'Sin coincidencias',
        message: 'No encontramos proveedores con ese criterio de busqueda.',
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
                          const _SuppliersTableHeader(),
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
                                  final supplier = controller.items[index];
                                  return _SupplierRow(
                                    supplier: supplier,
                                    onView: () => _openDetailDialog(supplier),
                                    onEdit: () => _openEditDialog(supplier),
                                    onDelete: () => _confirmDelete(supplier),
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

class _SupplierToolbar extends StatelessWidget {
  const _SupplierToolbar({
    required this.searchController,
    required this.isLoading,
    required this.onCreatePressed,
  });

  final TextEditingController searchController;
  final bool isLoading;
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
                hintText: 'Buscar proveedores',
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
            label: 'Registrar proveedor',
            onPressed: isLoading ? null : onCreatePressed,
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

class _SuppliersTableHeader extends StatelessWidget {
  const _SuppliersTableHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFA6C8C6),
      height: _SuppliersPageState._tableHeaderHeight,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.centerLeft,
      child: const Row(
        children: [
          _TableCell(label: 'Nombre', width: 170, isHeader: true),
          _TableCell(label: 'Correo', width: 210, isHeader: true),
          _TableCell(label: 'Numero Telf.', width: 130, isHeader: true),
          _TableCell(label: 'Ubicacion', width: 170, isHeader: true),
          _TableCell(label: 'Acciones', width: 150, isHeader: true),
        ],
      ),
    );
  }
}

class _SupplierRow extends StatelessWidget {
  const _SupplierRow({
    required this.supplier,
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final Supplier supplier;
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
          height: _SuppliersPageState._tableRowHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _TableCell(label: supplier.name, width: 170),
                _TableCell(label: supplier.email, width: 210),
                _TableCell(label: supplier.phone.toString(), width: 130),
                _TableCell(label: supplier.location, width: 170),
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
                        tooltip: 'Editar proveedor',
                        onPressed: onEdit,
                      ),
                      _ActionIconButton(
                        icon: Icons.delete_outline,
                        tooltip: 'Eliminar proveedor',
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
              Icons.local_shipping_outlined,
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

class _SupplierDetailDialog extends StatelessWidget {
  const _SupplierDetailDialog({required this.supplier});

  final Supplier supplier;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 10),
              child: Text(
                'Proveedores > ${supplier.name}',
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
                    _DetailRow(label: 'Nombre', value: supplier.name),
                    _DetailRow(label: 'Correo', value: supplier.email),
                    _DetailRow(
                      label: 'Telefono',
                      value: supplier.phone.toString(),
                    ),
                    _DetailRow(label: 'Ubicacion', value: supplier.location),
                    const SizedBox(height: 8),
                    const Text(
                      'Especialidades',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E4234),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: supplier.specialties.isEmpty
                          ? const [_TagChip(label: 'Sin especialidades')]
                          : supplier.specialties
                                .map((specialty) => _TagChip(label: specialty))
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
            width: 90,
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

class _SupplierFormDialog extends StatefulWidget {
  const _SupplierFormDialog({
    required this.title,
    required this.submitLabel,
    required this.onSubmit,
    this.supplier,
  });

  final Supplier? supplier;
  final String title;
  final String submitLabel;
  final Future<String?> Function(_SupplierFormValue value) onSubmit;

  @override
  State<_SupplierFormDialog> createState() => _SupplierFormDialogState();
}

class _SupplierFormDialogState extends State<_SupplierFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;
  late final TextEditingController _locationController;
  late final List<TextEditingController> _specialtyControllers;
  final Map<String, String> _fieldErrors = <String, String>{};
  String? _submitError;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.supplier != null;

  @override
  void initState() {
    super.initState();
    final supplier = widget.supplier;
    _nameController = TextEditingController(text: supplier?.name ?? '');
    _emailController = TextEditingController(text: supplier?.email ?? '');
    _phoneController = TextEditingController(
      text: supplier?.phone.toString() ?? '',
    );
    _locationController = TextEditingController(text: supplier?.location ?? '');
    final specialties = supplier?.specialties ?? const <String>[];
    _specialtyControllers = specialties.isEmpty
        ? <TextEditingController>[TextEditingController()]
        : specialties.map((item) => TextEditingController(text: item)).toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    for (final controller in _specialtyControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  bool _isValidEmail(String value) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  void _addSpecialtyField() {
    setState(() {
      _specialtyControllers.add(TextEditingController());
    });
  }

  void _removeSpecialtyField(int index) {
    if (_specialtyControllers.length == 1) {
      _specialtyControllers.first.clear();
      return;
    }

    setState(() {
      final controller = _specialtyControllers.removeAt(index);
      controller.dispose();
    });
  }

  _SupplierFormValue? _validateForm() {
    _fieldErrors.clear();

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phoneText = _phoneController.text.trim();
    final location = _locationController.text.trim();
    final phone = int.tryParse(phoneText);

    if (name.isEmpty) {
      _fieldErrors['name'] = 'Ingresa el nombre del proveedor.';
    }
    if (email.isEmpty) {
      _fieldErrors['email'] = 'Ingresa el correo.';
    } else if (!_isValidEmail(email)) {
      _fieldErrors['email'] = 'Ingresa un correo valido.';
    }
    if (phoneText.isEmpty) {
      _fieldErrors['phone'] = 'Ingresa el telefono.';
    } else if (phone == null || phone <= 0) {
      _fieldErrors['phone'] = 'Ingresa un telefono numerico valido.';
    }
    if (location.isEmpty) {
      _fieldErrors['location'] = 'Ingresa la ubicacion.';
    }

    if (_fieldErrors.isNotEmpty || phone == null) {
      return null;
    }

    final specialties = _specialtyControllers
        .map((controller) => controller.text.trim())
        .where((value) => value.isNotEmpty)
        .toList();

    return _SupplierFormValue(
      name: name,
      email: email,
      phone: phone,
      location: location,
      specialties: specialties,
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
        constraints: const BoxConstraints(maxWidth: 370),
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
                          fontSize: 28,
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
                    'Informacion de Contacto',
                    style: TextStyle(
                      color: Color(0xFF575757),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _SupplierInputField(
                  label: 'Nombre de proveedor',
                  controller: _nameController,
                  enabled: !_isSubmitting,
                  errorText: _fieldErrors['name'],
                ),
                const SizedBox(height: 14),
                _SupplierInputField(
                  label: 'Correo',
                  controller: _emailController,
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _fieldErrors['email'],
                ),
                const SizedBox(height: 14),
                _SupplierInputField(
                  label: 'Telefono',
                  controller: _phoneController,
                  enabled: !_isSubmitting,
                  keyboardType: TextInputType.phone,
                  errorText: _fieldErrors['phone'],
                ),
                const SizedBox(height: 14),
                _SupplierInputField(
                  label: 'Ubicacion',
                  controller: _locationController,
                  enabled: !_isSubmitting,
                  errorText: _fieldErrors['location'],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Especialidades',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 10),
                ...List<Widget>.generate(
                  _specialtyControllers.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(
                      bottom: index == _specialtyControllers.length - 1
                          ? 10
                          : 8,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SupplierRoundedField(
                            controller: _specialtyControllers[index],
                            enabled: !_isSubmitting,
                            hintText: 'Especialidad ${index + 1}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: _isSubmitting
                              ? null
                              : () => _removeSpecialtyField(index),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E3DD),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _specialtyControllers.length == 1
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
                  onTap: _isSubmitting ? null : _addSpecialtyField,
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
                if (_isEditMode) const SizedBox(height: 6),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SupplierInputField extends StatelessWidget {
  const _SupplierInputField({
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
        _SupplierRoundedField(
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

class _SupplierRoundedField extends StatelessWidget {
  const _SupplierRoundedField({
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
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF9A958F)),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
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
      ),
    );
  }
}

class _SupplierFormValue {
  const _SupplierFormValue({
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.specialties,
  });

  final String name;
  final String email;
  final int phone;
  final String location;
  final List<String> specialties;

  CreateSupplierInput toCreateInput() {
    return CreateSupplierInput(
      name: name,
      email: email,
      phone: phone,
      location: location,
      specialties: specialties,
    );
  }

  UpdateSupplierInput toUpdateInput() {
    return UpdateSupplierInput(
      name: name,
      email: email,
      phone: phone,
      location: location,
      specialties: specialties,
    );
  }
}
