import 'package:cafelab_iot_mobile/features/auth/presentation/constants/profile_constants.dart';
import 'package:cafelab_iot_mobile/features/profiles/data/profile_api_service.dart';
import 'package:cafelab_iot_mobile/features/profiles/domain/models/profile_model.dart';

class ProfileUniquenessService {
  ProfileUniquenessService({ProfileApiService? profileApiService})
      : _profileApiService = profileApiService ?? ProfileApiService();

  final ProfileApiService _profileApiService;

  Future<Map<String, String>> validateChangedFields({
    required ProfileModel currentProfile,
    required String email,
    required String cafeteriaName,
    required bool validateCafeteria,
  }) async {
    final errors = <String, String>{};
    final trimmedEmail = email.trim();
    final originalEmail = currentProfile.email.trim();

    if (trimmedEmail.toLowerCase() != originalEmail.toLowerCase()) {
      final emailAvailable = await _profileApiService.isEmailAvailable(
        email: trimmedEmail,
        excludeProfileId: currentProfile.id,
      );
      if (!emailAvailable) {
        errors['email'] = 'Este correo ya está registrado.';
      }
    }

    if (!validateCafeteria) {
      return errors;
    }

    final trimmedCafeteria = cafeteriaName.trim();
    final originalCafeteria = currentProfile.cafeteriaName.trim();
    if (trimmedCafeteria.isEmpty ||
        trimmedCafeteria.toLowerCase() ==
            ProfileConstants.cafeteriaNotConfirmed) {
      return errors;
    }

    if (trimmedCafeteria.toLowerCase() == originalCafeteria.toLowerCase()) {
      return errors;
    }

    final cafeteriaAvailable = await _profileApiService.isCafeteriaNameAvailable(
      cafeteriaName: trimmedCafeteria,
      excludeProfileId: currentProfile.id,
    );
    if (!cafeteriaAvailable) {
      errors['cafeteriaName'] = 'Este nombre de cafetería ya está registrado.';
    }

    return errors;
  }
}
