import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _progressKey = 'user_progress_v1';
  static const _userIdKey = 'stable_user_id';

  static Future<void> saveProgressJson(Map<String, dynamic> jsonMap) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(jsonMap);
    await prefs.setString(_progressKey, raw);
  }

  static Future<Map<String, dynamic>?> loadProgressJson() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressKey);
    if (raw == null || raw.isEmpty) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  static Future<String?> loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  static Future<void> saveUserId(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
  }

  static Future<void> clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
  }

  /// By default: clears progress but keeps stable userId (good for web).
  /// If you want a full reset (new identity), pass clearUserId: true.
  static Future<void> clearAll({bool clearUserId = false}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
    if (clearUserId) {
      await prefs.remove(_userIdKey);
    }
  }
}
