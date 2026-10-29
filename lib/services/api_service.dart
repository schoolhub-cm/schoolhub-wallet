// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;

  ApiResponse({required this.success, this.data, this.error});
}

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Uri _uri(String endpoint) {
    final base = AppConfig.activeBaseUrl;
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;
    return Uri.parse('$base/$cleanEndpoint');
  }

  // --- Authentification ---

  Future<ApiResponse<Map<String, dynamic>>> register({
    required String phoneNumber,
    required String nom,
    required String prenom,
    required String password,
    required String pinCode,
    String? email,
    String? dateNaissance,
    String? sexe,
  }) async {
    try {
      final res = await http.post(
        _uri('register/'),
        headers: _headers,
        body: jsonEncode({
          'phone_number': phoneNumber,
          'nom': nom,
          'prenom': prenom,
          'password': password,
          'pin_code': pinCode,
          if (email != null && email.isNotEmpty) 'email': email,
          if (dateNaissance != null && dateNaissance.isNotEmpty) 'date_naissance': dateNaissance,
          if (sexe != null && sexe.isNotEmpty) 'sexe': sexe,
        }),
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 200 || res.statusCode == 201) {
        return ApiResponse(success: true, data: body);
      }
      return ApiResponse(success: false, error: body['error'] ?? 'Échec de l\'inscription.');
    } catch (e) {
      return ApiResponse(success: false, error: 'Connexion impossible au serveur : $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final res = await http.post(
        _uri('login/'),
        headers: _headers,
        body: jsonEncode({
          'phone_number': phoneNumber,
          'password': password,
        }),
      );

      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return ApiResponse(success: true, data: body);
      }
      return ApiResponse(success: false, error: body['error'] ?? 'Numéro ou mot de passe incorrect.');
    } catch (e) {
      return ApiResponse(success: false, error: 'Erreur de connexion : $e');
    }
  }

  // --- Vérification Email ---

  Future<ApiResponse<Map<String, dynamic>>> verifyEmail(String code) async {
    try {
      final res = await http.post(
        _uri('verify-email/'),
        headers: _headers,
        body: jsonEncode({'code': code}),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return ApiResponse(success: true, data: body);
      }
      return ApiResponse(success: false, error: body['error'] ?? 'Code invalide.');
    } catch (e) {
      return ApiResponse(success: false, error: '$e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> resendEmailCode({String? email}) async {
    try {
      final res = await http.post(
        _uri('resend-email-code/'),
        headers: _headers,
        body: jsonEncode({if (email != null) 'email': email}),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return ApiResponse(success: true, data: body);
      }
      return ApiResponse(success: false, error: body['error'] ?? 'Impossible de renvoyer le code.');
    } catch (e) {
      return ApiResponse(success: false, error: '$e');
    }
  }

  // --- PIN ---

  Future<ApiResponse<Map<String, dynamic>>> setPin({required String pinCode, String? oldPin}) async {
    try {
      final res = await http.post(
        _uri('set-pin/'),
        headers: _headers,
        body: jsonEncode({
          'pin_code': pinCode,
          if (oldPin != null) 'old_pin': oldPin,
        }),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return ApiResponse(success: true, data: body);
      }
      return ApiResponse(success: false, error: body['error'] ?? 'Erreur PIN.');
    } catch (e) {
      return ApiResponse(success: false, error: '$e');
    }
  }

  // --- Wallet & Transactions ---

  Future<ApiResponse<Map<String, dynamic>>> getWalletInfo() async {
    try {
      final res = await http.get(_uri('wallet/'), headers: _headers);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return ApiResponse(success: true, data: body);
      }
      return ApiResponse(success: false, error: body['error'] ?? 'Erreur chargement.');
    } catch (e) {
      return ApiResponse(success: false, error: '$e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> rechargeDirect({
    required double montant,
    required String phoneNumber,
    required String operator,
  }) async {
    try {
      final res = await http.post(
        _uri('recharge/'),
        headers: _headers,
        body: jsonEncode({
          'montant': montant,
          'phone_number': phoneNumber,
          'operator': operator,
        }),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return ApiResponse(success: true, data: body);
      }
      return ApiResponse(success: false, error: body['error'] ?? 'Erreur lors de la recharge.');
    } catch (e) {
      return ApiResponse(success: false, error: '$e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> checkTransaction(int transId) async {
    try {
      final res = await http.get(_uri('check-transaction/$transId/'), headers: _headers);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return ApiResponse(success: true, data: body);
      }
      return ApiResponse(success: false, error: body['error'] ?? 'Erreur vérification.');
    } catch (e) {
      return ApiResponse(success: false, error: '$e');
    }
  }

  Future<ApiResponse<List<dynamic>>> getTransactionsHistory({String? type}) async {
    try {
      var uri = _uri('transactions/');
      if (type != null && type.isNotEmpty) {
        uri = uri.replace(queryParameters: {'type': type});
      }
      final res = await http.get(uri, headers: _headers);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200 && body['transactions'] != null) {
        return ApiResponse(success: true, data: body['transactions'] as List<dynamic>);
      }
      return ApiResponse(success: false, error: body['error'] ?? 'Erreur historique.');
    } catch (e) {
      return ApiResponse(success: false, error: '$e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> debiter({
    required double montant,
    required String pinCode,
    String description = 'Paiement',
  }) async {
    try {
      final res = await http.post(
        _uri('debiter/'),
        headers: _headers,
        body: jsonEncode({
          'montant': montant,
          'pin_code': pinCode,
          'description': description,
        }),
      );
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return ApiResponse(success: true, data: body);
      }
      return ApiResponse(success: false, error: body['error'] ?? 'Paiement refusé.');
    } catch (e) {
      return ApiResponse(success: false, error: '$e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getProfile() async {
    try {
      final res = await http.get(_uri('profile/'), headers: _headers);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return ApiResponse(success: true, data: body);
      }
      return ApiResponse(success: false, error: body['error'] ?? 'Erreur profil.');
    } catch (e) {
      return ApiResponse(success: false, error: '$e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> getAuditReport() async {
    try {
      final res = await http.get(_uri('audit/'), headers: _headers);
      final body = jsonDecode(res.body);
      if (res.statusCode == 200) {
        return ApiResponse(success: true, data: body);
      }
      return ApiResponse(success: false, error: body['error'] ?? 'Erreur lors du rapport d’audit.');
    } catch (e) {
      return ApiResponse(success: false, error: '$e');
    }
  }
}
