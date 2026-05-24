import 'dart:convert';

import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/defects/data/defects_api_service.dart';
import 'package:cafelab_iot_mobile/features/defects/data/defects_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/defects/domain/models/create_defect_request.dart';
import 'package:flutter/material.dart';

class DefectsTestPage extends StatefulWidget {
  const DefectsTestPage({super.key});

  @override
  State<DefectsTestPage> createState() => _DefectsTestPageState();
}

class _DefectsTestPageState extends State<DefectsTestPage> {
  final _repo = DefectsRepositoryImpl();
  final _tokenStorage = TokenStorageService();
  final _coffeeDisplayNameCtrl = TextEditingController();
  final _coffeeRegionCtrl = TextEditingController();
  final _coffeeVarietyCtrl = TextEditingController();
  final _coffeeTotalWeightCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _defectTypeCtrl = TextEditingController();
  final _defectWeightCtrl = TextEditingController();
  final _percentageCtrl = TextEditingController();
  final _probableCauseCtrl = TextEditingController();
  final _suggestedSolutionCtrl = TextEditingController();
  final _defectIdCtrl = TextEditingController();

  bool _loading = false;
  String _status = 'Idle';
  String _result = 'Sin llamadas todavía.';

  @override
  void dispose() {
    _coffeeDisplayNameCtrl.dispose();
    _coffeeRegionCtrl.dispose();
    _coffeeVarietyCtrl.dispose();
    _coffeeTotalWeightCtrl.dispose();
    _nameCtrl.dispose();
    _defectTypeCtrl.dispose();
    _defectWeightCtrl.dispose();
    _percentageCtrl.dispose();
    _probableCauseCtrl.dispose();
    _suggestedSolutionCtrl.dispose();
    _defectIdCtrl.dispose();
    super.dispose();
  }

  Future<bool> _ensureTokenOrShowError() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      _showError(
        'No hay token guardado. Haz Sign In primero para usar Defects.',
      );
      return false;
    }
    return true;
  }

  Future<void> _createDefect() async {
    if (!await _ensureTokenOrShowError()) return;

    final coffeeDisplayName = _coffeeDisplayNameCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    final defectType = _defectTypeCtrl.text.trim();
    final probableCause = _probableCauseCtrl.text.trim();
    final suggestedSolution = _suggestedSolutionCtrl.text.trim();
    final defectWeight = double.tryParse(_defectWeightCtrl.text.trim());
    final percentage = double.tryParse(_percentageCtrl.text.trim());
    final coffeeTotalWeightText = _coffeeTotalWeightCtrl.text.trim();
    final coffeeTotalWeight = coffeeTotalWeightText.isEmpty
        ? null
        : double.tryParse(coffeeTotalWeightText);

    if (coffeeDisplayName.isEmpty) {
      _showError('coffeeDisplayName es obligatorio.');
      return;
    }
    if (name.isEmpty) {
      _showError('name es obligatorio.');
      return;
    }
    if (defectType.isEmpty) {
      _showError('defectType es obligatorio.');
      return;
    }
    if (defectWeight == null || defectWeight <= 0) {
      _showError('defectWeight debe ser mayor a 0.');
      return;
    }
    if (percentage == null || percentage < 0 || percentage > 100) {
      _showError('percentage debe estar entre 0 y 100.');
      return;
    }
    if (probableCause.isEmpty) {
      _showError('probableCause es obligatorio.');
      return;
    }
    if (suggestedSolution.isEmpty) {
      _showError('suggestedSolution es obligatorio.');
      return;
    }
    if (coffeeTotalWeightText.isNotEmpty &&
        (coffeeTotalWeight == null || coffeeTotalWeight < 0)) {
      _showError('coffeeTotalWeight debe ser >= 0 cuando se envía.');
      return;
    }

    await _run(
      label: 'CREATE_DEFECT',
      action: () async {
        final defect = await _repo.createDefect(
          CreateDefectRequest(
            coffeeDisplayName: coffeeDisplayName,
            coffeeRegion: _coffeeRegionCtrl.text.trim().isEmpty
                ? null
                : _coffeeRegionCtrl.text.trim(),
            coffeeVariety: _coffeeVarietyCtrl.text.trim().isEmpty
                ? null
                : _coffeeVarietyCtrl.text.trim(),
            coffeeTotalWeight: coffeeTotalWeight,
            name: name,
            defectType: defectType,
            defectWeight: defectWeight,
            percentage: percentage,
            probableCause: probableCause,
            suggestedSolution: suggestedSolution,
          ),
        );
        _setResult('Creado correctamente', defect.prettyJson());
      },
    );
  }

  Future<void> _loadDefects() async {
    if (!await _ensureTokenOrShowError()) return;
    await _run(
      label: 'LOAD_DEFECTS',
      action: () async {
        final defects = await _repo.getDefects();
        final raw = defects.map((e) => e.raw).toList();
        _setResult(
          'Defectos cargados: ${defects.length}',
          const JsonEncoder.withIndent('  ').convert(raw),
        );
      },
    );
  }

  Future<void> _getById() async {
    if (!await _ensureTokenOrShowError()) return;
    final id = int.tryParse(_defectIdCtrl.text.trim());
    if (id == null) {
      _showError('Defect ID debe ser numérico.');
      return;
    }
    await _run(
      label: 'GET_DEFECT_BY_ID',
      action: () async {
        final defect = await _repo.getDefectById(id);
        _setResult('Defecto encontrado', defect.prettyJson());
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
    } on DefectsApiException catch (e) {
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
      appBar: AppBar(title: const Text('Defects Test Page')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _coffeeDisplayNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'coffeeDisplayName *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _coffeeRegionCtrl,
                decoration: const InputDecoration(
                  labelText: 'coffeeRegion',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _coffeeVarietyCtrl,
                decoration: const InputDecoration(
                  labelText: 'coffeeVariety',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _coffeeTotalWeightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'coffeeTotalWeight (>=0)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _defectTypeCtrl,
                decoration: const InputDecoration(
                  labelText: 'defectType *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _defectWeightCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'defectWeight * (>0)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _percentageCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'percentage * (0..100)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _probableCauseCtrl,
                decoration: const InputDecoration(
                  labelText: 'probableCause *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _suggestedSolutionCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'suggestedSolution *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (_loading) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loading ? null : _createDefect,
                child: const Text('Create Defect'),
              ),
              ElevatedButton(
                onPressed: _loading ? null : _loadDefects,
                child: const Text('Load My Defects'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _defectIdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Defect ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _loading ? null : _getById,
                child: const Text('Get Defect By Id'),
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
