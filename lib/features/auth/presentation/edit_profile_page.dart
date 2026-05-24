import 'package:cafelab_iot_mobile/features/auth/data/user_session_storage.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/models/auth_user_role.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/dashboard_features.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/dashboard_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/select_plans_onboarding_page.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/utils/edit_profile_validators.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_api_error_banner.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_header.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/auth_primary_button.dart';
import 'package:cafelab_iot_mobile/features/profiles/application/profile_uniqueness_service.dart';
import 'package:cafelab_iot_mobile/features/profiles/data/profile_api_service.dart';
import 'package:cafelab_iot_mobile/features/profiles/domain/models/profile_model.dart';
import 'package:cafelab_iot_mobile/features/profiles/domain/models/update_profile_request.dart';
import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({
    super.key,
    required this.userRole,
  });

  final AuthUserRole userRole;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _cafeteriaNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _profileApiService = ProfileApiService();
  final _uniquenessService = ProfileUniquenessService();
  final _sessionStorage = UserSessionStorage();

  ProfileModel? _profile;
  bool _isLoadingProfile = true;
  bool _isSaving = false;
  String _apiError = '';
  Map<String, String> _fieldErrors = {};

  bool get _isOwner => widget.userRole == AuthUserRole.owner;

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
    super.dispose();
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
      final sessionEmail = await _sessionStorage.getEmail();
      if (sessionEmail == null || sessionEmail.isEmpty) {
        throw const ProfileApiException(
          'No hay correo de sesión. Inicia sesión o regístrate de nuevo.',
        );
      }

      final profile = await _profileApiService.getProfileByEmail(sessionEmail);
      if (!mounted) return;

      _profile = profile;
      _splitFullName(profile.name);
      _emailController.text = profile.email;
      _cafeteriaNameController.text = profile.cafeteriaName;
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

  Future<void> _saveAndContinue() async {
    final fieldErrors = EditProfileValidators.validate(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      email: _emailController.text,
      isOwner: _isOwner,
      cafeteriaName: _cafeteriaNameController.text,
    );

    if (fieldErrors.isNotEmpty) {
      setState(() {
        _fieldErrors = fieldErrors;
        _apiError = '';
      });
      return;
    }

    final profile = _profile;
    if (profile == null) {
      setState(() {
        _apiError = 'Perfil no cargado. Intenta de nuevo.';
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
        validateCafeteria: _isOwner,
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

    final updatedEmail = _emailController.text.trim();
    final request = UpdateProfileRequest(
      name: _combinedFullName(),
      email: updatedEmail,
      cafeteriaName: _isOwner ? _cafeteriaNameController.text.trim() : profile.cafeteriaName,
      experience: profile.experience,
      paymentMethod: profile.paymentMethod,
      isFirstLogin: false,
      plan: profile.plan,
      hasPlan: profile.hasPlan,
    );

    try {
      final updatedProfile = await _profileApiService.updateProfile(
        profileId: profile.id,
        request: request,
      );
      await _sessionStorage.saveEmail(updatedProfile.email);
      await _sessionStorage.saveProfileState(
        profileId: updatedProfile.id,
        plan: updatedProfile.plan,
        hasPlan: updatedProfile.hasPlan,
      );

      if (!mounted) return;
      if (updatedProfile.hasPlan) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute<void>(
            builder: (_) => DashboardPage(
              planType: DashboardFeatures.planTypeFromApi(updatedProfile.plan),
            ),
          ),
          (_) => false,
        );
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SelectPlansOnboardingPage(userRole: widget.userRole),
        ),
      );
    } on ProfileApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _apiError = e.displayMessage;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _apiError = 'Error inesperado al guardar el perfil.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBusy = _isLoadingProfile || _isSaving;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AuthHeader(),
          Expanded(
            child: ColoredBox(
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
                        _ProfileFieldRow(
                          label: 'Nombres',
                          controller: _firstNameController,
                          enabled: !isBusy,
                          errorText: _fieldErrors['firstName'],
                        ),
                        const SizedBox(height: 20),
                        if (_isOwner) ...[
                          _ProfileFieldRow(
                            label: 'Nombre de Cafetería',
                            controller: _cafeteriaNameController,
                            enabled: !isBusy,
                            errorText: _fieldErrors['cafeteriaName'],
                          ),
                          const SizedBox(height: 20),
                        ],
                        _ProfileFieldRow(
                          label: 'Apellidos',
                          controller: _lastNameController,
                          enabled: !isBusy,
                          errorText: _fieldErrors['lastName'],
                        ),
                        const SizedBox(height: 20),
                        _ProfileFieldRow(
                          label: 'Email',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          enabled: !isBusy,
                          errorText: _fieldErrors['email'],
                        ),
                        const SizedBox(height: 32),
                        AuthPrimaryButton(
                          label: 'Guardar',
                          isLoading: _isSaving,
                          onPressed: isBusy ? null : _saveAndContinue,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileFieldRow extends StatelessWidget {
  const _ProfileFieldRow({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.enabled = true,
    this.errorText,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final bool enabled;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null && errorText!.isNotEmpty;

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
        TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: keyboardType,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
          ),
          decoration: InputDecoration(
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
