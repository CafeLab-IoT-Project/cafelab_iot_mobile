import 'dart:convert';

import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/management/data/management_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/create_inventory_entry_request.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/inventory_entry.dart';
import 'package:cafelab_iot_mobile/features/management/domain/models/update_inventory_entry_request.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/material.dart';

class ManagementTestPage extends StatefulWidget {
  const ManagementTestPage({super.key});

  @override
  State<ManagementTestPage> createState() => _ManagementTestPageState();
}

class _ManagementTestPageState extends State<ManagementTestPage> {
  final _repo = ManagementRepositoryImpl();
  final _tokenStorage = TokenStorageService();

  final _entryIdCtrl = TextEditingController();
  final _profileUserIdCtrl = TextEditingController();
  final _coffeeLotFilterCtrl = TextEditingController();

  final _coffeeLotIdCtrl = TextEditingController();
  final _quantityUsedCtrl = TextEditingController();
  final _dateUsedCtrl = TextEditingController(text: '2026-05-05T10:30:00');
  final _finalProductCtrl = TextEditingController();

  bool _loading = false;
  String _status = 'Idle';
  String _result = 'Sin llamadas todavía.';

  @override
  void dispose() {
    _entryIdCtrl.dispose();
    _profileUserIdCtrl.dispose();
    _coffeeLotFilterCtrl.dispose();
    _coffeeLotIdCtrl.dispose();
    _quantityUsedCtrl.dispose();
    _dateUsedCtrl.dispose();
    _finalProductCtrl.dispose();
    super.dispose();
  }

