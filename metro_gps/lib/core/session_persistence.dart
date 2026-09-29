import 'package:shared_preferences/shared_preferences.dart';

/// Guarda el JWT de `smart_session` en disco (móvil / escritorio).
abstract final class SessionPersistence {
  static const _keyToken = 'smart_session_token';
  static const _keyCookie = 'smart_session_cookie';

  static Future<String?> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_keyToken);
    if (token != null && token.trim().isNotEmpty) return token.trim();

    // Fallback: Si existía una sesión previa guardada como cookie
    final cookie = prefs.getString(_keyCookie);
    if (cookie != null && cookie.trim().isNotEmpty) {
      const prefix = 'smart_session=';
      var raw = cookie.trim();
      if (raw.startsWith(prefix)) {
        raw = raw.substring(prefix.length).trim();
      }
      if (raw.isNotEmpty) {
        await prefs.setString(_keyToken, raw);
        return raw;
      }
    }
    return null;
  }

  static Future<void> saveToken(String token) async {
    final clean = token.trim();
    if (clean.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyToken, clean);
    await prefs.setString(_keyCookie, 'smart_session=$clean');
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyToken);
    await prefs.remove(_keyCookie);
  }
}
