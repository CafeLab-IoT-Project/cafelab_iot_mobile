import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/subscription_plan.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_scaffold.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/data/cupping_sessions_repository_impl.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/cupping_sessions_repository.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/domain/models/create_cupping_session_request.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/widgets/cupping_session_form_fields.dart';
import 'package:cafelab_iot_mobile/features/cupping_sessions/presentation/widgets/cupping_sessions_common.dart';
import 'package:cafelab_iot_mobile/features/production/roast_profiles/presentation/widgets/roast_profiles_common.dart';
import 'package:cafelab_iot_mobile/features/production/shared/production_api_exception.dart';
import 'package:flutter/material.dart';

class CuppingSessionFormPage extends StatefulWidget {
  const CuppingSessionFormPage({
    super.key,
    required this.planType,
  });

  final SubscriptionPlanType planType;

  @override
  State<CuppingSessionFormPage> createState() => _CuppingSessionFormPageState();
}

class _CuppingSessionFormPageState extends State<CuppingSessionFormPage> {
  final CuppingSessionsRepository _repository = CuppingSessionsRepositoryImpl();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _varietyController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final Map<String, String> _fieldErrors = <String, String>{};

  String _processing = cuppingProcessingOptions.first;
  DateTime? _sessionDate = DateTime.now();
  String? _submitError;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _originController.dispose();
    _varietyController.dispose();
    _notesController.dispose();
    super.dispose();
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

  CreateCuppingSessionRequest? _validateForm() {
    _fieldErrors.clear();

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

    if (_fieldErrors.isNotEmpty || _sessionDate == null) {
      return null;
    }

    return CreateCuppingSessionRequest(
      name: name,
      origin: origin,
      variety: variety,
      processing: _processing,
      sessionDate: _sessionDate!,
      roastStyleNotes: notes.isEmpty ? null : notes,
    );
  }

  Future<void> _submit() async {
    final request = _validateForm();
    if (request == null) {
      setState(() => _submitError = null);
      return;
    }

    setState(() {
      _submitError = null;
      _isSubmitting = true;
    });

    try {
      await _repository.create(request);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ProductionApiException catch (error) {
      setState(() {
        _submitError = error.userMessage;
        _isSubmitting = false;
      });
    } catch (error) {
      setState(() {
        _submitError = 'Error inesperado: $error';
        _isSubmitting = false;
      });
    }
  }

  void _goBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AuthenticatedScaffold(
      onFeatures: _goBack,
      body: ColoredBox(
        color: AuthColors.profileScreenBackground,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        style: secondaryPillButtonStyle(),
                        onPressed: _isSubmitting ? null : _goBack,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                        label: const Text('Volver'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Nueva sesión de cata',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF3E4234),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      height: 2,
                      width: 180,
                      color: const Color(0xFF706E61),
                    ),
                    const SizedBox(height: 24),
                    CuppingSectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
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
                            enabled: !_isSubmitting,
                          ),
                          if (_submitError != null) ...[
                            const SizedBox(height: 14),
                            MessageBanner(
                              message: _submitError!,
                              backgroundColor: const Color(0xFFF8D9D9),
                              foregroundColor: const Color(0xFF8C1D1D),
                            ),
                          ],
                          const SizedBox(height: 22),
                          Align(
                            alignment: Alignment.center,
                            child: SizedBox(
                              width: 220,
                              child: AuthPrimaryButton(
                                label: 'Crear sesión',
                                isLoading: _isSubmitting,
                                onPressed: _isSubmitting ? null : _submit,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
