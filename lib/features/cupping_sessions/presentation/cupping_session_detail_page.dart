import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_scaffold.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/data/cupping_sessions_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/cupping_sessions_repository.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/cupping_session.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/sensory_scores.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/update_cupping_session_request.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/widgets/cupping_session_form_fields.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/widgets/cupping_sessions_common.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/widgets/sensory_hexagon_chart.dart';
import 'package:cafelab_iot_mobile/features/defects/presentation/defect_library_page.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/widgets/roast_profiles_common.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/material.dart';

class CuppingSessionDetailPage extends StatefulWidget {
  const CuppingSessionDetailPage({
    super.key,
    required this.sessionId,
    required this.planType,
    this.onSessionUpdated,
  });

  final int sessionId;
  final SubscriptionPlanType planType;
  final ValueChanged<CuppingSession>? onSessionUpdated;

  @override
  State<CuppingSessionDetailPage> createState() => _CuppingSessionDetailPageState();
}

class _CuppingSessionDetailPageState extends State<CuppingSessionDetailPage> {
  final CuppingSessionsRepository _repository = CuppingSessionsRepositoryImpl();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final Map<String, String> _fieldErrors = <String, String>{};

  CuppingSession? _session;
  SensoryScores _scores = SensoryScores.empty;
  String _processing = cuppingProcessingOptions.first;
  DateTime? _sessionDate;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _originController.dispose();
    _varietyController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadSession() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final session = await _repository.getById(widget.sessionId);
      _applySession(session);
      setState(() => _isLoading = false);
    } on ProductionApiException catch (error) {
      setState(() {
        _errorMessage = error.userMessage;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Error inesperado: $error';
        _isLoading = false;
      });
    }
  }

  void _applySession(CuppingSession session) {
    _session = session;
    _nameController.text = session.name;
    _originController.text = session.origin;
    _varietyController.text = session.variety;
    _notesController.text = session.roastStyleNotes ?? '';
    _processing = session.processing.isEmpty ? cuppingProcessingOptions.first : session.processing;
    _sessionDate = session.sessionDate;
    _scores = SensoryScores.fromResultsJson(session.resultsJson);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _sessionDate ?? now,
      firstDate: DateTime(now.year - 10),
      lastDate: DateTime(now.year + 10),
    );
    if (picked != null) {
      setState(() => _sessionDate = picked);
    }
  }

  UpdateCuppingSessionRequest? _validateForm() {
    _fieldErrors.clear();

    final session = _session;
    final name = _nameController.text.trim();
    final origin = _originController.text.trim();
    final variety = _varietyController.text.trim();
    final notes = _notesController.text.trim();

    if (name.isEmpty) {
      _fieldErrors['name'] = 'Ingresa el nombre de la sesión.';
    }
    if (origin.isEmpty) {
      _fieldErrors['origin'] = 'Ingresa el origen.';
    }
    if (variety.isEmpty) {
      _fieldErrors['variety'] = 'Ingresa la variedad.';
    }
    if (_processing.trim().isEmpty) {
      _fieldErrors['processing'] = 'Selecciona un procesamiento.';
    }
    if (_sessionDate == null) {
      _fieldErrors['sessionDate'] = 'Selecciona la fecha de la sesión.';
    }
    if (!_scores.isValid) {
      _fieldErrors['resultsJson'] = 'Los valores sensoriales deben estar entre 0 y 10.';
    }

    if (_fieldErrors.isNotEmpty || _sessionDate == null || session == null) {
      return null;
    }

    return UpdateCuppingSessionRequest(
      name: name,
      origin: origin,
      variety: variety,
      processing: _processing,
      sessionDate: _sessionDate!,
      favorite: session.favorite,
      resultsJson: _scores.toResultsJson(),
      roastStyleNotes: notes.isEmpty ? null : notes,
    );
  }

  Future<void> _saveSession() async {
    final session = _session;
    final request = _validateForm();
    if (session == null || request == null) {
      setState(() {});
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final updated = await _repository.update(session.id, request);
      _applySession(updated);
      widget.onSessionUpdated?.call(updated);
      if (!mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Sesión de cata guardada correctamente.')),
        );
      setState(() => _isSaving = false);
    } on ProductionApiException catch (error) {
      setState(() {
        _errorMessage = error.userMessage;
        _isSaving = false;
      });
    } catch (error) {
      setState(() {
        _errorMessage = 'Error inesperado: $error';
        _isSaving = false;
      });
    }
  }

  void _updateScore(String key, double value) {
    setState(() {
      _scores = switch (key) {
        'aroma' => _scores.copyWith(aroma: value),
        'cuerpo' => _scores.copyWith(cuerpo: value),
        'acidez' => _scores.copyWith(acidez: value),
        'dulzor' => _scores.copyWith(dulzor: value),
        'amargor' => _scores.copyWith(amargor: value),
        'postgusto' => _scores.copyWith(postgusto: value),
        _ => _scores,
      };
    });
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  void _openDefectLibrary() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DefectLibraryPage(planType: widget.planType),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedScaffold(
      onFeatures: _goBack,
      body: ColoredBox(
        color: AuthColors.profileScreenBackground,
        child: SafeArea(
          top: false,
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: AuthColors.primary),
                )
              : _errorMessage != null && _session == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MessageBanner(
                          message: _errorMessage!,
                          backgroundColor: const Color(0xFFF8D9D9),
                          foregroundColor: const Color(0xFF8C1D1D),
                        ),
                        const SizedBox(height: 16),
                        AuthPrimaryButton(
                          label: 'Reintentar',
                          onPressed: _loadSession,
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Inicio > Sesiones de cata > ${_session?.name ?? ''}',
                        style: const TextStyle(
                          color: Color(0xFF4E5342),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton(
                          style: secondaryPillButtonStyle(),
                          onPressed: _isSaving ? null : _goBack,
                          child: const Text('Volver'),
                        ),
                      ),
                      const SizedBox(height: 18),
                      if (_errorMessage != null) ...[
                        MessageBanner(
                          message: _errorMessage!,
                          backgroundColor: const Color(0xFFF8D9D9),
                          foregroundColor: const Color(0xFF8C1D1D),
                        ),
                        const SizedBox(height: 12),
                      ],
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth >= 980;
                          final left = _buildSensorySection();
                          final right = _buildSessionDataSection();

                          if (!isWide) {
                            return Column(
                              children: [
                                left,
                                const SizedBox(height: 16),
                                right,
                              ],
                            );
                          }

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 6, child: left),
                              const SizedBox(width: 18),
                              Expanded(flex: 5, child: right),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSensorySection() {
    return CuppingSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Evaluación sensorial',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF314131),
            ),
          ),
          const SizedBox(height: 22),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 720;
              final sliders = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _SensorySliderRow(
                    label: 'Aroma',
                    value: _scores.aroma,
                    onChanged: (value) => _updateScore('aroma', value),
                  ),
                  _SensorySliderRow(
                    label: 'Cuerpo',
                    value: _scores.cuerpo,
                    onChanged: (value) => _updateScore('cuerpo', value),
                  ),
                  _SensorySliderRow(
                    label: 'Acidez',
                    value: _scores.acidez,
                    onChanged: (value) => _updateScore('acidez', value),
                  ),
                  _SensorySliderRow(
                    label: 'Dulzor',
                    value: _scores.dulzor,
                    onChanged: (value) => _updateScore('dulzor', value),
                  ),
                  _SensorySliderRow(
                    label: 'Amargor',
                    value: _scores.amargor,
                    onChanged: (value) => _updateScore('amargor', value),
                  ),
                  _SensorySliderRow(
                    label: 'Postgusto',
                    value: _scores.postgusto,
                    onChanged: (value) => _updateScore('postgusto', value),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 220,
                    child: AuthPrimaryButton(
                      label: 'Generar hexágono sensorial',
                      onPressed: () {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            const SnackBar(
                              content: Text('Hexágono sensorial actualizado.'),
                            ),
                          );
                      },
                    ),
                  ),
                ],
              );
              final chart = Column(
                children: [
                  Center(
                    child: SizedBox(
                      width: 310,
                      child: SensoryHexagonChart(
                        scores: _scores,
                        fillColor: const Color(0x668B9F97),
                        strokeColor: const Color(0xFF4D5E54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '¿Detectó algún defecto en la degustación?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3E4234),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: 230,
                    child: OutlinedButton(
                      style: secondaryPillButtonStyle(),
                      onPressed: _openDefectLibrary,
                      child: const Text('Biblioteca de defectos'),
                    ),
                  ),
                ],
              );

              if (!isWide) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    sliders,
                    const SizedBox(height: 16),
                    chart,
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: sliders),
                  const SizedBox(width: 18),
                  Expanded(flex: 4, child: chart),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSessionDataSection() {
    return CuppingSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Datos de la sesión',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF314131),
            ),
          ),
          const SizedBox(height: 20),
          CuppingSessionFormFields(
            nameController: _nameController,
            originController: _originController,
            varietyController: _varietyController,
            notesController: _notesController,
            selectedProcessing: _processing,
            selectedDate: _sessionDate,
            onProcessingChanged: (value) {
              if (value != null) {
                setState(() => _processing = value);
              }
            },
            onPickDate: _pickDate,
            fieldErrors: _fieldErrors,
            enabled: !_isSaving,
          ),
          if (_fieldErrors['resultsJson'] != null) ...[
            const SizedBox(height: 8),
            Text(
              _fieldErrors['resultsJson']!,
              style: const TextStyle(
                color: Color(0xFFB3261E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 22),
          AuthPrimaryButton(
            label: 'Guardar sesión',
            isLoading: _isSaving,
            onPressed: _isSaving ? null : _saveSession,
          ),
        ],
      ),
    );
  }
}

class _SensorySliderRow extends StatelessWidget {
  const _SensorySliderRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF2E2E2E),
              ),
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: const Color(0xFF1B6BD8),
                inactiveTrackColor: const Color(0xFFD8E5F9),
                thumbColor: const Color(0xFF1B6BD8),
                overlayColor: const Color(0x331B6BD8),
                trackHeight: 4,
              ),
              child: Slider(
                value: value.clamp(0, 10),
                min: 0,
                max: 10,
                divisions: 10,
                onChanged: onChanged,
              ),
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 30,
            child: Text(
              value.toStringAsFixed(0),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2F3D2E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
