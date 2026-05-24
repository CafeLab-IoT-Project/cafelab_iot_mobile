import 'package:cafelab_iot_mobile/features/auth/data/user_session_storage.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/profile_constants.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/dashboard_features.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/dashboard_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/auth_user_role.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/plan_flow_mode.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/select_plans_session_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/utils/edit_profile_validators.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/utils/plan_display_labels.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/utils/profile_flow_navigation.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_api_error_banner.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_pill_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_scaffold.dart';
import 'package:cafelab_iot_mobile/features/profiles/application/profile_onboarding_service.dart';
import 'package:cafelab_iot_mobile/features/profiles/application/profile_uniqueness_service.dart';
import 'package:cafelab_iot_mobile/features/profiles/data/profile_api_service.dart';
import 'package:cafelab_iot_mobile/features/profiles/domain/models/profile_model.dart';
import 'package:cafelab_iot_mobile/features/profiles/domain/models/update_profile_request.dart';
import 'package:flutter/material.dart';

/// Editar perfil para usuario con sesión activa (menú hamburguesa → Perfil).
class EditProfileSessionPage extends StatefulWidget {
  const EditProfileSessionPage({super.key});

  @override
  State<EditProfileSessionPage> createState() => _EditProfileSessionPageState();
}

class _EditProfileSessionPageState extends State<EditProfileSessionPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cafeteriaNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _planController = TextEditingController();

  final _profileApiService = ProfileApiService();
  final _sessionStorage = UserSessionStorage();
  final _onboardingService = ProfileOnboardingService();
  final _uniquenessService = ProfileUniquenessService();

  ProfileModel? _profile;
  bool _isLoadingProfile = true;
  bool _isSaving = false;
  bool _cafeteriaConfirmed = false;
  bool _persistedNotConfirmedOnLeave = false;
  String _apiError = '';
  Map<String, String> _fieldErrors = {};

  @override
  void initState() {
    super.initState();
    _loadProfileFromBackend();
    _firstNameController.addListener(() => _clearFieldError('firstName'));
    _lastNameController.addListener(() => _clearFieldError('lastName'));
    _emailController.addListener(() => _clearFieldError('email'));
    _cafeteriaNameController.addListener(() => _clearFieldError('cafeteriaName'));
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cafeteriaNameController.dispose();
    _emailController.dispose();
    _planController.dispose();
    super.dispose();
  }

  AuthUserRole get _userRole {
    final role = _profile?.role ?? '';
    return ProfileFlowNavigation.roleFromProfile(role);
  }

  bool _isBaristaWithFullPlan(ProfileModel profile) {
    final role = profile.role.toLowerCase();
    final plan = profile.plan.toLowerCase();
    return role.contains('barista') && plan.contains('full');
  }

  bool _isOwnerRole(ProfileModel profile) {
    return profile.role.toLowerCase().contains('owner');
  }

  bool get _canEditCafeteria {
    final profile = _profile;
    if (profile == null) return false;
    return _isOwnerRole(profile) || _isBaristaWithFullPlan(profile);
  }

  bool get _requiresCafeteriaName {
    final profile = _profile;
    if (profile == null) return false;
    return _isOwnerRole(profile) || _isBaristaWithFullPlan(profile);
  }

  bool _cafeteriaNeedsConfirmation(ProfileModel profile) {
    return ProfileFlowNavigation.baristaFullPlanNeedsCafeteriaConfirmation(
      profile,
    );
  }

  bool get _mustPersistNotConfirmedOnLeave {
    final profile = _profile;
    if (profile == null || !_isBaristaWithFullPlan(profile)) return false;
    return !_cafeteriaConfirmed;
  }

  void _clearFieldError(String field) {
    if (!_fieldErrors.containsKey(field)) return;
    setState(() {
      _fieldErrors = Map<String, String>.from(_fieldErrors)..remove(field);
    });
  }

  void _splitFullName(String fullName) {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return;
    if (parts.length == 1) {
      _firstNameController.text = parts.first;
      _lastNameController.text = '';
      return;
    }
    _firstNameController.text = parts.first;
    _lastNameController.text = parts.sublist(1).join(' ');
  }

  String _combinedFullName() {
    return [
      _firstNameController.text.trim(),
      _lastNameController.text.trim(),
    ].where((part) => part.isNotEmpty).join(' ');
  }

  Future<void> _loadProfileFromBackend() async {
    setState(() {
      _isLoadingProfile = true;
      _apiError = '';
    });

    try {
      final profile = await _onboardingService.fetchCurrentProfile();
      if (!mounted) return;
      _persistedNotConfirmedOnLeave = false;
      _applyProfile(profile);
    } on ProfileApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = e.displayMessage;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _apiError = 'No se pudo cargar el perfil desde el backend.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingProfile = false;
        });
      }
    }
  }

  void _applyProfile(ProfileModel profile) {
    _profile = profile;
    _splitFullName(profile.name);
    _emailController.text = profile.email;
    _planController.text = PlanDisplayLabels.fromApiPlan(profile.plan);

    if (_canEditCafeteria) {
      final cafeteria = profile.cafeteriaName.trim();
      if (cafeteria.toLowerCase() == ProfileConstants.cafeteriaNotConfirmed) {
        _cafeteriaNameController.clear();
      } else {
        _cafeteriaNameController.text = cafeteria;
      }
    } else {
      _cafeteriaNameController.clear();
    }

    _cafeteriaConfirmed = !_cafeteriaNeedsConfirmation(profile);
    setState(() {});
  }

  Future<void> _saveProfile() async {
    final profile = _profile;
    if (profile == null) return;

    final fieldErrors = EditProfileValidators.validateSession(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      requiresCafeteria: _requiresCafeteriaName,
      cafeteriaName: _cafeteriaNameController.text,
    );

    if (fieldErrors.isNotEmpty) {
      setState(() {
        _fieldErrors = fieldErrors;
        _apiError = '';
      });
      return;
    }

    setState(() {
      _isSaving = true;
      _fieldErrors = {};
      _apiError = '';
    });

    try {
      final uniquenessErrors = await _uniquenessService.validateChangedFields(
        currentProfile: profile,
        email: _emailController.text,
        cafeteriaName: _cafeteriaNameController.text,
        validateCafeteria: _requiresCafeteriaName,
      );
      if (uniquenessErrors.isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _fieldErrors = uniquenessErrors;
          _isSaving = false;
        });
        return;
      }
    } on ProfileApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = e.displayMessage;
        _isSaving = false;
      });
      return;
    }

    final cafeteriaValue = _requiresCafeteriaName
        ? _cafeteriaNameController.text.trim()
        : profile.cafeteriaName;

    try {
      final updated = await _profileApiService.updateProfile(
        profileId: profile.id,
        request: UpdateProfileRequest(
          name: _combinedFullName(),
          email: _emailController.text.trim(),
          cafeteriaName: cafeteriaValue,
          experience: profile.experience,
          paymentMethod: profile.paymentMethod,
          isFirstLogin: false,
          plan: profile.plan,
          hasPlan: profile.hasPlan,
        ),
      );

      await _sessionStorage.saveEmail(updated.email);
      await _sessionStorage.saveProfileState(
        profileId: updated.id,
        plan: updated.plan,
        hasPlan: updated.hasPlan,
      );

      if (!mounted) return;
      _cafeteriaConfirmed = !_cafeteriaNeedsConfirmation(updated);
      _applyProfile(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente.')),
      );
    } on ProfileApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = e.displayMessage;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _apiError = 'Error al guardar el perfil.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _persistCafeteriaNotConfirmedIfNeeded() async {
    if (_persistedNotConfirmedOnLeave || !_mustPersistNotConfirmedOnLeave) {
      return;
    }

    final profile = _profile;
    if (profile == null) return;

    _persistedNotConfirmedOnLeave = true;

    try {
      final updated = await _profileApiService.updateProfile(
        profileId: profile.id,
        request: UpdateProfileRequest(
          name: profile.name,
          email: profile.email,
          cafeteriaName: ProfileConstants.cafeteriaNotConfirmed,
          experience: profile.experience,
          paymentMethod: profile.paymentMethod,
          isFirstLogin: false,
          plan: profile.plan,
          hasPlan: profile.hasPlan,
        ),
      );
      await _sessionStorage.saveProfileState(
        profileId: updated.id,
        plan: updated.plan,
        hasPlan: updated.hasPlan,
      );
      _profile = updated;
    } on ProfileApiException {
      _persistedNotConfirmedOnLeave = false;
    }
  }

  Future<void> _openChangePlan() async {
    await _persistCafeteriaNotConfirmedIfNeeded();
    if (!mounted) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SelectPlansSessionPage(
          userRole: _userRole,
          flowMode: PlanFlowMode.changePlan,
        ),
      ),
    );
    if (!mounted) return;
    await _loadProfileFromBackend();
  }

  Future<void> _goToDashboard() async {
    await _persistCafeteriaNotConfirmedIfNeeded();
    if (!mounted) return;
    final profile = _profile;
    if (profile == null || !profile.hasPlan) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(
        builder: (_) => DashboardPage(
          planType: DashboardFeatures.planTypeFromApi(profile.plan),
        ),
      ),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isLoadingProfile || _isSaving;
    final profile = _profile;
    final showVerified = profile?.hasPlan == true;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        await _persistCafeteriaNotConfirmedIfNeeded();
        if (!context.mounted) return;
        if (!didPop) {
          Navigator.of(context).pop();
        }
      },
      child: AuthenticatedScaffold(
        onFeatures: _goToDashboard,
        onProfile: null,
        onBeforeLogout: _persistCafeteriaNotConfirmedIfNeeded,
        body: ColoredBox(
        color: AuthColors.profileScreenBackground,
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Editar Perfil',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                ),
                const SizedBox(height: 28),
                if (_isLoadingProfile)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  if (_apiError.isNotEmpty) ...[
                    AuthApiErrorBanner(message: _apiError),
                    const SizedBox(height: 16),
                  ],
                  _SessionProfileField(
                    label: 'Nombres',
                    controller: _firstNameController,
                    enabled: !isBusy,
                    errorText: _fieldErrors['firstName'],
                  ),
                  const SizedBox(height: 20),
                  _SessionProfileField(
                    label: 'Nombre de Cafetería',
                    controller: _cafeteriaNameController,
                    enabled: !isBusy && _canEditCafeteria,
                    readOnlyHint: !_canEditCafeteria
                        ? 'Solo para plan dueño o completo'
                        : null,
                    helperText: profile != null &&
                            _isBaristaWithFullPlan(profile) &&
                            !_cafeteriaConfirmed
                        ? 'Obligatorio para plan completo. Confirma con Guardar.'
                        : null,
                    errorText: _fieldErrors['cafeteriaName'],
                  ),
                  const SizedBox(height: 20),
                  _SessionProfileField(
                    label: 'Apellidos',
                    controller: _lastNameController,
                    enabled: !isBusy,
                    errorText: _fieldErrors['lastName'],
                  ),
                  const SizedBox(height: 20),
                  _SessionProfileField(
                    label: 'Email',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isBusy,
                    errorText: _fieldErrors['email'],
                  ),
                  const SizedBox(height: 20),
                  _PlanActualSection(
                    planController: _planController,
                    showVerified: showVerified,
                    onChangePlan: isBusy ? null : _openChangePlan,
                  ),
                  const SizedBox(height: 32),
                  Align(
                    alignment: Alignment.centerRight,
                    child: AuthPrimaryButton(
                      label: 'Guardar',
                      isLoading: _isSaving,
                      onPressed: isBusy ? null : _saveProfile,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}

class _SessionProfileField extends StatelessWidget {
  const _SessionProfileField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.enabled = true,
    this.readOnlyHint,
    this.helperText,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final String? readOnlyHint;
  final String? helperText;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;
    final displayHint = !enabled && readOnlyHint != null ? readOnlyHint : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                readOnly: !enabled && readOnlyHint != null,
                keyboardType: keyboardType,
                style: TextStyle(
                  color: enabled
                      ? Colors.black87
                      : Colors.black.withValues(alpha: 0.45),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  hintText: displayHint,
                  hintStyle: TextStyle(
                    color: Colors.black.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasError ? Colors.red.shade300 : Colors.transparent,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: hasError ? Colors.red.shade400 : AuthColors.primary,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Material(
              color: AuthColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.edit_outlined,
                  color: AuthColors.primary,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        if (helperText != null && helperText!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: TextStyle(
              color: Colors.black.withValues(alpha: 0.55),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: TextStyle(
              color: Colors.red.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _PlanActualSection extends StatelessWidget {
  const _PlanActualSection({
    required this.planController,
    required this.showVerified,
    required this.onChangePlan,
  });

  final TextEditingController planController;
  final bool showVerified;
  final VoidCallback? onChangePlan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Plan actual',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: planController,
                readOnly: true,
                style: TextStyle(
                  color: Colors.black.withValues(alpha: 0.55),
                  fontSize: 15,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
            ),
            if (showVerified) ...[
              const SizedBox(width: 12),
              Text(
                'Verificado',
                style: TextStyle(
                  color: AuthColors.header,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        AuthPillButton(
          label: 'Cambiar Plan',
          onPressed: onChangePlan,
        ),
      ],
    );
  }
}