  Future<bool> _ensureTokenOrShowError() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      _showError('No hay token guardado. Haz Sign In primero para usar Management.');
      return false;
    }
    return true;
  }

  int? _parseInt(TextEditingController ctrl) => int.tryParse(ctrl.text.trim());
  double? _parseDouble(TextEditingController ctrl) => double.tryParse(ctrl.text.trim());

  DateTime? _parseDateTime(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return null;
    try {
      return inventoryEntryDateFromWire(value);
    } catch (_) {
      return null;
    }
  }

  String? _validateEntryForm() {
    final coffeeLotId = _parseInt(_coffeeLotIdCtrl);
    final quantityUsed = _parseDouble(_quantityUsedCtrl);
    final dateUsed = _parseDateTime(_dateUsedCtrl.text);
    final finalProduct = _finalProductCtrl.text.trim();

    if (coffeeLotId == null || coffeeLotId <= 0) return 'coffeeLotId debe ser numérico y positivo.';
    if (quantityUsed == null || quantityUsed <= 0) {
      return 'quantityUsed debe ser numérico y mayor que cero.';
    }
    if (dateUsed == null) return 'dateUsed debe tener formato YYYY-MM-DDTHH:mm:ss.';
    if (finalProduct.isEmpty) return 'finalProduct es obligatorio.';
    if (finalProduct.length > 100) return 'finalProduct no puede superar 100 caracteres.';
    return null;
  }

  CreateInventoryEntryRequest _buildCreateRequest() {
    return CreateInventoryEntryRequest(
      coffeeLotId: int.parse(_coffeeLotIdCtrl.text.trim()),
      quantityUsed: double.parse(_quantityUsedCtrl.text.trim()),
      dateUsed: _parseDateTime(_dateUsedCtrl.text)!,
      finalProduct: _finalProductCtrl.text.trim(),
    );
  }

  UpdateInventoryEntryRequest _buildUpdateRequest() {
    return UpdateInventoryEntryRequest(
      coffeeLotId: int.parse(_coffeeLotIdCtrl.text.trim()),
      quantityUsed: double.parse(_quantityUsedCtrl.text.trim()),
      dateUsed: _parseDateTime(_dateUsedCtrl.text)!,
      finalProduct: _finalProductCtrl.text.trim(),
    );
  }

  Future<void> _createEntry() async {
    if (!await _ensureTokenOrShowError()) return;
    final error = _validateEntryForm();
    if (error != null) return _showError(error);
    await _run(
      label: 'CREATE_INVENTORY_ENTRY',
      action: () async {
        final data = await _repo.createInventoryEntry(_buildCreateRequest());
        _setResult('Entrada creada', _pretty(_entryMap(data)));
      },
    );
  }

  Future<void> _listMine() async {
    if (!await _ensureTokenOrShowError()) return;
    await _run(
      label: 'LIST_INVENTORY_ENTRIES',
      action: () async {
        final list = await _repo.listInventoryEntries();
        _setResult('Entradas: ${list.length}', _pretty(list.map(_entryMap).toList()));
      },
    );
  }

  Future<void> _listByProfile() async {
    if (!await _ensureTokenOrShowError()) return;
    final userId = _parseInt(_profileUserIdCtrl);
    if (userId == null) return _showError('profile userId debe ser numérico.');
    await _run(
      label: 'LIST_BY_PROFILE',
      action: () async {
        final list = await _repo.listInventoryEntriesByProfile(userId);
        _setResult('Entradas por perfil: ${list.length}', _pretty(list.map(_entryMap).toList()));
      },
    );
  }

  Future<void> _listByCoffeeLot() async {
    if (!await _ensureTokenOrShowError()) return;
    final coffeeLotId = _parseInt(_coffeeLotFilterCtrl);
    if (coffeeLotId == null) return _showError('coffeeLotId filtro debe ser numérico.');
    await _run(
      label: 'LIST_BY_COFFEE_LOT',
      action: () async {
        final list = await _repo.listInventoryEntriesByCoffeeLot(coffeeLotId);
        _setResult('Entradas por lote: ${list.length}', _pretty(list.map(_entryMap).toList()));
      },
    );
  }

  Future<void> _getById() async {
    if (!await _ensureTokenOrShowError()) return;
    final entryId = _parseInt(_entryIdCtrl);
    if (entryId == null) return _showError('inventoryEntryId debe ser numérico.');
    await _run(
      label: 'GET_BY_ID',
      action: () async {
        final data = await _repo.getInventoryEntryById(entryId);
        _setResult('Entrada encontrada', _pretty(_entryMap(data)));
      },
    );
  }

  Future<void> _updateEntry() async {
    if (!await _ensureTokenOrShowError()) return;
    final entryId = _parseInt(_entryIdCtrl);
    if (entryId == null) return _showError('inventoryEntryId debe ser numérico.');
    final error = _validateEntryForm();
    if (error != null) return _showError(error);
    await _run(
      label: 'UPDATE_INVENTORY_ENTRY',
      action: () async {
        final data = await _repo.updateInventoryEntry(entryId, _buildUpdateRequest());
        _setResult('Entrada actualizada', _pretty(_entryMap(data)));
      },
    );
  }

  Future<void> _deleteEntry() async {
    if (!await _ensureTokenOrShowError()) return;
    final entryId = _parseInt(_entryIdCtrl);
    if (entryId == null) return _showError('inventoryEntryId debe ser numérico.');
    await _run(
      label: 'DELETE_INVENTORY_ENTRY',
      action: () async {
        final msg = await _repo.deleteInventoryEntry(entryId);
        _setResult('Entrada eliminada', _pretty({'message': msg.message}));
      },
    );
  }

  Future<void> _run({
    required String label,
    required Future<void> Function() action,
  }) async {
    setState(() {
      _loading = true;
      _status = '$label - loading...';
    });
    try {
      await action();
    } on ProductionApiException catch (e) {
      _showError(e.toString());
    } catch (e) {
      _showError('Error inesperado: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _setResult(String status, String result) {
    setState(() {
      _status = status;
      _result = result;
    });
  }

  void _showError(String message) {
    setState(() {
      _status = 'Error';
      _result = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _pretty(Object value) => const JsonEncoder.withIndent('  ').convert(value);

  Map<String, dynamic> _entryMap(InventoryEntry e) => {
        'id': e.id,
        'userId': e.userId,
        'coffeeLotId': e.coffeeLotId,
        'quantityUsed': e.quantityUsed,
        'dateUsed': inventoryEntryDateToWire(e.dateUsed),
        'finalProduct': e.finalProduct,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Management / Inventory Entries')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_loading) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text('Filtros / IDs', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _entryIdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'inventoryEntryId (get/update/delete)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _profileUserIdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'profile userId (list by profile)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _coffeeLotFilterCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'coffeeLotId (list by lot)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Create / Update body', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _coffeeLotIdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'coffeeLotId *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _quantityUsedCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'quantityUsed * (> 0)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dateUsedCtrl,
                decoration: const InputDecoration(
                  labelText: 'dateUsed * (YYYY-MM-DDTHH:mm:ss)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _finalProductCtrl,
                decoration: const InputDecoration(
                  labelText: 'finalProduct *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: _loading ? null : _createEntry,
                    child: const Text('Create'),
                  ),
                  ElevatedButton(
                    onPressed: _loading ? null : _listMine,
                    child: const Text('List mine'),
                  ),
                  ElevatedButton(
                    onPressed: _loading ? null : _listByProfile,
                    child: const Text('List by profile'),
                  ),
                  ElevatedButton(
                    onPressed: _loading ? null : _listByCoffeeLot,
                    child: const Text('List by lot'),
                  ),
                  OutlinedButton(
                    onPressed: _loading ? null : _getById,
                    child: const Text('Get by ID'),
                  ),
                  OutlinedButton(
                    onPressed: _loading ? null : _updateEntry,
                    child: const Text('Update'),
                  ),
                  OutlinedButton(
                    onPressed: _loading ? null : _deleteEntry,
                    child: const Text('Delete'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text('Status: $_status'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(_result),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
