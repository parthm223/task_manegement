import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static SharedPreferences? _prefs;
  
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  static String? getString(String key) {
    return _prefs?.getString(key);
  }
  
  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }
  
  static bool? getBool(String key) {
    return _prefs?.getBool(key);
  }
  
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }
  
  static int? getInt(String key) {
    return _prefs?.getInt(key);
  }
  
  static Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }
  
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }
  
  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }
}

