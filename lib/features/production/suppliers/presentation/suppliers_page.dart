import 'dart:convert';

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
  final controller = SuppliersController();
  final _userFilterCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.loadSuppliers();
  }

  @override
  void dispose() {
    controller.dispose();
    _userFilterCtrl.dispose();
    super.dispose();
  }

  Future<void> _openCreateDialog() async {
    final result = await showDialog<CreateSupplierInput>(
      context: context,
      builder: (_) => const _SupplierFormDialog(),
    );
    if (result != null) {
      await controller.createSupplier(result);
    }
  }

  Future<void> _openEditDialog(Supplier supplier) async {
    final result = await showDialog<UpdateSupplierInput>(
      context: context,
      builder: (_) => _SupplierFormDialog(supplier: supplier),
    );
    if (result != null) {
      await controller.updateSupplier(supplier.id, result);
    }
  }

  Future<void> _showDetail(Supplier supplier) async {
    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Supplier ${supplier.id}'),
        content: SingleChildScrollView(
          child: SelectableText(
            const JsonEncoder.withIndent('  ').convert({
              'id': supplier.id,
              'userId': supplier.userId,
              'name': supplier.name,
              'email': supplier.email,
              'phone': supplier.phone,
              'location': supplier.location,
              'specialties': supplier.specialties,
            }),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (controller.isLoading) return;
              controller.loadSuppliers();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateDialog,
        child: const Icon(Icons.add),
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return Column(
            children: [
              if (controller.isLoading) const LinearProgressIndicator(),
              if (controller.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    controller.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (controller.lastActionMessage != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(controller.lastActionMessage!),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _userFilterCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Filtrar por userId',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: controller.isLoading
                          ? null
                          : () async {
                              final userId = int.tryParse(_userFilterCtrl.text.trim());
                              if (userId == null) return;
                              await controller.loadSuppliersByUserId(userId);
                            },
                      child: const Text('Filtrar'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: controller.items.isEmpty
                    ? const Center(child: Text('Sin suppliers'))
                    : ListView.builder(
                        itemCount: controller.items.length,
                        itemBuilder: (_, index) {
                          final supplier = controller.items[index];
                          return Card(
                            child: ListTile(
                              title: Text(supplier.name),
                              subtitle: Text(
                                '${supplier.email}\nphone: ${supplier.phone}\n${supplier.location}',
                              ),
                              isThreeLine: true,
                              onTap: () => _showDetail(supplier),
                              trailing: Wrap(
                                spacing: 4,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.info_outline),
                                    onPressed: () => _showDetail(supplier),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined),
                                    onPressed: () => _openEditDialog(supplier),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () async {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Confirmar eliminacion'),
                                          content: Text(
                                            'Eliminar supplier ${supplier.id} (${supplier.name})?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(false),
                                              child: const Text('Cancelar'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.of(context).pop(true),
                                              child: const Text('Eliminar'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (ok == true) {
                                        await controller.deleteSupplier(supplier.id);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SupplierFormDialog extends StatefulWidget {
  const _SupplierFormDialog({this.supplier});

  final Supplier? supplier;

  @override
  State<_SupplierFormDialog> createState() => _SupplierFormDialogState();
}

class _SupplierFormDialogState extends State<_SupplierFormDialog> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _specialtiesCtrl;
  String? _error;

  @override
  void initState() {
    super.initState();
    final s = widget.supplier;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _emailCtrl = TextEditingController(text: s?.email ?? '');
    _phoneCtrl = TextEditingController(text: s?.phone.toString() ?? '');
    _locationCtrl = TextEditingController(text: s?.location ?? '');
    _specialtiesCtrl = TextEditingController(text: (s?.specialties ?? []).join(', '));
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _locationCtrl.dispose();
    _specialtiesCtrl.dispose();
    super.dispose();
  }

  bool _isValidEmail(String value) {
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return regex.hasMatch(value);
  }

  List<String> _parseSpecialties() {
    final raw = _specialtiesCtrl.text.trim();
    if (raw.isEmpty) return [];
    return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  void _submit() {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = int.tryParse(_phoneCtrl.text.trim());
    final location = _locationCtrl.text.trim();
    final specialties = _parseSpecialties();

    if (name.isEmpty || name.length > 100) {
      setState(() => _error = 'name requerido, max 100');
      return;
    }
    if (email.isEmpty || email.length > 100 || !_isValidEmail(email)) {
      setState(() => _error = 'email invalido, requerido, max 100');
      return;
    }
    if (phone == null || phone <= 0) {
      setState(() => _error = 'phone debe ser numero > 0');
      return;
    }
    if (location.isEmpty || location.length > 200) {
      setState(() => _error = 'location requerido, max 200');
      return;
    }
    if (specialties.length > 4) {
      setState(() => _error = 'specialties maximo 4 elementos');
      return;
    }

    if (widget.supplier == null) {
      Navigator.of(context).pop(
        CreateSupplierInput(
          name: name,
          email: email,
          phone: phone,
          location: location,
          specialties: specialties,
        ),
      );
      return;
    }
    Navigator.of(context).pop(
      UpdateSupplierInput(
        name: name,
        email: email,
        phone: phone,
        location: location,
        specialties: specialties,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplier != null;
    return AlertDialog(
      title: Text(isEdit ? 'Editar Supplier' : 'Crear Supplier'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'name *'),
            ),
            TextField(
              controller: _emailCtrl,
              decoration: const InputDecoration(labelText: 'email *'),
            ),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'phone *'),
            ),
            TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(labelText: 'location *'),
            ),
            TextField(
              controller: _specialtiesCtrl,
              decoration: const InputDecoration(
                labelText: 'specialties (comma separated, max 4)',
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  _error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEdit ? 'Guardar' : 'Crear'),
        ),
      ],
    );
  }
}
