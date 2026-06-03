import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyCnic = 'cnic';
  static const _keyFullName = 'full_name';
  static const _keyRole = 'role';
  static const _keyCitizenId = 'citizen_id';

  /// Save session after successful login
  static Future<void> saveSession({
    required String cnic,
    required String fullName,
    required String role,
    required int citizenId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCnic, cnic);
    await prefs.setString(_keyFullName, fullName);
    await prefs.setString(_keyRole, role);
    await prefs.setInt(_keyCitizenId, citizenId);
  }

  static Future<String?> getCnic() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCnic);
  }

  static Future<String?> getFullName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyFullName);
  }

  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyRole);
  }

  static Future<int?> getCitizenId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyCitizenId);
  }

  /// Clear session on logout
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final cnic = await getCnic();
    return cnic != null && cnic.isNotEmpty;
  }
}
