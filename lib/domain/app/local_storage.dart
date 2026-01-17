import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _fcmTokenKey = 'fcm_token';

  // Singleton
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> saveToken(String token) async {
    await _prefs?.setString(_tokenKey, token);
  }

  String? getToken() {
    return _prefs?.getString(_tokenKey);
  }

  Future<void> saveUser(Map<String, dynamic> user) async {
    await _prefs?.setString(_userKey, jsonEncode(user));
  }

  Map<String, dynamic>? getUser() {
    final userStr = _prefs?.getString(_userKey);
    if (userStr != null) {
      return jsonDecode(userStr);
    }
    return null;
  }

  Future<void> clear() async {
    await _prefs?.clear();
  }

  Future<void> saveFcmToken(String token) async {
    await _prefs?.setString(_fcmTokenKey, token);
  }

  String? getFcmToken() {
    return _prefs?.getString(_fcmTokenKey);
  }
}
