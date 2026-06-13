import 'dart:convert';

import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/coffees/data/coffees_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/coffees/domain/models/coffee.dart';
import 'package:cafelab_iot_mobile/features/coffees/domain/models/create_coffee_request.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/material.dart';

class CoffeesTestPage extends StatefulWidget {
  const CoffeesTestPage({super.key});

  @override
  State<CoffeesTestPage> createState() => _CoffeesTestPageState();
}

class _CoffeesTestPageState extends State<CoffeesTestPage> {
  final _repo = CoffeesRepositoryImpl();
  final _tokenStorage = TokenStorageService();
  final _nameCtrl = TextEditingController();
  final _regionCtrl = TextEditingController();
  final _varietyCtrl = TextEditingController();
  final _totalWeightCtrl = TextEditingController();
  final _coffeeIdCtrl = TextEditingController();

  bool _loading = false;
  String _status = 'Idle';
  String _result = 'Sin llamadas todavía.';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _regionCtrl.dispose();
    _varietyCtrl.dispose();
    _totalWeightCtrl.dispose();
    _coffeeIdCtrl.dispose();
    super.dispose();
  }

  Future<bool> _ensureTokenOrShowError() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      _showError(
        'No hay token guardado. Haz Sign In primero para usar Coffees.',
      );
      return false;
    }
    return true;
  }

  Future<void> _createCoffee() async {
    if (!await _ensureTokenOrShowError()) return;

    final name = _nameCtrl.text.trim();
    final region = _regionCtrl.text.trim();
    final variety = _varietyCtrl.text.trim();
    final totalWeight = double.tryParse(_totalWeightCtrl.text.trim());

    if (name.isEmpty || region.isEmpty || variety.isEmpty) {
      _showError('name, region y variety son obligatorios (no vacíos).');
      return;
    }
    if (totalWeight == null || totalWeight <= 0) {
      _showError('totalWeight debe ser mayor a 0.');
      return;
    }

    await _run(
      label: 'CREATE_COFFEE',
      action: () async {
        final coffee = await _repo.create(
          CreateCoffeeRequest(
            name: name,
            region: region,
            variety: variety,
            totalWeight: totalWeight,
          ),
        );
        _setResult(
          'Creado correctamente',
          const JsonEncoder.withIndent('  ').convert(_coffeeMap(coffee)),
        );
      },
    );
  }

  Future<void> _loadCoffees() async {
    if (!await _ensureTokenOrShowError()) return;
    await _run(
      label: 'LOAD_COFFEES',
      action: () async {
        final list = await _repo.getAll();
        final raw = list.map(_coffeeMap).toList();
        _setResult(
          'Cafés cargados: ${list.length}',
          const JsonEncoder.withIndent('  ').convert(raw),
        );
      },
    );
  }

  Future<void> _getById() async {
    if (!await _ensureTokenOrShowError()) return;
    final id = int.tryParse(_coffeeIdCtrl.text.trim());
    if (id == null) {
      _showError('coffeeId debe ser numérico.');
      return;
    }
    await _run(
      label: 'GET_COFFEE_BY_ID',
      action: () async {
        final coffee = await _repo.getById(id);
        _setResult(
          'Café encontrado',
          const JsonEncoder.withIndent('  ').convert(_coffeeMap(coffee)),
        );
      },
    );
  }

  Map<String, dynamic> _coffeeMap(Coffee coffee) {
    return {
      'id': coffee.id,
      'name': coffee.name,
      'region': coffee.region,
      'variety': coffee.variety,
      'totalWeight': coffee.totalWeight,
    };
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
      if (mounted) {
        setState(() => _loading = false);
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Coffees')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _regionCtrl,
                decoration: const InputDecoration(
                  labelText: 'region *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _varietyCtrl,
                decoration: const InputDecoration(
                  labelText: 'variety *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _totalWeightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'totalWeight * (>0)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (_loading) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loading ? null : _createCoffee,
                child: const Text('Create Coffee'),
              ),
              ElevatedButton(
                onPressed: _loading ? null : _loadCoffees,
                child: const Text('Load All Coffees'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _coffeeIdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Coffee ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _loading ? null : _getById,
                child: const Text('Get Coffee By Id'),
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
