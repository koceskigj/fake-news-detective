import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const _progressKey = 'user_progress_v1';

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

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressKey);
  }
}
