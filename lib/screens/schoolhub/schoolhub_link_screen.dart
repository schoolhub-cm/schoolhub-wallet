// lib/screens/schoolhub/schoolhub_link_screen.dart
// Écran de liaison SchoolHub avec saisie et collage direct du code

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../services/schoolhub_service.dart';

class SchoolHubLinkScreen extends StatefulWidget {
  const SchoolHubLinkScreen({super.key});

  @override
  State<SchoolHubLinkScreen> createState() => _SchoolHubLinkScreenState();
}

class _SchoolHubLinkScreenState extends State<SchoolHubLinkScreen>
    with WidgetsBindingObserver {
  static const _primaryColor = Color(0xFF4F46E5);
  final _service = SchoolHubService();
  final _codeController = TextEditingController();

  bool _loading = false;
  bool _validatingCode = false;
  String? _error;
  bool _success = false;
  String? _generatedUrl;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _generatedUrl = _service.getLinkUrl();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _codeController.dispose();
    super.dispose();
  }

  // Détection du retour de l'utilisateur dans l'application
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkClipboardForCode();
      _checkIfAlreadyLinked();
    }
  }

  /// Vérifie automatiquement si le presse-papier contient un code de liaison
  Future<void> _checkClipboardForCode() async {
    try {
      final clipData = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipData?.text?.trim() ?? '';
      // Un code de liaison fait entre 30 et 60 caractères alphanumériques/tirets
      if (text.length >= 30 && text.length <= 60 && !text.contains(' ') && !text.contains('http')) {
        if (_codeController.text != text && mounted) {
          setState(() {
            _codeController.text = text;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('📋 Code de liaison détecté et inséré automatiquement !'),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (_) {}
  }

  /// Vérifie si le statut est déjà passé à lié
  Future<void> _checkIfAlreadyLinked() async {
    final status = await _service.getStatus();
    if (status.success && status.data?['linked'] == true && mounted) {
      setState(() => _success = true);
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) Navigator.pop(context, true);
    }
  }

  Future<void> _openWebLinkPage() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final url = _service.getLinkUrl();
    _generatedUrl = url;
    final uri = Uri.parse(url);

    bool launched = false;
    try {
      launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      launched = false;
    }

    if (!launched) {
      try {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (_) {
        launched = false;
      }
    }

    if (mounted) {
      setState(() => _loading = false);
      if (launched) {
        _showWaitingDialog();
      } else {
        setState(() {
          _error = 'Le navigateur n\'a pas pu s\'ouvrir automatiquement. Vous pouvez copier le lien ci-dessous et l\'ouvrir manuellement dans votre navigateur.';
        });
      }
    }
  }

  void _pasteFromClipboard() async {
    try {
      final data = await Clipboard.getData(Clipboard.kTextPlain);
      final text = data?.text?.trim() ?? '';
      if (text.isNotEmpty) {
        setState(() {
          _codeController.text = text;
          _error = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code collé ! Cliquez sur « Valider la liaison »'),
            backgroundColor: Color(0xFF4F46E5),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (_) {}
  }

  void _copyLinkToClipboard() {
    if (_generatedUrl == null) return;
    Clipboard.setData(ClipboardData(text: _generatedUrl!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📋 Lien de connexion copié dans le presse-papier !'),
        backgroundColor: Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showWaitingDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(Icons.open_in_browser_rounded, color: _primaryColor, size: 20),
            ),
            const SizedBox(width: 10),
            const Text('Page ouverte', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1. Connectez-vous sur la page web SchoolHub.\n'
              '2. Cliquez sur « Copier le code » sur la page.\n'
              '3. Revenez ici et validez.',
              style: TextStyle(color: Color(0xFF475569), height: 1.5, fontSize: 13),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: _primaryColor, size: 18),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'La zone de saisie du code vous attend sur l\'écran.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _checkClipboardForCode();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Compris, entrer le code'),
          ),
        ],
      ),
    );
  }

  Future<void> _submitCode() async {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _error = 'Veuillez coller le code de liaison affiché sur la page web.');
      return;
    }

    setState(() {
      _validatingCode = true;
      _error = null;
    });

    final resp = await _service.submitLinkCode(code);
    if (mounted) {
      setState(() => _validatingCode = false);
      if (resp.success) {
        setState(() => _success = true);
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) Navigator.pop(context, true);
      } else {
        setState(() => _error = resp.error ?? 'Code invalide ou expiré.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Lier mon compte SchoolHub',
          style: TextStyle(color: Color(0xFF1E293B), fontWeight: FontWeight.w700, fontSize: 16),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: _success ? _buildSuccess() : _buildContent(),
    );
  }

  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFFECFDF5), Color(0xFFD1FAE5)]),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF6EE7B7), width: 2),
              ),
              child: const Icon(Icons.check_circle_rounded, size: 42, color: Color(0xFF10B981)),
            ),
            const SizedBox(height: 20),
            const Text(
              'Compte lié avec succès !',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            const Text(
              'Votre espace scolaire SchoolHub est activé.\nRedirection en cours…',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 14, height: 1.5),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Badge sécurité
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFF0FDF4),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFBBF7D0)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Connexion chiffrée SSL & Code unique',
                    style: TextStyle(color: Color(0xFF166534), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ============================================
          // ÉTAPE 1 : OUVRIR LA PAGE DE CONNEXION
          // ============================================
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF4F46E5), Color(0xFF6366F1)]),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('1', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Se connecter à SchoolHub',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cliquez sur le bouton ci-dessous pour ouvrir la page web, entrez vos identifiants puis copiez le code de liaison affiché.',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.45),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _openWebLinkPage,
                    icon: _loading
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.open_in_browser_rounded, size: 20),
                    label: Text(
                      _loading ? 'Ouverture en cours…' : 'Ouvrir la page de connexion',
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),

                // Lien de secours
                if (_generatedUrl != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Si le navigateur ne s\'ouvre pas :',
                        style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                      ),
                      TextButton.icon(
                        onPressed: _copyLinkToClipboard,
                        icon: const Icon(Icons.copy_rounded, size: 13, color: _primaryColor),
                        label: const Text('Copier l\'adresse', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _primaryColor)),
                        style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ============================================
          // ÉTAPE 2 : COLLER LE CODE & VALIDER
          // ============================================
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFC7D2FE), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [Color(0xFF10B981), Color(0xFF059669)]),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text('2', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Finaliser la liaison',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E293B)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Collez ici le code de liaison généré sur la page web après votre connexion :',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B), height: 1.45),
                ),
                const SizedBox(height: 14),

                // Champ de saisie avec bouton Coller intégré
                TextField(
                  controller: _codeController,
                  autocorrect: false,
                  enableSuggestions: false,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Collez le code de liaison ici…',
                    hintStyle: const TextStyle(fontFamily: 'sans-serif', fontSize: 13, color: Color(0xFF94A3B8)),
                    prefixIcon: const Icon(Icons.vpn_key_rounded, color: _primaryColor, size: 20),
                    suffixIcon: TextButton.icon(
                      onPressed: _pasteFromClipboard,
                      icon: const Icon(Icons.paste_rounded, size: 16, color: _primaryColor),
                      label: const Text('Coller', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: _primaryColor)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _primaryColor, width: 2),
                    ),
                  ),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.error_outline_rounded, color: Color(0xFFDC2626), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(_error!, style: const TextStyle(color: Color(0xFFB91C1C), fontSize: 12.5, height: 1.4)),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _validatingCode ? null : _submitCode,
                    icon: _validatingCode
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.check_circle_rounded, size: 20),
                    label: Text(
                      _validatingCode ? 'Vérification en cours…' : 'Valider la liaison de mon compte',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
