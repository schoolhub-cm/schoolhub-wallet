// lib/screens/legal/privacy_policy_screen.dart

import 'package:flutter/material.dart';
import '../../config/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Confidentialité & Sécurité"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Engagement SchoolHub",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Protection intégrale de vos données scolaires et de vos fonds financiers.",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _buildSection(
              icon: Icons.account_balance_wallet_rounded,
              title: "1. Système Financier & Sécurité Anti-Arnaque",
              content:
                  "Wallet Hub utilise une technologie propriétaire de Grand Livre Cryptographique scellé par empreintes HMAC/SHA-256.\n\n"
                  "• Intégrité garantie : Le solde de votre compte est certifié par réconciliation systématique de l'historique de vos recharges et paiements. Aucune altération extérieure de solde n'est possible.\n"
                  "• Agrégateur officiel : Les transactions de recharge Mobile Money (MTN MoMo et Orange Money) transitent de manière chiffrée par nos partenaires financiers agréés par la COBAC et le MINPOSTEL au Cameroun.\n"
                  "• Non-conservation des codes PIN : Wallet Hub et SchoolHub ne stockent jamais vos codes secrets Mobile Money.",
            ),

            _buildSection(
              icon: Icons.school_rounded,
              title: "2. Écosystème SchoolHub Cameroun",
              content:
                  "Le portefeuille Wallet Hub est étroitement interconnecté avec la plateforme scolaire SchoolHub pour faciliter le paiement instantané des frais de scolarité, cantine, cours de répétition et examens sans frais cachés.\n\n"
                  "Les parents d'élèves, élèves et enseignants disposent d'une traçabilité totale avec reçu numérique instantané délivré pour chaque transaction.",
            ),

            _buildSection(
              icon: Icons.fingerprint_rounded,
              title: "3. Protection des Données Personnelles",
              content:
                  "Conformément à la Loi camerounaise N° 2010/012 du 21 décembre 2010 relative à la cybersécurité et à la cybercriminalité :\n\n"
                  "• Vos informations (nom, numéro de téléphone, email) sont exclusivement réservées à l'identification et à la sécurisation de votre compte.\n"
                  "• Aucune donnée n'est cédée, vendue ou louée à des tiers.\n"
                  "• Vous pouvez demander la modification ou suppression de votre compte en contactant le support technique.",
            ),

            _buildSection(
              icon: Icons.lock_clock_rounded,
              title: "4. Chiffrement & Authentification",
              content:
                  "Toutes les communications entre votre téléphone et nos serveurs sont protégées par le protocole sécurisé SSL/TLS 256 bits.\n\n"
                  "L'accès à votre compte et la validation de tout paiement nécessitent votre code PIN secret à 4 chiffres scellé.",
            ),

            _buildSection(
              icon: Icons.support_agent_rounded,
              title: "5. Contact & Assistance Technique",
              content:
                  "SchoolHub SARL - Yaoundé / Douala, Cameroun\n"
                  "Support technique : support@schoolhub.cm\n"
                  "Site web officiel : https://schoolhub.cm",
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textDark,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 13,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }
}
