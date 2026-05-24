import 'package:cafelab_iot_mobile/features/auth/domain/models/authenticated_user.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/sign_in_request.dart';
import 'package:cafelab_iot_mobile/features/auth/domain/models/sign_up_request.dart';

abstract class AuthRepository {
  Future<AuthenticatedUser> signIn(SignInRequest request);
  Future<void> registerProfile(SignUpRequest request);
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> clearToken();
}
