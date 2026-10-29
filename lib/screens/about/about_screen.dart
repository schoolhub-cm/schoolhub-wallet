// lib/screens/about/about_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeIn;
  late final Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _fadeIn = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 320,
              pinned: true,
              backgroundColor: AppColors.primary,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.of(context).pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(background: _buildHero()),
              title: const Text('À propos', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
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
                        const SizedBox(height: 28),
                        _section('🚀 Ce que Wallet Hub vous offre'),
                        const SizedBox(height: 14),
                        _buildFeatureGrid(),
                        const SizedBox(height: 28),
                        _section('🔐 Sécurité et Confiance'),
                        const SizedBox(height: 14),
                        _buildSecurityCard(),
                        const SizedBox(height: 28),
                        _section('📊 Wallet Hub en chiffres'),
                        const SizedBox(height: 14),
                        _buildStatsRow(),
                        const SizedBox(height: 28),
                        _section('💎 Nos valeurs'),
                        const SizedBox(height: 14),
                        _buildValuesList(),
                        const SizedBox(height: 28),
                        _section('⚙️ Comment ça marche ?'),
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

  // ── Hero ──────────────────────────────────────────────────────────────────────

  Widget _buildHero() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0A0F1D), Color(0xFF1E293B), Color(0xFF0F172A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Positioned(right: -40, top: -40, child: _orb(200, const Color(0xFF0284C7), 0.15)),
          Positioned(left: -30, bottom: -30, child: _orb(180, const Color(0xFF7C3AED), 0.12)),
          Positioned(right: 60, bottom: 30, child: _orb(80, const Color(0xFF10B981), 0.10)),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 84, height: 84,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 8))],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Image.asset('assets/images/wallet_logo.png', fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text('Wallet Hub', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                    const SizedBox(height: 6),
                    Text('by SchoolHub Cameroon', style: TextStyle(color: Colors.white.withOpacity(0.55), fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.20)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 14),
                          SizedBox(width: 6),
                          Text('Version 1.0  •  Sécurisé et Certifié', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
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
    width: size, height: size,
    decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color.withOpacity(opacity), Colors.transparent])),
  );

  // ── Mission Card ──────────────────────────────────────────────────────────────

  Widget _buildMissionCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF2563EB), Color(0xFF7C3AED)],
          begin: Alignment.topLeft, end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF0284C7).withOpacity(0.30), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(children: [
            Icon(Icons.flag_rounded, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Notre Mission', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
          ]),
          const SizedBox(height: 12),
          Text(
            'Wallet Hub révolutionne les paiements scolaires au Cameroun. '
            'Nous offrons aux élèves, parents et établissements une solution '
            'numérique sécurisée, transparente et ultra-rapide pour gérer '
            'les frais de cantine, fournitures, inscriptions et bien plus encore.',
            style: TextStyle(color: Colors.white.withOpacity(0.90), fontSize: 13.5, height: 1.65, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              _pill(Icons.school_rounded, 'Éducation Numérique'),
              _pill(Icons.lock_rounded, '100% Sécurisé'),
              _pill(Icons.flag_rounded, 'Made in Cameroun'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _pill(IconData icon, String label) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.25)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, color: Colors.white, size: 13), const SizedBox(width: 6),
      Text(label, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
    ]),
  );

  // ── Section title ─────────────────────────────────────────────────────────────

  Widget _section(String title) => Text(title,
    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.textDark, letterSpacing: 0.2));

  // ── Feature Grid ──────────────────────────────────────────────────────────────

  Widget _buildFeatureGrid() {
    final f = [
      ['Recharge Express', 'MTN MoMo & Orange Money en quelques secondes', '${Icons.bolt_rounded.codePoint}', '0xFFFF7900'],
      ['Paiements Instantanés', 'Cantine, transport, fournitures depuis l\'app', '${Icons.payments_rounded.codePoint}', '0xFF0284C7'],
      ['Historique Complet', 'Chaque transaction horodatée et traçable', '${Icons.history_rounded.codePoint}', '0xFF7C3AED'],
      ['Anti-Arnaque', 'Solde certifié par Grand Livre cryptographique', '${Icons.security_rounded.codePoint}', '0xFF10B981'],
      ['Carte Virtuelle SCH', 'Votre carte unique SCH-XXXX-XXXX-XXXX', '${Icons.credit_card_rounded.codePoint}', '0xFFDC2626'],
      ['PIN Sécurisé', 'Code PIN 4 chiffres pour chaque paiement', '${Icons.verified_user_rounded.codePoint}', '0xFFF59E0B'],
    ];
    final icons = [Icons.bolt_rounded, Icons.payments_rounded, Icons.history_rounded, Icons.security_rounded, Icons.credit_card_rounded, Icons.verified_user_rounded];
    final colors = [const Color(0xFFFF7900), const Color(0xFF0284C7), const Color(0xFF7C3AED), const Color(0xFF10B981), const Color(0xFFDC2626), const Color(0xFFF59E0B)];
    return GridView.count(
      crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.15,
      children: List.generate(f.length, (i) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(color: colors[i].withOpacity(0.10), borderRadius: BorderRadius.circular(12)),
            child: Icon(icons[i], color: colors[i], size: 22),
          ),
          const SizedBox(height: 10),
          Text(f[i][0], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(f[i][1], style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
      )),
    );
  }

  // ── Security Card ─────────────────────────────────────────────────────────────

  Widget _buildSecurityCard() {
    final items = [
      [Icons.enhanced_encryption_rounded, 'Cryptographie HMAC/SHA-256', 'Chaque transaction est scellée numériquement, impossible à falsifier.'],
      [Icons.balance_rounded, 'Grand Livre Double-Entrée', 'Votre solde est calculé par les transactions réelles, jamais modifié directement.'],
      [Icons.timer_rounded, 'Session 30 minutes max', 'Déconnexion automatique après 30 min pour protéger votre compte.'],
      [Icons.verified_rounded, 'Vérification email OTP', 'Votre email est vérifié par code avant toute utilisation.'],
    ];

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
      child: Column(children: List.generate(items.length, (i) => Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 40, height: 40,
              decoration: BoxDecoration(color: const Color(0xFF10B981).withOpacity(0.10), borderRadius: BorderRadius.circular(12)),
              child: Icon(items[i][0] as IconData, color: const Color(0xFF10B981), size: 20)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(items[i][1] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
              const SizedBox(height: 3),
              Text(items[i][2] as String, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, height: 1.45)),
            ])),
          ])),
        if (i < items.length - 1) Divider(height: 1, color: Colors.grey.shade100, indent: 18, endIndent: 18),
      ]))),
    );
  }

  // ── Stats Row ─────────────────────────────────────────────────────────────────

  Widget _buildStatsRow() => Row(children: [
    Expanded(child: _stat('100%', 'Sécurisé', const Color(0xFF10B981))),
    const SizedBox(width: 12),
    Expanded(child: _stat('24/7', 'Disponible', const Color(0xFF0284C7))),
    const SizedBox(width: 12),
    Expanded(child: _stat('0 FCFA', 'Frais cachés', const Color(0xFF7C3AED))),
  ]);

  Widget _stat(String v, String l, Color c) => Container(
    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
    decoration: BoxDecoration(color: c.withOpacity(0.07), borderRadius: BorderRadius.circular(18), border: Border.all(color: c.withOpacity(0.20))),
    child: Column(children: [
      Text(v, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: c), textAlign: TextAlign.center),
      const SizedBox(height: 4),
      Text(l, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted), textAlign: TextAlign.center),
    ]),
  );

  // ── Values List ───────────────────────────────────────────────────────────────

  Widget _buildValuesList() {
    final v = [
      ('🎯', 'Accessibilité', 'Un compte ouvert à tous, avec juste un numéro de téléphone mobile.'),
      ('🔒', 'Intégrité', 'Aucune modification de solde possible en dehors des transactions légitimes.'),
      ('⚡', 'Rapidité', 'Recharges et paiements validés en quelques secondes, 24h/24.'),
      ('🤝', 'Confiance', 'Chaque opération est traçable, scellée cryptographiquement et infalsifiable.'),
    ];
    return Column(children: v.map((e) => Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Row(children: [
        Text(e.$1, style: const TextStyle(fontSize: 22)), const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(e.$2, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textDark)),
          const SizedBox(height: 3),
          Text(e.$3, style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted, height: 1.4)),
        ])),
      ]),
    )).toList());
  }

  // ── Steps List ────────────────────────────────────────────────────────────────

  Widget _buildStepsList() {
    final steps = [
      'Inscrivez-vous avec votre numéro de téléphone mobile.',
      'Renseignez vos informations personnelles : nom, prénom, date de naissance.',
      'Vérifiez votre adresse email par code de confirmation OTP.',
      'Rechargez votre wallet via MTN Mobile Money ou Orange Money.',
      'Effectuez vos paiements scolaires sécurisés avec votre code PIN.',
    ];
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFE2E8F0))),
      child: Column(children: List.generate(steps.length, (i) => Column(children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 28, height: 28,
              decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(8)),
              child: Center(child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)))),
            const SizedBox(width: 14),
            Expanded(child: Padding(padding: const EdgeInsets.only(top: 4),
              child: Text(steps[i], style: const TextStyle(fontSize: 13, color: AppColors.textDark, height: 1.45, fontWeight: FontWeight.w500)))),
          ])),
        if (i < steps.length - 1) Divider(height: 1, color: Colors.grey.shade100, indent: 60, endIndent: 18),
      ]))),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────────

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(children: [
        Row(children: [
          Container(width: 44, height: 44,
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.account_balance_wallet_rounded, color: Colors.white, size: 22)),
          const SizedBox(width: 14),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Wallet Hub', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900)),
            Text('SchoolHub Cameroon © 2025', style: TextStyle(color: Colors.white54, fontSize: 11, fontWeight: FontWeight.w500)),
          ]),
        ]),
        const SizedBox(height: 18),
        Divider(color: Colors.white.withOpacity(0.12), height: 1),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _flink(Icons.email_outlined, 'Contact'),
            _flink(Icons.policy_outlined, 'Politique'),
            _flink(Icons.help_outline_rounded, 'Support'),
            _flink(Icons.info_outline_rounded, 'v1.0.0'),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Propulsé par la technologie SchoolHub — Ensemble, digitalisons l\'éducation au Cameroun 🇨🇲',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 10.5, height: 1.5, fontWeight: FontWeight.w500),
        ),
      ]),
    );
  }

  Widget _flink(IconData icon, String label) => Column(children: [
    Icon(icon, color: Colors.white54, size: 18), const SizedBox(height: 4),
    Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.w600)),
  ]);
}
