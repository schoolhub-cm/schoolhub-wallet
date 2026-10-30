// lib/screens/about/about_screen.dart
// Présentation officielle de Wallet Hub : fun, vivante et animée

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;
  late final Animation<double> _pulseAnim;

  bool _cardFlipped = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);

    _fadeIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.10), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _pulseAnim = Tween<double>(begin: 0.96, end: 1.04)
        .animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 310,
              pinned: true,
              backgroundColor: const Color(0xFF4F46E5),
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(background: _buildAnimatedHero()),
              title: const Text(
                'À propos de Wallet Hub',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16),
              ),
              centerTitle: true,
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeIn,
                child: SlideTransition(
                  position: _slideUp,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildMissionCard(),
                        const SizedBox(height: 24),

                        // Démonstrateur interactif de carte virtuelle
                        _section('💳 Votre Carte Virtuelle Titanium'),
                        const SizedBox(height: 12),
                        _buildInteractiveCardDemo(),
                        const SizedBox(height: 28),

                        _section('⚡ Fonctionnalités Clés'),
                        const SizedBox(height: 14),
                        _buildFeatureGrid(),
                        const SizedBox(height: 28),

                        _section('🛡️ Bouclier Anti-Arnaque & Sécurité'),
                        const SizedBox(height: 14),
                        _buildSecurityCard(),
                        const SizedBox(height: 28),

                        _section('📊 Wallet Hub en Chiffres'),
                        const SizedBox(height: 14),
                        _buildAnimatedStatsRow(),
                        const SizedBox(height: 28),

                        _section('💎 Nos Valeurs & Engagements'),
                        const SizedBox(height: 14),
                        _buildValuesList(),
                        const SizedBox(height: 28),

                        _section('🚀 Comment ça marche ?'),
                        const SizedBox(height: 14),
                        _buildStepsList(),
                        const SizedBox(height: 28),

                        _buildFooter(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero animé et vivant ───────────────────────────────────────────────────

  Widget _buildAnimatedHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4338CA), Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          // Orbes flottants animés
          AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (ctx, child) {
              return Stack(
                children: [
                  Positioned(
                    right: -20 + (_pulseCtrl.value * 25),
                    top: -20 - (_pulseCtrl.value * 15),
                    child: _orb(220, Colors.cyanAccent, 0.20),
                  ),
                  Positioned(
                    left: -30 - (_pulseCtrl.value * 20),
                    bottom: -30 + (_pulseCtrl.value * 20),
                    child: _orb(190, Colors.pinkAccent, 0.18),
                  ),
                  Positioned(
                    right: 40,
                    bottom: 20 + (_pulseCtrl.value * 10),
                    child: _orb(90, Colors.amberAccent, 0.15),
                  ),
                ],
              );
            },
          ),

          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ScaleTransition(
                      scale: _pulseAnim,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFFFFF), Color(0xFFEEF2FF)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.18),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            'assets/images/wallet_logo.png',
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.account_balance_wallet_rounded,
                              color: Color(0xFF4F46E5),
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Wallet Hub',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'by SchoolHub Cameroon 🇨🇲',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.35)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Portefeuille Officiel & Inviolable',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(double size, Color color, double opacity) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: RadialGradient(colors: [color.withOpacity(opacity), Colors.transparent]),
    ),
  );

  // ── Mission Card ──────────────────────────────────────────────────────────

  Widget _buildMissionCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4F46E5), Color(0xFF6366F1), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4F46E5).withOpacity(0.30),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag_rounded, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text('Notre Mission', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Wallet Hub révolutionne la finance scolaire au Cameroun. '
            'Nous offrons aux élèves, parents et établissements une solution '
            'digitale ultra-rapide, sécurisée et sans friction pour régler '
            'les pensions, cantines et abonnements scolaires.',
            style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 13.5, height: 1.6, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill(Icons.school_rounded, 'Éducation Numérique'),
              _pill(Icons.shield_rounded, 'Anti-Arnaque Scellé'),
              _pill(Icons.bolt_rounded, 'MTN & Orange MoMo'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.18),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withOpacity(0.30)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white, size: 12),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
      ],
    ),
  );

  // ── Démonstrateur de Carte Virtuelle ──────────────────────────────────────

  Widget _buildInteractiveCardDemo() {
    return GestureDetector(
      onTap: () => setState(() => _cardFlipped = !_cardFlipped),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: _cardFlipped
              ? const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)])
              : const LinearGradient(colors: [Color(0xFF1E1B4B), Color(0xFF312E81), Color(0xFF4338CA)]),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.25),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 26,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFDE68A), Color(0xFFD97706)]),
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.wifi, color: Colors.white54, size: 18),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.touch_app_rounded, color: Colors.amberAccent, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        _cardFlipped ? 'Voir Recto' : 'Toucher pour retourner',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            if (!_cardFlipped) ...[
              const Text(
                'SCH-XXXX-XXXX-XXXX',
                style: TextStyle(
                  fontFamily: 'monospace',
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 16),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('TITULAIRE', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w600)),
                      Text('VOTRE NOM & PRÉNOM', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('SOLDE SCELLÉ', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w600)),
                      Text('CERTIFIÉ 100%', style: TextStyle(color: Color(0xFF34D399), fontSize: 12, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ],
              ),
            ] else ...[
              Container(height: 32, color: Colors.black54),
              const SizedBox(height: 12),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('CVV Holographique : ***', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text('Puce EMV & NFC', style: TextStyle(color: Color(0xFF38BDF8), fontSize: 11, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Section Title ─────────────────────────────────────────────────────────

  Widget _section(String title) => Text(
    title,
    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Color(0xFF0F172A), letterSpacing: -0.3),
  );

  // ── Feature Grid ──────────────────────────────────────────────────────────

  Widget _buildFeatureGrid() {
    final f = [
      ['Recharge Express', 'MTN MoMo & Orange Money sans redirection', Icons.bolt_rounded, const Color(0xFFFF7900)],
      ['Paiements Pensions', 'Tranches scolaires certifiées avec reçu', Icons.payments_rounded, const Color(0xFF4F46E5)],
      ['Anti-Arnaque Scellé', 'Solde inviolable calculé en double-entrée', Icons.security_rounded, const Color(0xFF10B981)],
      ['Carte SCH Virtuelle', 'Votre identifiant unique SCH-XXXX', Icons.credit_card_rounded, const Color(0xFF06B6D4)],
      ['Liaison Multi-Rôles', 'Parents, Établissements & Enseignants', Icons.link_rounded, const Color(0xFF8B5CF6)],
      ['PIN Sécurisé', 'Validation stricte à chaque transaction', Icons.pin_rounded, const Color(0xFFF59E0B)],
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: List.generate(f.length, (i) {
        final item = f[i];
        final icon = item[2] as IconData;
        final color = item[3] as Color;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                item[0] as String,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 3),
              Text(
                item[1] as String,
                style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.35),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      }),
    );
  }

  // ── Security Card ─────────────────────────────────────────────────────────

  Widget _buildSecurityCard() {
    final items = [
      (Icons.enhanced_encryption_rounded, 'Signature HMAC SHA-256', 'Chaque mouvement est signé cryptographiquement.'),
      (Icons.balance_rounded, 'Grand Livre Scellé', 'Calcul en double-entrée : aucune falsification possible.'),
      (Icons.timer_rounded, 'Session 30 Minutes Max', 'Déconnexion automatique pour protéger votre solde.'),
      (Icons.verified_user_rounded, 'Code PIN 4 Chiffres', 'Exigé à chaque débit ou paiement scolaire.'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(item.$1, color: const Color(0xFF10B981), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text(item.$3, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.4)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (i < items.length - 1)
                const Divider(height: 1, indent: 64, color: Color(0xFFF1F5F9)),
            ],
          );
        }),
      ),
    );
  }

  // ── Stats Row animées ─────────────────────────────────────────────────────

  Widget _buildAnimatedStatsRow() {
    return Row(
      children: [
        Expanded(child: _stat('100%', 'Sécurisé & Scellé', const Color(0xFF10B981))),
        const SizedBox(width: 10),
        Expanded(child: _stat('< 2s', 'Validation Instantanée', const Color(0xFF4F46E5))),
        const SizedBox(width: 10),
        Expanded(child: _stat('0 FCFA', 'Frais Cachés', const Color(0xFF06B6D4))),
      ],
    );
  }

  Widget _stat(String v, String l, Color c) => Container(
    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
    decoration: BoxDecoration(
      color: c.withOpacity(0.06),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: c.withOpacity(0.18)),
    ),
    child: Column(
      children: [
        Text(v, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: c), textAlign: TextAlign.center),
        const SizedBox(height: 4),
        Text(l, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: Color(0xFF64748B)), textAlign: TextAlign.center),
      ],
    ),
  );

  // ── Values List ───────────────────────────────────────────────────────────

  Widget _buildValuesList() {
    final v = [
      ('🎯', 'Simplicité', 'Activez votre wallet avec votre numéro de téléphone en 30 secondes.'),
      ('🔒', 'Intégrité', 'Votre solde est protégé contre toute manipulation non autorisée.'),
      ('⚡', 'Rapidité', 'Recharges et paiements en direct, sans quitter l\'application.'),
      ('🇨🇲', 'Fierté Locale', 'Une solution 100% pensée pour l\'écosystème scolaire camerounais.'),
    ];
    return Column(
      children: v.map((e) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Text(e.$1, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
                  const SizedBox(height: 2),
                  Text(e.$3, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B), height: 1.35)),
                ],
              ),
            ),
          ],
        ),
      )).toList(),
    );
  }

  // ── Steps List ────────────────────────────────────────────────────────────

  Widget _buildStepsList() {
    final steps = [
      'Inscrivez-vous avec votre numéro mobile en 30 secondes.',
      'Configurez votre code PIN secret à 4 chiffres.',
      'Rechargez votre compte via MTN Mobile Money ou Orange Money.',
      'Liez votre compte SchoolHub pour régler les pensions et abonnements.',
    ];
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: List.generate(steps.length, (i) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(steps[i], style: const TextStyle(fontSize: 12.5, color: Color(0xFF0F172A), height: 1.4, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
            if (i < steps.length - 1)
              const Divider(height: 1, indent: 54, color: Color(0xFFF1F5F9)),
          ],
        )),
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Wallet Hub', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w900)),
                  Text('SchoolHub Cameroon © 2026', style: TextStyle(color: Colors.white70, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.15), height: 1),
          const SizedBox(height: 14),
          Text(
            'Propulsé par SchoolHUB Technologies & Fapshi — Tous droits réservés.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white.withOpacity(0.60), fontSize: 11, height: 1.4),
          ),
        ],
      ),
    );
  }
}
