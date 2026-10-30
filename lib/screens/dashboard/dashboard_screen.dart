// lib/screens/dashboard/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/wallet_model.dart';
import '../../models/transaction_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/virtual_card.dart';
import '../../widgets/transaction_tile.dart';
import '../recharge/recharge_screen.dart';
import '../transactions/history_screen.dart';
import '../profile/profile_screen.dart';
import '../legal/security_audit_screen.dart';
import '../about/about_screen.dart';
import '../schoolhub/schoolhub_screen.dart';
import '../auth/login_screen.dart';
import '../../services/wallet_update_service.dart';
import '../../widgets/update_dialog.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  WalletModel? _wallet;
  List<TransactionModel> _recentTransactions = [];
  double _totalRecharges = 0;
  double _totalPaiements = 0;
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAutomaticUpdate();
    });
  }

  Future<void> _checkAutomaticUpdate() async {
    final update = await WalletUpdateService().checkForUpdate();
    if (!mounted || update == null) return;
    if (update.hasUpdate && update.downloadUrl != null) {
      await WalletUpdateDialog.showUpdatePrompt(context, update);
    }
  }

  Future<void> _loadDashboardData() async {
    // Vérification d'expiration de session (règle 30 min)
    final expired = AuthService().checkAndHandleExpiry();
    if (expired) {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⏱️ Session expirée (30 min). Reconnectez-vous pour continuer.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final res = await AuthService().api.getWalletInfo();

    if (!mounted) return;

    // Vérification 401 (token expiré côté serveur)
    if (res.error?.contains('401') == true || res.error?.toLowerCase().contains('token') == true || res.error?.toLowerCase().contains('non autorisé') == true) {
      await AuthService().logout();
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔐 Session expirée. Veuillez vous reconnecter.'),
          backgroundColor: Color(0xFFDC2626),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (res.success && res.data != null) {
      final walletJson = res.data!['wallet'] as Map<String, dynamic>;
      final transList = (res.data!['recent_transactions'] as List<dynamic>?) ?? [];
      final stats = res.data!['stats'] as Map<String, dynamic>?;

      setState(() {
        _wallet = WalletModel.fromJson(walletJson);
        _recentTransactions = transList
            .map((item) => TransactionModel.fromJson(item as Map<String, dynamic>))
            .toList();
        if (stats != null) {
          _totalRecharges = (stats['total_recharges'] as num?)?.toDouble() ?? 0;
          _totalPaiements = (stats['total_paiements'] as num?)?.toDouble() ?? 0;
        }
        _loading = false;
      });
    } else {
      setState(() {
        _errorMessage = res.error ?? 'Erreur lors du chargement.';
        _loading = false;
      });
    }
  }

  void _openRecharge() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RechargeScreen(onRechargeSuccess: _loadDashboardData),
      ),
    );
  }

  void _openDebiterDialog() {
    final montantController = TextEditingController();
    final descController = TextEditingController();
    final pinController = TextEditingController();
    String? err;
    bool inProgress = false;
    String selectedCategory = 'Cantine';
    final categories = ['Cantine', 'Fournitures', 'Transport', 'Inscription', 'Autre'];
    final presets = [500, 1000, 2500, 5000];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 8,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 20),
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.payments_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 14),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Effectuer un paiement',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF0F172A)),
                      ),
                      Text(
                        'Sécurisé par votre code PIN',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Error banner
              if (err != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(err!, style: const TextStyle(color: Color(0xFFDC2626), fontSize: 13))),
                    ],
                  ),
                ),

              // Montant field
              const Text('Montant', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 8),
              TextField(
                controller: montantController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                decoration: InputDecoration(
                  hintText: '0',
                  suffixText: 'FCFA',
                  suffixStyle: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF6366F1)),
                  prefixIcon: const Icon(Icons.monetization_on_rounded, color: Color(0xFF6366F1)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                ),
              ),
              const SizedBox(height: 12),

              // Preset amount chips
              Wrap(
                spacing: 8,
                children: presets.map((amount) {
                  return GestureDetector(
                    onTap: () => setDState(() => montantController.text = amount.toString()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFC7D2FE)),
                      ),
                      child: Text(
                        '$amount FCFA',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF4F46E5)),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),

              // Catégorie
              const Text('Catégorie', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((cat) {
                    final isSelected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () {
                        setDState(() {
                          selectedCategory = cat;
                          descController.text = cat;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0)),
                        ),
                        child: Text(
                          cat,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? Colors.white : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              // Description
              TextField(
                controller: descController,
                decoration: InputDecoration(
                  hintText: 'Description du paiement',
                  prefixIcon: const Icon(Icons.edit_note_rounded, color: Color(0xFF6366F1)),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 1.5)),
                ),
              ),
              const SizedBox(height: 16),

              // Code PIN
              const Text('Code PIN secret', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
              const SizedBox(height: 8),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                maxLength: 4,
                obscureText: true,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 12),
                decoration: InputDecoration(
                  hintText: '• • • •',
                  hintStyle: const TextStyle(fontSize: 18, letterSpacing: 8, color: Color(0xFFCBD5E1)),
                  counterText: '',
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2)),
                ),
              ),
              const SizedBox(height: 24),

              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 54,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    onPressed: inProgress
                        ? null
                        : () async {
                            final amt = double.tryParse(montantController.text.trim());
                            final desc = descController.text.trim();
                            final pin = pinController.text.trim();

                            if (amt == null || amt <= 0) {
                              setDState(() => err = 'Veuillez saisir un montant valide.');
                              return;
                            }
                            if (pin.length != 4) {
                              setDState(() => err = 'Le code PIN doit comporter exactement 4 chiffres.');
                              return;
                            }

                            setDState(() { inProgress = true; err = null; });

                            final res = await AuthService().api.debiter(
                              montant: amt,
                              pinCode: pin,
                              description: desc.isNotEmpty ? desc : 'Paiement',
                            );

                            setDState(() => inProgress = false);

                            if (res.success) {
                              Navigator.of(ctx).pop();
                              _loadDashboardData();
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Row(
                                    children: [
                                      Icon(Icons.check_circle, color: Colors.white, size: 20),
                                      SizedBox(width: 10),
                                      Text('Paiement effectué avec succès !', style: TextStyle(fontWeight: FontWeight.w700)),
                                    ],
                                  ),
                                  backgroundColor: const Color(0xFF10B981),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            } else {
                              setDState(() => err = res.error ?? 'Erreur lors du paiement.');
                            }
                          },
                    child: inProgress
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.lock_rounded, size: 18, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Confirmer le paiement',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                ).then((_) => setState(() {}));
              },
              child: CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primary,
                child: Text(
                  (user?.prenom.isNotEmpty == true ? user!.prenom[0] : 'U').toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bonjour,',
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                Text(
                  user?.prenom ?? 'Utilisateur',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textDark),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
            onPressed: _loadDashboardData,
            tooltip: 'Actualiser',
          ),
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.primary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
            tooltip: 'À propos',
          ),
          IconButton(
            icon: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              ).then((_) => setState(() {}));
            },
            tooltip: 'Mon Profil',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. CARTE VIRTUELLE TITANIUM
              VirtualCardWidget(
                wallet: _wallet,
                onRechargeTap: _openRecharge,
              ),
              const SizedBox(height: 16),

              // 2. BANNIÈRE ANTI-ARNAQUE & GRAND LIVRE
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SecurityAuditScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.accentGreen.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.security_rounded, color: AppColors.accentGreen, size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bouclier Anti-Arnaque Actif',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                            ),
                            Text(
                              'Solde 100% certifié par Grand Livre scellé',
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: AppColors.accentGreen),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // BANNIÈRE ESPACE SCHOOLHUB
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SchoolHubScreen()),
                  ).then((_) => _loadDashboardData());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEEF2FF), Color(0xFFF5F3FF)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFC7D2FE)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4F46E5).withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.school_rounded, color: Color(0xFF4F46E5), size: 20),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Espace Scolaire SchoolHub',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark),
                            ),
                            Text(
                              'Pensions scolaires, abonnements & enfants',
                              style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: Color(0xFF4F46E5)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 3. ACTIONS RAPIDES (Recharger, Payer, Historique, Audit)
              Row(
                children: [
                  Expanded(
                    child: _actionButton(
                      icon: Icons.bolt_rounded,
                      label: 'Recharger',
                      color: AppColors.orangeMomo,
                      onTap: _openRecharge,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Payer',
                      color: AppColors.accent,
                      onTap: _openDebiterDialog,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.history_rounded,
                      label: 'Historique',
                      color: AppColors.primaryLight,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const HistoryScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _actionButton(
                      icon: Icons.verified_user_rounded,
                      label: 'Anti-Fraude',
                      color: AppColors.accentGreen,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SecurityAuditScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. STATISTIQUES FINANCIÈRES
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.arrow_downward_rounded, size: 14, color: AppColors.accentGreen),
                              SizedBox(width: 4),
                              Text('Total Rechargé', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_totalRecharges.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 35, color: Colors.grey.shade200),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.arrow_upward_rounded, size: 14, color: AppColors.error),
                              SizedBox(width: 4),
                              Text('Total Dépensé', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${_totalPaiements.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.textDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 5. TRANSACTIONS RÉCENTES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Activités récentes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                    },
                    child: const Text('Tout voir', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (_loading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_errorMessage != null)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(_errorMessage!, style: const TextStyle(color: AppColors.textMuted)),
                        const SizedBox(height: 10),
                        ElevatedButton(onPressed: _loadDashboardData, child: const Text('Réessayer')),
                      ],
                    ),
                  ),
                )
              else if (_recentTransactions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long_outlined, size: 36, color: Colors.grey.shade400),
                        const SizedBox(height: 10),
                        const Text(
                          'Aucune transaction pour l’instant',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.textDark),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Rechargez votre compte pour effectuer vos premiers paiements.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._recentTransactions.map((t) => TransactionTile(transaction: t)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
