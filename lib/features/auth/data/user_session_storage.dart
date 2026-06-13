import 'package:shared_preferences/shared_preferences.dart';

class UserSessionStorage {
  static const _emailKey = 'session_user_email';
  static const _profileIdKey = 'session_profile_id';
  static const _planKey = 'session_profile_plan';
  static const _hasPlanKey = 'session_profile_has_plan';

  Future<void> saveEmail(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email.trim());
  }

  Future<String?> getEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  Future<void> saveProfileState({
    required int profileId,
    required String plan,
    required bool hasPlan,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_profileIdKey, profileId);
    await prefs.setString(_planKey, plan);
    await prefs.setBool(_hasPlanKey, hasPlan);
  }

  Future<int?> getProfileId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_profileIdKey);
  }

  Future<String?> getPlan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_planKey);
  }

  Future<bool?> getHasPlan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasPlanKey);
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_profileIdKey);
    await prefs.remove(_planKey);
    await prefs.remove(_hasPlanKey);
  }

  Future<void> clearEmail() => clearSession();
}
