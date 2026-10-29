// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wallet_user.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService api = ApiService();

  static const int sessionTimeoutMinutes = 30; // 30 minutes max par session (sécurité bancaire)

  String? _token;
  WalletUser? _currentUser;
  DateTime? _loginTime;
  bool _initialized = false;
  bool _hasSeenOnboarding = false;

  String? get token => _token;
  WalletUser? get currentUser => _currentUser;
  DateTime? get loginTime => _loginTime;

  bool get isSessionExpired {
    if (_token == null || _loginTime == null) return false;
    return DateTime.now().difference(_loginTime!).inMinutes >= sessionTimeoutMinutes;
  }

  bool get isAuthenticated => _token != null && _currentUser != null && !isSessionExpired;
  bool get initialized => _initialized;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _hasSeenOnboarding = prefs.getBool('wallet_has_seen_onboarding') ?? false;
    _token = prefs.getString('wallet_token');

    final loginTimeMs = prefs.getInt('wallet_login_time');
    if (loginTimeMs != null) {
      _loginTime = DateTime.fromMillisecondsSinceEpoch(loginTimeMs);
      // Règle de sécurité : expiration après 30 minutes max
      if (DateTime.now().difference(_loginTime!).inMinutes >= sessionTimeoutMinutes) {
        await logout();
        _initialized = true;
        notifyListeners();
        return;
      }
    }

    final userJson = prefs.getString('wallet_user');
    if (_token != null && userJson != null) {
      try {
        _currentUser = WalletUser.fromJson(jsonDecode(userJson));
        api.setToken(_token);
      } catch (_) {
        _token = null;
        _currentUser = null;
      }
    }
    _initialized = true;
    notifyListeners();
  }

  /// Vérifie si la session est expirée (utilisé avant les actions sensibles)
  bool checkAndHandleExpiry() {
    if (isSessionExpired) {
      logout();
      return true;
    }
    return false;
  }

  Future<void> setHasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('wallet_has_seen_onboarding', true);
    _hasSeenOnboarding = true;
    notifyListeners();
  }

  Future<void> saveSession({required String token, required Map<String, dynamic> userMap}) async {
    final prefs = await SharedPreferences.getInstance();
    _token = token;
    _currentUser = WalletUser.fromJson(userMap);
    _loginTime = DateTime.now();
    api.setToken(token);

    await prefs.setString('wallet_token', token);
    await prefs.setString('wallet_user', jsonEncode(userMap));
    await prefs.setInt('wallet_login_time', _loginTime!.millisecondsSinceEpoch);
    notifyListeners();
  }

  void updateCurrentUser(WalletUser user) async {
    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wallet_user', jsonEncode(user.toJson()));
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('wallet_token');
    await prefs.remove('wallet_user');
    await prefs.remove('wallet_login_time');
    _token = null;
    _currentUser = null;
    _loginTime = null;
    api.setToken(null);
    notifyListeners();
  }
}
