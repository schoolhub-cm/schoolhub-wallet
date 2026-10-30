// lib/screens/schoolhub/schoolhub_screen.dart
// Écran principal "Espace SchoolHub" dans Wallet Hub

import 'package:flutter/material.dart';
import '../../services/schoolhub_service.dart';
import 'schoolhub_parent_view.dart';
import 'schoolhub_etablissement_view.dart';
import 'schoolhub_professeur_view.dart';
import 'schoolhub_link_screen.dart';

class SchoolHubScreen extends StatefulWidget {
  const SchoolHubScreen({super.key});

  @override
  State<SchoolHubScreen> createState() => _SchoolHubScreenState();
}

class _SchoolHubScreenState extends State<SchoolHubScreen>
    with SingleTickerProviderStateMixin {
  static const _primaryColor = Color(0xFF4F46E5);
  static const _bgColor = Color(0xFFF8FAFC);

  final _service = SchoolHubService();
  bool _loading = true;
  Map<String, dynamic>? _statusData;
  String? _error;

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _loadStatus();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    setState(() => _loading = true);
    final resp = await _service.getStatus();
    if (mounted) {
      setState(() {
        _loading = false;
        if (resp.success) {
          _statusData = resp.data;
          _error = null;
        } else {
          _error = resp.error;
        }
      });
      _animCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: const Color(0xFF1E293B),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.school_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 10),
            const Text(
              'Espace SchoolHub',
              style: TextStyle(
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.w700,
                fontSize: 17,
              ),
            ),
          ],
        ),
        actions: [
          if (_statusData != null && _statusData!['linked'] == true)
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B)),
              onPressed: _loadStatus,
              tooltip: 'Actualiser',
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Connexion à SchoolHub…',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return _buildErrorState();
    }

    if (_statusData == null || _statusData!['linked'] != true) {
      return FadeTransition(opacity: _fadeAnim, child: _buildUnlinkedState());
    }

    return FadeTransition(
      opacity: _fadeAnim,
      child: _buildLinkedState(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 56, color: Color(0xFFCBD5E1)),
            const SizedBox(height: 16),
            const Text(
              'Impossible de se connecter',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Erreur inconnue',
              style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadStatus,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlinkedState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
              ),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFC7D2FE), width: 2),
            ),
            child: const Icon(
              Icons.link_rounded,
              size: 52,
              color: Color(0xFF4F46E5),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Liez votre compte SchoolHub',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'Connectez votre compte Parent, Établissement ou Professeur pour payer les frais de scolarité et gérer votre abonnement directement depuis Wallet Hub.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ..._buildBenefits(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _goToLinkScreen,
              icon: const Icon(Icons.link_rounded),
              label: const Text(
                'Lier mon compte SchoolHub',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Connexion sécurisée via SchoolHub 🔒',
            style: TextStyle(
              color: Color(0xFF10B981),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBenefits() {
    final benefits = [
      (Icons.payments_rounded, 'Paiement pension scolaire', 'Payez les tranches directement depuis votre wallet'),
      (Icons.verified_rounded, 'Gestion abonnements', 'Activez et renouvelez votre abonnement SchoolHub'),
      (Icons.child_care_rounded, 'Suivi de vos enfants', 'Consultez le statut des paiements de chaque enfant'),
    ];
    return benefits.map((b) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(b.$1, color: _primaryColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(b.$2, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF1E293B))),
                  const SizedBox(height: 2),
                  Text(b.$3, style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    )).toList();
  }

  Widget _buildLinkedState() {
    final role = _statusData!['role'] as String? ?? '';

    return switch (role) {
      'PARENT' => SchoolHubParentView(
          data: _statusData!,
          onRefresh: _loadStatus,
        ),
      'ETABLISSEMENT' => SchoolHubEtablissementView(
          data: _statusData!,
          onRefresh: _loadStatus,
        ),
      'PROFESSEUR' => SchoolHubProfesseurView(
          data: _statusData!,
          onRefresh: _loadStatus,
        ),
      _ => const Center(child: Text('Rôle non reconnu')),
    };
  }

  void _goToLinkScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SchoolHubLinkScreen()),
    ).then((_) => _loadStatus());
  }
}
