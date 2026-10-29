// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../services/auth_service.dart';
import 'auth/login_screen.dart';
import 'auth/register_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Carte Virtuelle Titanium',
      'tagline': 'Votre compte scolaire & personnel',
      'desc': 'Recevez immédiatement votre carte numérique unique SCH-XXXX pour gérer l\'argent de poche, cantine et fournitures sans espèces.',
      'gradient': const [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)],
      'icon': Icons.credit_card_rounded,
      'accentColor': const Color(0xFF38BDF8),
      'badge': 'SÉCURISÉ & UNIQUE',
      'previewType': 'card',
    },
    {
      'title': 'Recharge Directe Sans Redirection',
      'tagline': 'MTN MoMo & Orange Money',
      'desc': 'Rechargez en toute sécurité via le push USSD directement sur votre téléphone. Aucune navigation web requise, crédité en 3 secondes.',
      'gradient': const [Color(0xFFEA580C), Color(0xFFF97316), Color(0xFFFB923C)],
      'icon': Icons.bolt_rounded,
      'accentColor': const Color(0xFFFFD54F),
      'badge': 'INSTANTANÉ 24/7',
      'previewType': 'recharge',
    },
    {
      'title': 'Paiements Scolaires en 1 Clic',
      'tagline': 'Cantine, transport, livres & frais',
      'desc': 'Réglez toutes les dépenses de l\'école en sélectionnant la catégorie et validez avec votre code PIN secret à 4 chiffres.',
      'gradient': const [Color(0xFF4338CA), Color(0xFF6366F1), Color(0xFF818CF8)],
      'icon': Icons.school_rounded,
      'accentColor': const Color(0xFFA5B4FC),
      'badge': 'ZÉRO ATTENTE',
      'previewType': 'pay',
    },
    {
      'title': 'Grand Livre Anti-Arnaque',
      'tagline': 'Scellement Cryptographique HMAC',
      'desc': 'Votre solde est certifié par double-entrée comptable. Impossible à falsifier en base de données, vos fonds sont mathématiquement protégés.',
      'gradient': const [Color(0xFF065F46), Color(0xFF059669), Color(0xFF10B981)],
      'icon': Icons.verified_user_rounded,
      'accentColor': const Color(0xFF6EE7B7),
      'badge': '100% INVIOLABLE',
      'previewType': 'security',
    },
    {
      'title': 'Reçus & Traçabilité Totale',
      'tagline': 'Historique certifié & Audit en direct',
      'desc': 'Chaque franc dépensé est horodaté et consultable. Les parents et élèves gardent le contrôle total avec des alertes immédiates.',
      'gradient': const [Color(0xFF831843), Color(0xFFBE185D), Color(0xFFDB2777)],
      'icon': Icons.receipt_long_rounded,
      'accentColor': const Color(0xFFFBCFE8),
      'badge': 'TRANSPARENCE',
      'previewType': 'receipt',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finishOnboarding(bool toRegister) async {
    await AuthService().setHasSeenOnboarding();
    if (!mounted) return;
    if (toRegister) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const RegisterScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = _pages[_currentPage];
    final List<Color> gradientColors = page['gradient'] as List<Color>;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0F1D),
      body: Stack(
        children: [
          // Dynamic Animated Background Aura
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -0.3),
                radius: 1.2,
                colors: [
                  gradientColors[0].withOpacity(0.45),
                  const Color(0xFF0A0F1D),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top Bar: Logo + Passer
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/images/wallet_logo.png',
                              width: 32,
                              height: 32,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Wallet Hub',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => _finishOnboarding(false),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white70,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        ),
                        child: const Text(
                          'Passer',
                          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

                // Main Page Carousel
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _pages.length,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemBuilder: (context, idx) {
                      final item = _pages[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Animated Hero Graphic
                            ScaleTransition(
                              scale: _pulseAnimation,
                              child: _buildHeroGraphic(item),
                            ),
                            const SizedBox(height: 36),

                            // Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: (item['accentColor'] as Color).withOpacity(0.16),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: (item['accentColor'] as Color).withOpacity(0.4),
                                ),
                              ),
                              child: Text(
                                item['badge'] as String,
                                style: TextStyle(
                                  color: item['accentColor'] as Color,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Title
                            Text(
                              item['title'] as String,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                            const SizedBox(height: 6),

                            // Tagline
                            Text(
                              item['tagline'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: item['accentColor'] as Color,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Description
                            Text(
                              item['desc'] as String,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13.5,
                                color: Colors.white.withOpacity(0.72),
                                height: 1.55,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Dots indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (idx) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == idx ? 28 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _currentPage == idx
                            ? (_pages[_currentPage]['accentColor'] as Color)
                            : Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // Bottom Action Buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Column(
                    children: [
                      // Bouton Suivant / Commencer
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                gradientColors[0],
                                gradientColors.length > 1 ? gradientColors[1] : gradientColors[0],
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: gradientColors[0].withOpacity(0.4),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            onPressed: () {
                              if (_currentPage < _pages.length - 1) {
                                _pageController.nextPage(
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeInOut,
                                );
                              } else {
                                _finishOnboarding(true);
                              }
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  _currentPage < _pages.length - 1
                                      ? 'Suivant'
                                      : 'Créer mon Wallet Hub',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  _currentPage < _pages.length - 1
                                      ? Icons.arrow_forward_rounded
                                      : Icons.rocket_launch_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Bouton Se connecter
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          onPressed: () => _finishOnboarding(false),
                          child: const Text(
                            'J\'ai déjà un compte • Se connecter',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroGraphic(Map<String, dynamic> item) {
    final List<Color> colors = item['gradient'] as List<Color>;
    final Color accent = item['accentColor'] as Color;
    final IconData icon = item['icon'] as IconData;

    return Container(
      width: 170,
      height: 170,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            colors[0].withOpacity(0.8),
            colors.length > 1 ? colors[1] : colors[0],
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.5),
            blurRadius: 36,
            spreadRadius: 4,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.25),
          width: 2,
        ),
      ),
      child: Center(
        child: Container(
          width: 90,
          height: 90,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.12),
            shape: BoxShape.circle,
            border: Border.all(color: accent.withOpacity(0.5), width: 1.5),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 46,
          ),
        ),
      ),
    );
  }
}
