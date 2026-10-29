// lib/models/transaction_model.dart

class TransactionModel {
  final int id;
  final String type;
  final String typeDisplay;
  final String statut;
  final String statutDisplay;
  final double montant;
  final double? balanceApres;
  final String reference;
  final String description;
  final String createdAt;

  TransactionModel({
    required this.id,
    required this.type,
    required this.typeDisplay,
    required this.statut,
    required this.statutDisplay,
    required this.montant,
    this.balanceApres,
    required this.reference,
    required this.description,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? 0,
      type: json['type'] ?? 'RECHARGE',
      typeDisplay: json['type_display'] ?? 'Transaction',
      statut: json['statut'] ?? 'EN_ATTENTE',
      statutDisplay: json['statut_display'] ?? 'En attente',
      montant: (json['montant'] is num) ? (json['montant'] as num).toDouble() : 0.0,
      balanceApres: json['balance_apres'] != null ? (json['balance_apres'] as num).toDouble() : null,
      reference: json['reference'] ?? '',
      description: json['description'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }

  bool get isRecharge => type == 'RECHARGE';
  bool get isSuccess => statut == 'SUCCES';
  bool get isPending => statut == 'EN_ATTENTE';
  bool get isFailed => statut == 'ECHEC' || statut == 'ANNULE';
}
