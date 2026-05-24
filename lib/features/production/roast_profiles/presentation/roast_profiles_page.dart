import 'dart:convert';

import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/create_roast_profile_input.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/domain/models/update_roast_profile_input.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/roast_profiles_controller.dart';
import 'package:flutter/material.dart';

class RoastProfilesPage extends StatefulWidget {
  const RoastProfilesPage({super.key});

  @override
  State<RoastProfilesPage> createState() => _RoastProfilesPageState();
}

class _RoastProfilesPageState extends State<RoastProfilesPage> {
  final controller = RoastProfilesController();
  final _nameCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _tempStartCtrl = TextEditingController();
  final _tempEndCtrl = TextEditingController();
  final _lotCtrl = TextEditingController();
  final _favoriteCtrl = ValueNotifier<bool>(false);
  final _idCtrl = TextEditingController();
  final _userFilterCtrl = TextEditingController();
  final _lotFilterCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.loadAll();
  }

  @override
  void dispose() {
    controller.dispose();
    _nameCtrl.dispose();
    _typeCtrl.dispose();
    _durationCtrl.dispose();
    _tempStartCtrl.dispose();
    _tempEndCtrl.dispose();
    _lotCtrl.dispose();
    _favoriteCtrl.dispose();
    _idCtrl.dispose();
    _userFilterCtrl.dispose();
    _lotFilterCtrl.dispose();
    super.dispose();
  }

  CreateRoastProfileInput? _buildCreateInput() {
    final duration = int.tryParse(_durationCtrl.text.trim());
    final tempStart = double.tryParse(_tempStartCtrl.text.trim());
    final tempEnd = double.tryParse(_tempEndCtrl.text.trim());
    final lot = int.tryParse(_lotCtrl.text.trim());
    if (_nameCtrl.text.trim().isEmpty ||
        _typeCtrl.text.trim().isEmpty ||
        duration == null ||
        duration <= 0 ||
        tempStart == null ||
        tempEnd == null ||
        lot == null ||
        lot <= 0) {
      return null;
    }
    return CreateRoastProfileInput(
      name: _nameCtrl.text.trim(),
      type: _typeCtrl.text.trim(),
      duration: duration,
      tempStart: tempStart,
      tempEnd: tempEnd,
      lot: lot,
      isFavorite: _favoriteCtrl.value,
    );
  }

  UpdateRoastProfileInput? _buildUpdateInput() {
    final create = _buildCreateInput();
    if (create == null) return null;
    return UpdateRoastProfileInput(
      name: create.name,
      type: create.type,
      duration: create.duration,
      tempStart: create.tempStart,
      tempEnd: create.tempEnd,
      lot: create.lot,
      isFavorite: _favoriteCtrl.value,
    );
  }

  void _showJson(String title, Map<String, dynamic> jsonMap) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: SelectableText(const JsonEncoder.withIndent('  ').convert(jsonMap)),
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
      appBar: AppBar(title: const Text('Roast Profiles')),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
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
                const SizedBox(height: 8),
                TextField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'name *'),
                ),
                TextField(
                  controller: _typeCtrl,
                  decoration: const InputDecoration(labelText: 'type *'),
                ),
                TextField(
                  controller: _durationCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'duration *'),
                ),
                TextField(
                  controller: _tempStartCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'tempStart *'),
                ),
                TextField(
                  controller: _tempEndCtrl,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'tempEnd *'),
                ),
                TextField(
                  controller: _lotCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'lot *'),
                ),
                const SizedBox(height: 8),
                ValueListenableBuilder<bool>(
                  valueListenable: _favoriteCtrl,
                  builder: (_, value, __) => SwitchListTile(
                    title: const Text('isFavorite'),
                    value: value,
                    onChanged: (v) => _favoriteCtrl.value = v,
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
                              const SnackBar(content: Text('Datos invalidos para crear')),
                            );
                            return;
                          }
                          await controller.create(input);
                        },
                  child: const Text('Create'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _idCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'id para detalle/editar/eliminar'),
                      ),
                    ),
                  ],
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
                            _showJson('Detalle Roast Profile', {
                              'id': selected.id,
                              'userId': selected.userId,
                              'name': selected.name,
                              'type': selected.type,
                              'duration': selected.duration,
                              'tempStart': selected.tempStart,
                              'tempEnd': selected.tempEnd,
                              'coffeeLotId': selected.coffeeLotId,
                              'isFavorite': selected.isFavorite,
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
                              content: Text('Eliminar roast profile $id?'),
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
                          if (confirmed == true) {
                            await controller.delete(id);
                          }
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
                  controller: _lotFilterCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'coffeeLotId'),
                ),
                ElevatedButton(
                  onPressed: controller.isLoading
                      ? null
                      : () async {
                          final id = int.tryParse(_lotFilterCtrl.text.trim());
                          if (id == null) return;
                          await controller.filterByLotId(id);
                        },
                  child: const Text('Filtrar por lot'),
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
                      title: Text('${item.name} (${item.type})'),
                      subtitle: Text(
                        'id=${item.id} lot=${item.coffeeLotId} duration=${item.duration} fav=${item.isFavorite}',
                      ),
                      onTap: () {
                        _showJson('Roast Profile ${item.id}', {
                          'id': item.id,
                          'userId': item.userId,
                          'name': item.name,
                          'type': item.type,
                          'duration': item.duration,
                          'tempStart': item.tempStart,
                          'tempEnd': item.tempEnd,
                          'coffeeLotId': item.coffeeLotId,
                          'isFavorite': item.isFavorite,
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
