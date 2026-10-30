// lib/services/schoolhub_service.dart
// Service pour la liaison Wallet ↔ SchoolHub

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import 'auth_service.dart';
import '../config/app_config.dart';

class SchoolHubService {
  static final SchoolHubService _instance = SchoolHubService._internal();
  factory SchoolHubService() => _instance;
  SchoolHubService._internal();

  /// Retourne l'URL de la page web de liaison
  String getLinkUrl() {
    final token = AuthService().token ?? '';
    final base = AppConfig.activeRootUrl;
    const deepLink = 'schoolhubwallet%3A%2F%2Fschoolhub%2Fcallback';
    return '$base/wallet/auth/connect/?token=$token&redirect=$deepLink';
  }

  /// Soumet le code reçu après l'OAuth web pour finaliser la liaison
  Future<ApiResponse<Map<String, dynamic>>> submitLinkCode(String code) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConfig.activeBaseUrl}/schoolhub/connect/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (AuthService().token != null)
            'Authorization': 'Bearer ${AuthService().token}',
        },
        body: jsonEncode({'code': code}),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return ApiResponse(success: true, data: data);
      }
      return ApiResponse(success: false, error: data['error'] ?? 'Erreur lors de la liaison.');
    } catch (e) {
      return ApiResponse(success: false, error: 'Erreur réseau: $e');
    }
  }

  /// Récupère le statut et les données SchoolHub liées
  Future<ApiResponse<Map<String, dynamic>>> getStatus() async {
    try {
      final res = await http.get(
        Uri.parse('${AppConfig.activeBaseUrl}/schoolhub/status/'),
        headers: {
          'Accept': 'application/json',
          if (AuthService().token != null)
            'Authorization': 'Bearer ${AuthService().token}',
        },
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return ApiResponse(success: true, data: data);
    } catch (e) {
      return ApiResponse(success: false, error: 'Erreur réseau: $e');
    }
  }

  /// Paiement d'une tranche de pension scolaire
  Future<ApiResponse<Map<String, dynamic>>> payPension({
    required int eleveId,
    required int trancheId,
    required String pin,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConfig.activeBaseUrl}/schoolhub/pay-pension/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (AuthService().token != null)
            'Authorization': 'Bearer ${AuthService().token}',
        },
        body: jsonEncode({
          'eleve_id': eleveId,
          'tranche_id': trancheId,
          'pin': pin,
        }),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return ApiResponse(success: true, data: data);
      }
      return ApiResponse(success: false, error: data['error'] ?? 'Paiement échoué.');
    } catch (e) {
      return ApiResponse(success: false, error: 'Erreur réseau: $e');
    }
  }

  /// Paiement et activation d'un abonnement établissement
  Future<ApiResponse<Map<String, dynamic>>> paySubscription({
    required int offreId,
    required String pin,
  }) async {
    try {
      final res = await http.post(
        Uri.parse('${AppConfig.activeBaseUrl}/schoolhub/pay-subscription/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (AuthService().token != null)
            'Authorization': 'Bearer ${AuthService().token}',
        },
        body: jsonEncode({
          'offre_id': offreId,
          'pin': pin,
        }),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      if (res.statusCode == 200 && data['success'] == true) {
        return ApiResponse(success: true, data: data);
      }
      return ApiResponse(success: false, error: data['error'] ?? 'Activation échouée.');
    } catch (e) {
      return ApiResponse(success: false, error: 'Erreur réseau: $e');
    }
  }

  /// Supprimer la liaison
  Future<ApiResponse<Map<String, dynamic>>> unlink() async {
    try {
      final res = await http.post(
        Uri.parse('${AppConfig.activeBaseUrl}/schoolhub/unlink/'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (AuthService().token != null)
            'Authorization': 'Bearer ${AuthService().token}',
        },
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return ApiResponse(success: res.statusCode == 200, data: data);
    } catch (e) {
      return ApiResponse(success: false, error: 'Erreur réseau: $e');
    }
  }
}
