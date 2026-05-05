import 'dart:convert';

import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/calibrations/data/calibrations_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/create_grind_calibration_request.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/grind_calibration.dart';
import 'package:cafelab_iot_mobile/features/calibrations/domain/models/update_grind_calibration_request.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/material.dart';

class CalibrationsTestPage extends StatefulWidget {
  const CalibrationsTestPage({super.key});

  @override
  State<CalibrationsTestPage> createState() => _CalibrationsTestPageState();
}

class _CalibrationsTestPageState extends State<CalibrationsTestPage> {
  final _repo = CalibrationsRepositoryImpl();
  final _tokenStorage = TokenStorageService();
  final _nameCtrl = TextEditingController();
  final _methodCtrl = TextEditingController();
  final _equipmentCtrl = TextEditingController();
  final _grindNumberCtrl = TextEditingController();
  final _apertureCtrl = TextEditingController(text: '0');
  final _cupVolumeCtrl = TextEditingController(text: '0');
  final _finalVolumeCtrl = TextEditingController(text: '0');
  final _calibrationDateCtrl = TextEditingController(text: '2026-05-04');
  final _commentsCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _sampleImageCtrl = TextEditingController();
  final _calibrationIdCtrl = TextEditingController();

  bool _loading = false;
  String _status = 'Idle';
  String _result = 'Sin llamadas todavía.';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _methodCtrl.dispose();
    _equipmentCtrl.dispose();
    _grindNumberCtrl.dispose();
    _apertureCtrl.dispose();
    _cupVolumeCtrl.dispose();
    _finalVolumeCtrl.dispose();
    _calibrationDateCtrl.dispose();
    _commentsCtrl.dispose();
    _notesCtrl.dispose();
    _sampleImageCtrl.dispose();
    _calibrationIdCtrl.dispose();
    super.dispose();
  }

  Future<bool> _ensureTokenOrShowError() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      _showError(
        'No hay token guardado. Haz Sign In primero para usar calibraciones.',
      );
      return false;
    }
    return true;
  }

  DateTime? _parseCalibrationDateOrNull(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    try {
      return grindCalibrationDateFromWire(trimmed);
    } catch (_) {
      return null;
    }
  }

  String? _validateFormFields() {
    final name = _nameCtrl.text.trim();
    final method = _methodCtrl.text.trim();
    final equipment = _equipmentCtrl.text.trim();
    final grindNumber = _grindNumberCtrl.text.trim();
    final aperture = double.tryParse(_apertureCtrl.text.trim());
    final cupVolume = double.tryParse(_cupVolumeCtrl.text.trim());
    final finalVolume = double.tryParse(_finalVolumeCtrl.text.trim());
    final calibrationDate =
        _parseCalibrationDateOrNull(_calibrationDateCtrl.text);

    if (name.isEmpty ||
        method.isEmpty ||
        equipment.isEmpty ||
        grindNumber.isEmpty) {
      return 'name, method, equipment y grindNumber son obligatorios.';
    }
    if (aperture == null || cupVolume == null || finalVolume == null) {
      return 'aperture, cupVolume y finalVolume deben ser números válidos.';
    }
    if (aperture < 0 || cupVolume < 0 || finalVolume < 0) {
      return 'aperture, cupVolume y finalVolume deben ser >= 0.';
    }
    if (calibrationDate == null) {
      return 'calibrationDate debe ser YYYY-MM-DD válido.';
    }
    return null;
  }

  CreateGrindCalibrationRequest _buildCreateRequest() {
    final calibrationDate =
        _parseCalibrationDateOrNull(_calibrationDateCtrl.text)!;
    final commentsRaw = _commentsCtrl.text.trim();
    final notesRaw = _notesCtrl.text.trim();
    final sampleRaw = _sampleImageCtrl.text.trim();

    return CreateGrindCalibrationRequest(
      name: _nameCtrl.text.trim(),
      method: _methodCtrl.text.trim(),
      equipment: _equipmentCtrl.text.trim(),
      grindNumber: _grindNumberCtrl.text.trim(),
      aperture: double.parse(_apertureCtrl.text.trim()),
      cupVolume: double.parse(_cupVolumeCtrl.text.trim()),
      finalVolume: double.parse(_finalVolumeCtrl.text.trim()),
      calibrationDate: calibrationDate,
      comments: commentsRaw.isEmpty ? null : commentsRaw,
      notes: notesRaw.isEmpty ? null : notesRaw,
      sampleImage: sampleRaw.isEmpty ? null : sampleRaw,
    );
  }

  UpdateGrindCalibrationRequest _buildUpdateRequest() {
    final calibrationDate =
        _parseCalibrationDateOrNull(_calibrationDateCtrl.text)!;
    final commentsRaw = _commentsCtrl.text.trim();
    final notesRaw = _notesCtrl.text.trim();
    final sampleRaw = _sampleImageCtrl.text.trim();

    return UpdateGrindCalibrationRequest(
      name: _nameCtrl.text.trim(),
      method: _methodCtrl.text.trim(),
      equipment: _equipmentCtrl.text.trim(),
      grindNumber: _grindNumberCtrl.text.trim(),
      aperture: double.parse(_apertureCtrl.text.trim()),
      cupVolume: double.parse(_cupVolumeCtrl.text.trim()),
      finalVolume: double.parse(_finalVolumeCtrl.text.trim()),
      calibrationDate: calibrationDate,
      comments: commentsRaw.isEmpty ? null : commentsRaw,
      notes: notesRaw.isEmpty ? null : notesRaw,
      sampleImage: sampleRaw.isEmpty ? null : sampleRaw,
    );
  }

  Future<void> _createCalibration() async {
    if (!await _ensureTokenOrShowError()) return;
    final err = _validateFormFields();
    if (err != null) {
      _showError(err);
      return;
    }

    await _run(
      label: 'CREATE_CALIBRATION',
      action: () async {
        final calibration = await _repo.create(_buildCreateRequest());
        _setResult(
          'Creado correctamente',
          const JsonEncoder.withIndent('  ')
              .convert(_calibrationMap(calibration)),
        );
      },
    );
  }

  Future<void> _loadCalibrations() async {
    if (!await _ensureTokenOrShowError()) return;
    await _run(
      label: 'LIST_CALIBRATIONS',
      action: () async {
        final list = await _repo.list();
        final raw = list.map(_calibrationMap).toList();
        _setResult(
          'Calibraciones: ${list.length}',
          const JsonEncoder.withIndent('  ').convert(raw),
        );
      },
    );
  }

  Future<void> _getById() async {
    if (!await _ensureTokenOrShowError()) return;
    final id = int.tryParse(_calibrationIdCtrl.text.trim());
    if (id == null) {
      _showError('calibrationId debe ser numérico.');
      return;
    }
    await _run(
      label: 'GET_CALIBRATION_BY_ID',
      action: () async {
        final calibration = await _repo.getById(id);
        _setResult(
          'Calibración encontrada',
          const JsonEncoder.withIndent('  ')
              .convert(_calibrationMap(calibration)),
        );
      },
    );
  }

  Future<void> _updateCalibration() async {
    if (!await _ensureTokenOrShowError()) return;
    final id = int.tryParse(_calibrationIdCtrl.text.trim());
    if (id == null) {
      _showError('calibrationId debe ser numérico para actualizar.');
      return;
    }
    final err = _validateFormFields();
    if (err != null) {
      _showError(err);
      return;
    }

    await _run(
      label: 'UPDATE_CALIBRATION',
      action: () async {
        final calibration = await _repo.update(id, _buildUpdateRequest());
        _setResult(
          'Actualizado correctamente',
          const JsonEncoder.withIndent('  ')
              .convert(_calibrationMap(calibration)),
        );
      },
    );
  }

  Map<String, dynamic> _calibrationMap(GrindCalibration c) {
    return {
      'id': c.id,
      'userId': c.userId,
      'name': c.name,
      'method': c.method,
      'equipment': c.equipment,
      'grindNumber': c.grindNumber,
      'aperture': c.aperture,
      'cupVolume': c.cupVolume,
      'finalVolume': c.finalVolume,
      'calibrationDate': grindCalibrationDateToWire(c.calibrationDate),
      'comments': c.comments,
      'notes': c.notes,
      'sampleImage': c.sampleImage,
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
      appBar: AppBar(title: const Text('Calibraciones (molienda)')),
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
                controller: _methodCtrl,
                decoration: const InputDecoration(
                  labelText: 'method *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _equipmentCtrl,
                decoration: const InputDecoration(
                  labelText: 'equipment *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _grindNumberCtrl,
                decoration: const InputDecoration(
                  labelText: 'grindNumber *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _apertureCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'aperture * (>= 0)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _cupVolumeCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'cupVolume * (>= 0)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _finalVolumeCtrl,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'finalVolume * (>= 0)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _calibrationDateCtrl,
                decoration: const InputDecoration(
                  labelText: 'calibrationDate * (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _commentsCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'comments (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'notes (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _sampleImageCtrl,
                decoration: const InputDecoration(
                  labelText: 'sampleImage (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _calibrationIdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'calibrationId (get / update)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (_loading) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loading ? null : _createCalibration,
                child: const Text('Create calibration'),
              ),
              ElevatedButton(
                onPressed: _loading ? null : _loadCalibrations,
                child: const Text('List my calibrations'),
              ),
              OutlinedButton(
                onPressed: _loading ? null : _getById,
                child: const Text('Get by id'),
              ),
              OutlinedButton(
                onPressed: _loading ? null : _updateCalibration,
                child: const Text('Update calibration'),
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
