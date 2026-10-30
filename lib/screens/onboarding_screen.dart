// lib/screens/onboarding_screen.dart

import 'package:flutter/material.dart';
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
      'desc': 'Recevez immédiatement votre carte numérique unique SCH-XXXX pour gérer cantine, fournitures et argent de poche sans espèces.',
      'icon': Icons.credit_card_rounded,
      'primaryColor': const Color(0xFF4F46E5), // Indigo moderne
      'lightColor': const Color(0xFFEEF2FF),
      'badge': 'SÉCURISÉ & UNIQUE',
    },
    {
      'title': 'Recharge Directe Instantanée',
      'tagline': 'MTN MoMo & Orange Money',
      'desc': 'Rechargez en toute sécurité par push USSD direct sur votre téléphone, sans redirection web. Vos fonds sont crédités en 3 secondes.',
      'icon': Icons.bolt_rounded,
      'primaryColor': const Color(0xFFEA580C), // Orange vif
      'lightColor': const Color(0xFFFFF7ED),
      'badge': 'DISPONIBLE 24H/24',
    },
    {
      'title': 'Paiements Scolaires en 1 Clic',
      'tagline': 'Cantine, transport, livres & frais',
      'desc': 'Réglez toutes les dépenses de l\'école en sélectionnant la catégorie et validez simplement avec votre code PIN secret à 4 chiffres.',
      'icon': Icons.school_rounded,
      'primaryColor': const Color(0xFF0284C7), // Bleu SchoolHub
      'lightColor': const Color(0xFFF0F9FF),
      'badge': 'ZÉRO ATTENTE',
    },
    {
      'title': 'Grand Livre Anti-Arnaque',
      'tagline': 'Scellement Cryptographique HMAC',
      'desc': 'Votre solde est certifié par double-entrée comptable. Impossible à falsifier en base de données, vos fonds sont mathématiquement protégés.',
      'icon': Icons.verified_user_rounded,
      'primaryColor': const Color(0xFF059669), // Vert émeraude
      'lightColor': const Color(0xFFECFDF5),
      'badge': '100% INVIOLABLE',
    },
    {
      'title': 'Liaison Directe SchoolHub',
      'tagline': 'Parents, Écoles & Professeurs',
      'desc': 'Liez votre compte SchoolHub pour régler les pensions scolaires de vos enfants ou activer les abonnements de votre établissement en un clic.',
      'icon': Icons.hub_rounded,
      'primaryColor': const Color(0xFF7C3AED), // Violet fintech
      'lightColor': const Color(0xFFF5F3FF),
      'badge': 'NOUVEAU',
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
    final Color primaryColor = page['primaryColor'] as Color;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // Fond clair, doux et épuré
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
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
                          width: 34,
                          height: 34,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Wallet Hub',
                        style: TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: () => _finishOnboarding(false),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFF64748B),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    child: const Text(
                      'Passer',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
                    ),
                  ),
                ],
              ),
            ),

            // Carousel des produits
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemBuilder: (context, idx) {
                  final item = _pages[idx];
                  final Color itemPrimary = item['primaryColor'] as Color;
                  final Color itemLight = item['lightColor'] as Color;
                  final IconData itemIcon = item['icon'] as IconData;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Illustration Produit avec animation douce
                        ScaleTransition(
                          scale: _pulseAnimation,
                          child: Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              color: itemLight,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: itemPrimary.withOpacity(0.25),
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: itemPrimary.withOpacity(0.12),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Container(
                                width: 88,
                                height: 88,
                                decoration: BoxDecoration(
                                  color: itemPrimary,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: itemPrimary.withOpacity(0.35),
                                      blurRadius: 18,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  itemIcon,
                                  color: Colors.white,
                                  size: 44,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(
                            color: itemLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: itemPrimary.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            item['badge'] as String,
                            style: TextStyle(
                              color: itemPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Titre
                        Text(
                          item['title'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            height: 1.25,
                          ),
                        ),
                        const SizedBox(height: 6),

                        // Sous-titre
                        Text(
                          item['tagline'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                            color: itemPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Description
                        Text(
                          item['desc'] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF64748B),
                            height: 1.55,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Indicateurs de page (Dots)
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
                        ? primaryColor
                        : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Boutons d'action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: primaryColor.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () {
                        if (_currentPage < _pages.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 350),
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
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            _currentPage < _pages.length - 1
                                ? Icons.arrow_forward_rounded
                                : Icons.rocket_launch_rounded,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0F172A),
                        side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => _finishOnboarding(false),
                      child: const Text(
                        'J\'ai déjà un compte • Se connecter',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
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
    );
  }
}
