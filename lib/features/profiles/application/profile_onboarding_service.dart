import 'package:cafelab_iot_mobile/features/auth/data/token_storage_service.dart';
import 'package:cafelab_iot_mobile/features/auth/data/user_session_storage.dart';
import 'package:cafelab_iot_mobile/features/profiles/data/profile_api_service.dart';
import 'package:cafelab_iot_mobile/features/profiles/domain/models/profile_model.dart';
import 'package:cafelab_iot_mobile/features/profiles/domain/models/update_profile_request.dart';

class ProfileOnboardingService {
  ProfileOnboardingService({
    ProfileApiService? profileApiService,
    UserSessionStorage? sessionStorage,
    TokenStorageService? tokenStorage,
  })  : _profileApiService = profileApiService ?? ProfileApiService(),
        _sessionStorage = sessionStorage ?? UserSessionStorage(),
        _tokenStorage = tokenStorage ?? TokenStorageService();

  final ProfileApiService _profileApiService;
  final UserSessionStorage _sessionStorage;
  final TokenStorageService _tokenStorage;

  Future<bool> hasActiveSession() async {
    final token = await _tokenStorage.getToken();
    final email = await _sessionStorage.getEmail();
    return token != null &&
        token.isNotEmpty &&
        email != null &&
        email.isNotEmpty;
  }

  Future<ProfileModel> fetchCurrentProfile() async {
    final email = await _sessionStorage.getEmail();
    if (email == null || email.isEmpty) {
      throw const ProfileApiException(
        'No hay sesión activa. Inicia sesión de nuevo.',
      );
    }
    final profile = await _profileApiService.getProfileByEmail(email);
    await _sessionStorage.saveProfileState(
      profileId: profile.id,
      plan: profile.plan,
      hasPlan: profile.hasPlan,
    );
    return profile;
  }

  Future<ProfileModel> assignSelectedPlan({
    required ProfileModel profile,
    required String plan,
  }) async {
    final updated = await _profileApiService.updateProfile(
      profileId: profile.id,
      request: UpdateProfileRequest(
        name: profile.name,
        email: profile.email,
        cafeteriaName: profile.cafeteriaName,
        experience: profile.experience,
        paymentMethod: profile.paymentMethod,
        isFirstLogin: profile.isFirstLogin,
        plan: plan,
        hasPlan: false,
      ),
    );
    await _sessionStorage.saveProfileState(
      profileId: updated.id,
      plan: updated.plan,
      hasPlan: updated.hasPlan,
    );
    return updated;
  }

  Future<ProfileModel> completePayment({
    required ProfileModel profile,
    required String paymentMethod,
    String? planOverride,
  }) async {
    final updated = await _profileApiService.updateProfile(
      profileId: profile.id,
      request: UpdateProfileRequest(
        name: profile.name,
        email: profile.email,
        cafeteriaName: profile.cafeteriaName,
        experience: profile.experience,
        paymentMethod: paymentMethod,
        isFirstLogin: false,
        plan: planOverride ?? profile.plan,
        hasPlan: true,
      ),
    );
    await _sessionStorage.saveProfileState(
      profileId: updated.id,
      plan: updated.plan,
      hasPlan: updated.hasPlan,
    );
    return updated;
  }
}
