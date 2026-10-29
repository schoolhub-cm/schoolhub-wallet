// lib/models/wallet_model.dart

class WalletModel {
  final String cardNumber;
  final double balance;
  final double verifiedBalance;
  final bool isTamperDetected;
  final String integrityStatus;
  final String currency;
  final bool isActive;
  final String holderName;
  final String phoneNumber;
  final String? phoneProvider;

  WalletModel({
    required this.cardNumber,
    required this.balance,
    required this.verifiedBalance,
    required this.isTamperDetected,
    required this.integrityStatus,
    required this.currency,
    required this.isActive,
    required this.holderName,
    required this.phoneNumber,
    this.phoneProvider,
  });

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    final bal = (json['balance'] is num) ? (json['balance'] as num).toDouble() : 0.0;
    final verBal = (json['verified_balance'] is num) 
        ? (json['verified_balance'] as num).toDouble() 
        : bal;

    return WalletModel(
      cardNumber: json['card_number'] ?? '',
      balance: bal,
      verifiedBalance: verBal,
      isTamperDetected: json['is_tamper_detected'] ?? false,
      integrityStatus: json['integrity_status'] ?? 'CERTIFIE_CONFORME',
      currency: json['currency'] ?? 'XAF',
      isActive: json['is_active'] ?? false,
      holderName: json['holder_name'] ?? 'Titulaire Wallet Hub',
      phoneNumber: json['phone_number'] ?? '',
      phoneProvider: json['phone_provider'],
    );
  }

  /// Retourne le numéro complet bien formé (ex: SCH-236B-B7CA-67C1)
  String get formattedCardNumber => cardNumber;

  /// Retourne le numéro masqué sécurisé (ex: SCH-••••-••••-67C1)
  String get maskedCardNumber {
    if (cardNumber.startsWith('SCH-') && cardNumber.length >= 17) {
      final lastPart = cardNumber.substring(cardNumber.length - 4);
      return 'SCH-••••-••••-$lastPart';
    }
    if (cardNumber.length > 4) {
      final last4 = cardNumber.substring(cardNumber.length - 4);
      return '•••• •••• •••• $last4';
    }
    return cardNumber;
  }
}
