import 'dart:convert';

import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/data/cupping_sessions_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/create_cupping_session_request.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/cupping_session.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/update_cupping_session_request.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/material.dart';

class CuppingSessionsTestPage extends StatefulWidget {
  const CuppingSessionsTestPage({super.key});

  @override
  State<CuppingSessionsTestPage> createState() =>
      _CuppingSessionsTestPageState();
}

class _CuppingSessionsTestPageState extends State<CuppingSessionsTestPage> {
  final _repo = CuppingSessionsRepositoryImpl();
  final _tokenStorage = TokenStorageService();
  final _nameCtrl = TextEditingController();
  final _originCtrl = TextEditingController();
  final _varietyCtrl = TextEditingController();
  final _processingCtrl = TextEditingController();
  final _sessionDateCtrl = TextEditingController(text: '2026-05-04');
  final _resultsJsonCtrl = TextEditingController();
  final _roastStyleNotesCtrl = TextEditingController();
  final _sessionIdCtrl = TextEditingController();

  bool _favoriteCreate = false;
  bool _favoriteUpdate = false;

  bool _loading = false;
  String _status = 'Idle';
  String _result = 'Sin llamadas todavía.';

  @override
  void dispose() {
    _nameCtrl.dispose();
    _originCtrl.dispose();
    _varietyCtrl.dispose();
    _processingCtrl.dispose();
    _sessionDateCtrl.dispose();
    _resultsJsonCtrl.dispose();
    _roastStyleNotesCtrl.dispose();
    _sessionIdCtrl.dispose();
    super.dispose();
  }

  Future<bool> _ensureTokenOrShowError() async {
    final token = await _tokenStorage.getToken();
    if (token == null || token.isEmpty) {
      _showError(
        'No hay token guardado. Haz Sign In primero para usar sesiones de cata.',
      );
      return false;
    }
    return true;
  }

  DateTime? _parseSessionDateOrError(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;
    try {
      return cuppingSessionDateFromWire(trimmed);
    } catch (_) {
      return null;
    }
  }

  Future<void> _createSession() async {
    if (!await _ensureTokenOrShowError()) return;

    final name = _nameCtrl.text.trim();
    final origin = _originCtrl.text.trim();
    final variety = _varietyCtrl.text.trim();
    final processing = _processingCtrl.text.trim();
    final sessionDate = _parseSessionDateOrError(_sessionDateCtrl.text);

    if (name.isEmpty ||
        origin.isEmpty ||
        variety.isEmpty ||
        processing.isEmpty) {
      _showError('name, origin, variety y processing son obligatorios.');
      return;
    }
    if (sessionDate == null) {
      _showError('sessionDate debe ser YYYY-MM-DD válido.');
      return;
    }

    final resultsRaw = _resultsJsonCtrl.text.trim();
    final notesRaw = _roastStyleNotesCtrl.text.trim();

    await _run(
      label: 'CREATE_CUPPING_SESSION',
      action: () async {
        final session = await _repo.create(
          CreateCuppingSessionRequest(
            name: name,
            origin: origin,
            variety: variety,
            processing: processing,
            sessionDate: sessionDate,
            favorite: _favoriteCreate,
            resultsJson: resultsRaw.isEmpty ? null : resultsRaw,
            roastStyleNotes: notesRaw.isEmpty ? null : notesRaw,
          ),
        );
        _setResult(
          'Creado correctamente',
          const JsonEncoder.withIndent('  ').convert(_sessionMap(session)),
        );
      },
    );
  }

  Future<void> _loadSessions() async {
    if (!await _ensureTokenOrShowError()) return;
    await _run(
      label: 'LIST_CUPPING_SESSIONS',
      action: () async {
        final list = await _repo.list();
        final raw = list.map(_sessionMap).toList();
        _setResult(
          'Sesiones: ${list.length}',
          const JsonEncoder.withIndent('  ').convert(raw),
        );
      },
    );
  }

  Future<void> _getById() async {
    if (!await _ensureTokenOrShowError()) return;
    final id = int.tryParse(_sessionIdCtrl.text.trim());
    if (id == null) {
      _showError('sessionId debe ser numérico.');
      return;
    }
    await _run(
      label: 'GET_CUPPING_SESSION_BY_ID',
      action: () async {
        final session = await _repo.getById(id);
        _setResult(
          'Sesión encontrada',
          const JsonEncoder.withIndent('  ').convert(_sessionMap(session)),
        );
      },
    );
  }

