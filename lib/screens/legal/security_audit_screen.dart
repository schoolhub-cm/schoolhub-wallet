// lib/screens/legal/security_audit_screen.dart

import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';

class SecurityAuditScreen extends StatefulWidget {
  const SecurityAuditScreen({super.key});

  @override
  State<SecurityAuditScreen> createState() => _SecurityAuditScreenState();
}

class _SecurityAuditScreenState extends State<SecurityAuditScreen> {
  final _apiService = AuthService().api;
  bool _loading = true;
  Map<String, dynamic>? _cert;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAudit();
  }

  Future<void> _loadAudit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final res = await _apiService.getAuditReport();
    if (!mounted) return;

    if (res.success && res.data != null) {
      setState(() {
        _cert = res.data!['certificate'];
        _loading = false;
      });
    } else {
      setState(() {
        _error = res.error ?? 'Impossible de générer le rapport.';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Audit Anti-Arnaque & Ledger'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded, size: 50, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadAudit,
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Badge de certification
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.accentGreen.withOpacity(0.5), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accentGreen.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.accentGreen.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified_user_rounded,
                                color: AppColors.accentGreen,
                                size: 42,
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _cert?['statut_integrite'] ?? 'CERTIFIÉ CONFORME',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.accentGreen,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _cert?['certificate_number'] ?? 'CERT-SCH-XXXX',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                                fontFamily: 'monospace',
                                letterSpacing: 1.1,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Divider(color: Colors.white24),
                            const SizedBox(height: 14),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMiniStat(
                                  'Solde Certifié',
                                  '${(_cert?['solde_certifie'] ?? 0).toStringAsFixed(0)} FCFA',
                                  AppColors.accentCyan,
                                ),
                                _buildMiniStat(
                                  'Transactions Scellées',
                                  '${_cert?['transactions_scellees'] ?? 0} / ${_cert?['total_transactions'] ?? 0}',
                                  Colors.white,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Carte explicative du bouclier anti-arnaque
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.lock_person_rounded, color: Colors.amber.shade900, size: 22),
                                ),
                                const SizedBox(width: 12),
                                const Expanded(
                                  child: Text(
                                    'Comment fonctionne l\'Anti-Arnaque ?',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.textDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildFeatureRow(
                              Icons.block_rounded,
                              'Interdiction des modifications arbitraires',
                              'Personne (ni pirate, ni admin) ne peut altérer votre solde directement. Tout solde non justifié par une transaction est immédiatement rejeté.',
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureRow(
                              Icons.history_edu_rounded,
                              'Grand Livre Double Entrée',
                              'Votre solde réel est recalculé en temps réel à partir de la somme exacte de vos recharges validées moins vos paiements.',
                            ),
                            const SizedBox(height: 12),
                            _buildFeatureRow(
                              Icons.key_rounded,
                              'Signatures Cryptographiques SHA-256',
                              'Chaque transaction possède une empreinte numérique infalsifiable enregistrée sur les serveurs SchoolHub.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Bouton d'actualisation
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _loadAudit,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Re-vérifier l\'intégrité du compte'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
    );
  }

  Widget _buildMiniStat(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
