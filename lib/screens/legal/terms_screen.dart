// lib/screens/legal/terms_screen.dart

import 'package:flutter/material.dart';
import '../../config/theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Conditions d\'Utilisation'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conditions Générales d\'Utilisation — Wallet Hub',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Dernière mise à jour : 29 Octobre 2026',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            _buildTermItem(
              '1. Objet du Service',
              'Wallet Hub est un service financier numérique édité par SchoolHub SARL permettant aux parents, élèves et enseignants d\'effectuer des paiements scolaires, de gérer leur budget et de recharger via Mobile Money (MTN MoMo, Orange Money).',
            ),
            _buildTermItem(
              '2. Numéro de Carte Virtuelle SCH-',
              'Chaque utilisateur se voit attribuer un numéro de carte virtuelle unique commençant par le préfixe SCH- (ex: SCH-XXXX-XXXX-XXXX). Ce numéro identifie de manière univoque votre compte de paiement dans le réseau scolaire.',
            ),
            _buildTermItem(
              '3. Sécurité du Code PIN',
              'L\'utilisateur est seul responsable de la confidentialité de son code PIN à 4 chiffres. Toute opération validée avec ce code PIN est réputée initiée par le titulaire du compte.',
            ),
            _buildTermItem(
              '4. Recharges & Débits',
              'Les recharges sont effectuées en monnaie locale (Franc CFA - XAF) sans frais cachés. Les invites USSD envoyées sur votre téléphone nécessitent la saisie de votre code Mobile Money opérateur.',
            ),
            _buildTermItem(
              '5. Lutte contre la Fraude',
              'Toute tentative de manipulation frauduleuse du solde entraîne la suspension immédiate du compte et le signalement aux autorités compétentes camerounaises.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermItem(String title, String body) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
