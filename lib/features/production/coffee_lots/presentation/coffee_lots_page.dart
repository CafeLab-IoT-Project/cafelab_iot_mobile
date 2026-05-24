import 'dart:convert';

import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/create_coffee_lot_input.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/domain/models/update_coffee_lot_input.dart';
import 'package:cafelab_iot_mobile/features/production/coffee_lots/presentation/coffee_lots_controller.dart';
import 'package:flutter/material.dart';

class CoffeeLotsPage extends StatefulWidget {
  const CoffeeLotsPage({super.key});

  @override
  State<CoffeeLotsPage> createState() => _CoffeeLotsPageState();
}

class _CoffeeLotsPageState extends State<CoffeeLotsPage> {
  final controller = CoffeeLotsController();
  final _supplierIdCtrl = TextEditingController();
  final _lotNameCtrl = TextEditingController();
  final _coffeeTypeCtrl = TextEditingController();
  final _processingMethodCtrl = TextEditingController();
  final _altitudeCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _originCtrl = TextEditingController();
  final _statusCtrl = TextEditingController();
  final _certificationsCtrl = TextEditingController();
  final _idCtrl = TextEditingController();
  final _userFilterCtrl = TextEditingController();
  final _supplierFilterCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.loadAll();
  }

  @override
  void dispose() {
    controller.dispose();
    _supplierIdCtrl.dispose();
    _lotNameCtrl.dispose();
    _coffeeTypeCtrl.dispose();
    _processingMethodCtrl.dispose();
    _altitudeCtrl.dispose();
    _weightCtrl.dispose();
    _originCtrl.dispose();
    _statusCtrl.dispose();
    _certificationsCtrl.dispose();
    _idCtrl.dispose();
    _userFilterCtrl.dispose();
    _supplierFilterCtrl.dispose();
    super.dispose();
  }

  List<String> _parseCertifications() {
    final raw = _certificationsCtrl.text.trim();
    if (raw.isEmpty) return <String>[];
    return raw.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  CreateCoffeeLotInput? _buildCreateInput() {
    final supplierId = int.tryParse(_supplierIdCtrl.text.trim());
    final altitude = int.tryParse(_altitudeCtrl.text.trim());
    final weight = double.tryParse(_weightCtrl.text.trim());
    if (supplierId == null ||
        supplierId <= 0 ||
        _lotNameCtrl.text.trim().isEmpty ||
        _coffeeTypeCtrl.text.trim().isEmpty ||
        _processingMethodCtrl.text.trim().isEmpty ||
        altitude == null ||
        altitude <= 0 ||
        weight == null ||
        weight <= 0 ||
        _originCtrl.text.trim().isEmpty ||
        _statusCtrl.text.trim().isEmpty) {
      return null;
    }
    return CreateCoffeeLotInput(
      supplierId: supplierId,
      lotName: _lotNameCtrl.text.trim(),
      coffeeType: _coffeeTypeCtrl.text.trim(),
      processingMethod: _processingMethodCtrl.text.trim(),
      altitude: altitude,
      weight: weight,
      origin: _originCtrl.text.trim(),
      status: _statusCtrl.text.trim(),
      certifications: _parseCertifications(),
    );
  }

  UpdateCoffeeLotInput? _buildUpdateInput() {
    final altitude = int.tryParse(_altitudeCtrl.text.trim());
    final weight = double.tryParse(_weightCtrl.text.trim());
    if (_lotNameCtrl.text.trim().isEmpty ||
        _coffeeTypeCtrl.text.trim().isEmpty ||
        _processingMethodCtrl.text.trim().isEmpty ||
        altitude == null ||
        altitude <= 0 ||
        weight == null ||
        weight <= 0 ||
        _originCtrl.text.trim().isEmpty ||
        _statusCtrl.text.trim().isEmpty) {
      return null;
    }
    return UpdateCoffeeLotInput(
      lotName: _lotNameCtrl.text.trim(),
      coffeeType: _coffeeTypeCtrl.text.trim(),
      processingMethod: _processingMethodCtrl.text.trim(),
      altitude: altitude,
      weight: weight,
      origin: _originCtrl.text.trim(),
      status: _statusCtrl.text.trim(),
      certifications: _parseCertifications(),
    );
  }

  void _showJson(String title, Map<String, dynamic> map) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: SelectableText(const JsonEncoder.withIndent('  ').convert(map)),
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
      appBar: AppBar(title: const Text('Coffee Lots')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (_, __) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (controller.isLoading) const LinearProgressIndicator(),
                if (controller.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      controller.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (controller.lastActionMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(controller.lastActionMessage!),
                  ),
                const SizedBox(height: 12),
                const Text('Crear / Editar'),
                TextField(
                  controller: _supplierIdCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'supplier_id *'),
                ),
                TextField(
                  controller: _lotNameCtrl,
                  decoration: const InputDecoration(labelText: 'lot_name *'),
                ),
                TextField(
                  controller: _coffeeTypeCtrl,
                  decoration: const InputDecoration(labelText: 'coffee_type *'),
                ),
                TextField(
                  controller: _processingMethodCtrl,
                  decoration: const InputDecoration(labelText: 'processing_method *'),
                ),
                TextField(
                  controller: _altitudeCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'altitude *'),
                ),
                TextField(
                  controller: _weightCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'weight *'),
                ),
                TextField(
                  controller: _originCtrl,
                  decoration: const InputDecoration(labelText: 'origin *'),
                ),
                TextField(
                  controller: _statusCtrl,
                  decoration: const InputDecoration(labelText: 'status *'),
                ),
                TextField(
                  controller: _certificationsCtrl,
                  decoration: const InputDecoration(
                    labelText: 'certifications (comma separated)',
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          final input = _buildCreateInput();
                          if (input == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Datos invalidos para crear lote')),
                            );
                            return;
                          }
                          await controller.create(input);
                        },
                  child: const Text('Create'),
                ),
                TextField(
                  controller: _idCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'id para detalle/editar/eliminar'),
                ),
                ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          final id = int.tryParse(_idCtrl.text.trim());
                          if (id == null) return;
                          await controller.getById(id);
                          final selected = controller.selected;
                          if (selected != null && context.mounted) {
                            _showJson('Coffee Lot ${selected.id}', {
                              'id': selected.id,
                              'userId': selected.userId,
                              'supplierId': selected.supplierId,
                              'lotName': selected.lotName,
                              'coffeeType': selected.coffeeType,
                              'processingMethod': selected.processingMethod,
                              'altitude': selected.altitude,
                              'weight': selected.weight,
                              'origin': selected.origin,
                              'status': selected.status,
                              'certifications': selected.certifications,
                            });
                          }
                        },
                  child: const Text('Get By Id'),
                ),
                ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          final id = int.tryParse(_idCtrl.text.trim());
                          final input = _buildUpdateInput();
                          if (id == null || input == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('id o datos invalidos para editar')),
                            );
                            return;
                          }
                          await controller.update(id, input);
                        },
                  child: const Text('Update By Id'),
                ),
                OutlinedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          final id = int.tryParse(_idCtrl.text.trim());
                          if (id == null) return;
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Confirmar eliminacion'),
                              content: Text('Eliminar coffee lot $id?'),
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
                          if (confirmed == true) await controller.delete(id);
                        },
                  child: const Text('Delete By Id'),
                ),
                const Divider(height: 24),
                const Text('Filtros'),
                TextField(
                  controller: _userFilterCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'userId'),
                ),
                ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          final id = int.tryParse(_userFilterCtrl.text.trim());
                          if (id == null) return;
                          await controller.filterByUserId(id);
                        },
                  child: const Text('Filtrar por userId'),
                ),
                TextField(
                  controller: _supplierFilterCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'supplierId'),
                ),
                ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          final id = int.tryParse(_supplierFilterCtrl.text.trim());
                          if (id == null) return;
                          await controller.filterBySupplierId(id);
                        },
                  child: const Text('Filtrar por supplierId'),
                ),
                OutlinedButton(
                  onPressed: controller.isLoading ? null : controller.loadAll,
                  child: const Text('Recargar todos'),
                ),
                const Divider(height: 24),
                const Text('Listado'),
                if (!controller.isLoading && controller.items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16),
                    child: Text('Sin datos'),
                  ),
                ...controller.items.map(
                  (item) => Card(
                    child: ListTile(
                      title: Text(item.lotName),
                      subtitle: Text(
                        'id=${item.id} supplier=${item.supplierId} weight=${item.weight}',
                      ),
                      onTap: () {
                        _showJson('Coffee Lot ${item.id}', {
                          'id': item.id,
                          'userId': item.userId,
                          'supplierId': item.supplierId,
                          'lotName': item.lotName,
                          'coffeeType': item.coffeeType,
                          'processingMethod': item.processingMethod,
                          'altitude': item.altitude,
                          'weight': item.weight,
                          'origin': item.origin,
                          'status': item.status,
                          'certifications': item.certifications,
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
