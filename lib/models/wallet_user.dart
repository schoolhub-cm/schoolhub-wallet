// lib/models/wallet_user.dart

class WalletUser {
  final int id;
  final String phoneNumber;
  final String nom;
  final String prenom;
  final String fullName;
  final String email;
  final bool emailVerified;
  final String? dateNaissance;
  final String? sexe;
  final bool hasPin;

  WalletUser({
    required this.id,
    required this.phoneNumber,
    required this.nom,
    required this.prenom,
    required this.fullName,
    required this.email,
    required this.emailVerified,
    this.dateNaissance,
    this.sexe,
    required this.hasPin,
  });

  factory WalletUser.fromJson(Map<String, dynamic> json) {
    return WalletUser(
      id: json['id'] ?? 0,
      phoneNumber: json['phone_number'] ?? '',
      nom: json['nom'] ?? '',
      prenom: json['prenom'] ?? '',
      fullName: json['full_name'] ?? '${json['prenom'] ?? ''} ${json['nom'] ?? ''}'.trim(),
      email: json['email'] ?? '',
      emailVerified: json['email_verified'] ?? false,
      dateNaissance: json['date_naissance'],
      sexe: json['sexe'],
      hasPin: json['has_pin'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'phone_number': phoneNumber,
    'nom': nom,
    'prenom': prenom,
    'full_name': fullName,
    'email': email,
    'email_verified': emailVerified,
    'date_naissance': dateNaissance,
    'sexe': sexe,
    'has_pin': hasPin,
  };
}