  Future<void> _updateSession() async {
    if (!await _ensureTokenOrShowError()) return;
    final id = int.tryParse(_sessionIdCtrl.text.trim());
    if (id == null) {
      _showError('sessionId debe ser numérico para actualizar.');
      return;
    }

    final name = _nameCtrl.text.trim();
    final origin = _originCtrl.text.trim();
    final variety = _varietyCtrl.text.trim();
    final processing = _processingCtrl.text.trim();
    final sessionDate = _parseSessionDateOrError(_sessionDateCtrl.text);

    if (name.isEmpty ||
        origin.isEmpty ||
        variety.isEmpty ||
        processing.isEmpty) {
      _showError('name, origin, variety y processing son obligatorios.');
      return;
    }
    if (sessionDate == null) {
      _showError('sessionDate debe ser YYYY-MM-DD válido.');
      return;
    }

    final resultsRaw = _resultsJsonCtrl.text.trim();
    final notesRaw = _roastStyleNotesCtrl.text.trim();

    await _run(
      label: 'UPDATE_CUPPING_SESSION',
      action: () async {
        final session = await _repo.update(
          id,
          UpdateCuppingSessionRequest(
            name: name,
            origin: origin,
            variety: variety,
            processing: processing,
            sessionDate: sessionDate,
            favorite: _favoriteUpdate,
            resultsJson: resultsRaw.isEmpty ? null : resultsRaw,
            roastStyleNotes: notesRaw.isEmpty ? null : notesRaw,
          ),
        );
        _setResult(
          'Actualizado correctamente',
          const JsonEncoder.withIndent('  ').convert(_sessionMap(session)),
        );
      },
    );
  }

  Future<void> _deleteSession() async {
    if (!await _ensureTokenOrShowError()) return;
    final id = int.tryParse(_sessionIdCtrl.text.trim());
    if (id == null) {
      _showError('sessionId debe ser numérico para eliminar.');
      return;
    }
    await _run(
      label: 'DELETE_CUPPING_SESSION',
      action: () async {
        await _repo.delete(id);
        _setResult('Eliminado', 'HTTP 204 No Content — sin cuerpo.');
      },
    );
  }

  Map<String, dynamic> _sessionMap(CuppingSession s) {
    return {
      'id': s.id,
      'userId': s.userId,
      'name': s.name,
      'origin': s.origin,
      'variety': s.variety,
      'processing': s.processing,
      'sessionDate': cuppingSessionDateToWire(s.sessionDate),
      'favorite': s.favorite,
      'resultsJson': s.resultsJson,
      'roastStyleNotes': s.roastStyleNotes,
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
      appBar: AppBar(title: const Text('Cupping sessions')),
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
                controller: _originCtrl,
                decoration: const InputDecoration(
                  labelText: 'origin *',
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
                controller: _processingCtrl,
                decoration: const InputDecoration(
                  labelText: 'processing *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _sessionDateCtrl,
                decoration: const InputDecoration(
                  labelText: 'sessionDate * (YYYY-MM-DD)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: const Text('favorite (create)'),
                value: _favoriteCreate,
                onChanged: _loading
                    ? null
                    : (v) => setState(() => _favoriteCreate = v),
              ),
              SwitchListTile(
                title: const Text('favorite (update)'),
                value: _favoriteUpdate,
                onChanged: _loading
                    ? null
                    : (v) => setState(() => _favoriteUpdate = v),
              ),
              TextField(
                controller: _resultsJsonCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'resultsJson (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _roastStyleNotesCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'roastStyleNotes (opcional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _sessionIdCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'sessionId (get / update / delete)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              if (_loading) const LinearProgressIndicator(),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: _loading ? null : _createSession,
                child: const Text('Create session'),
              ),
              ElevatedButton(
                onPressed: _loading ? null : _loadSessions,
                child: const Text('List my sessions'),
              ),
              OutlinedButton(
                onPressed: _loading ? null : _getById,
                child: const Text('Get by id'),
              ),
              OutlinedButton(
                onPressed: _loading ? null : _updateSession,
                child: const Text('Update session'),
              ),
              OutlinedButton(
                onPressed: _loading ? null : _deleteSession,
                child: const Text('Delete session'),
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
