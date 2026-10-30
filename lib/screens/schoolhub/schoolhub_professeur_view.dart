// lib/screens/schoolhub/schoolhub_professeur_view.dart
// Vue Professeur : informations et services SchoolHub pour enseignants

import 'package:flutter/material.dart';

class SchoolHubProfesseurView extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onRefresh;

  const SchoolHubProfesseurView({
    super.key,
    required this.data,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final profNom = data['professeur_nom'] ?? 'Professeur';
    final email = data['schoolhub_email'] ?? '';

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: const Color(0xFF4F46E5),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.school_rounded, color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Espace Enseignant', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                      Text(profNom, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800)),
                      Text(email, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_rounded, color: Colors.white, size: 12),
                      SizedBox(width: 4),
                      Text('Prof', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Services Enseignant',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),
          _buildFeatureCard(
            Icons.account_balance_wallet_rounded,
            "Réception d'honoraires & primes",
            "Recevez vos paiements de vacations directement sur votre Wallet Hub.",
            const Color(0xFF10B981),
          ),
          _buildFeatureCard(
            Icons.menu_book_rounded,
            "Ressources Pédagogiques SchoolHub",
            "Accédez aux épreuves, corrigés et outils pédagogiques de votre établissement.",
            const Color(0xFF4F46E5),
          ),
          _buildFeatureCard(
            Icons.security_rounded,
            "Sécurité Anti-Arnaque",
            "Chaque transaction et versement d'heures est certifié cryptographiquement.",
            const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF1E293B))),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
