// lib/screens/auth/verify_email_screen.dart

import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/wallet_user.dart';
import '../../services/auth_service.dart';
import '../dashboard/dashboard_screen.dart';

class VerifyEmailScreen extends StatefulWidget {
  final String email;
  final bool fromRegister;

  const VerifyEmailScreen({
    super.key,
    required this.email,
    this.fromRegister = false,
  });

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final _codeController = TextEditingController();
  bool _loading = false;
  bool _resending = false;
  String? _errorMessage;
  String? _successMessage;

  Future<void> _handleVerify() async {
    final code = _codeController.text.trim();
    if (code.length != 6) {
      setState(() => _errorMessage = 'Veuillez saisir le code à 6 chiffres.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final res = await AuthService().api.verifyEmail(code);

    setState(() => _loading = false);

    if (res.success) {
      final user = AuthService().currentUser;
      if (user != null) {
        // Mettre à jour localement
        AuthService().updateCurrentUser(
          WalletUser(
            id: user.id,
            phoneNumber: user.phoneNumber,
            nom: user.nom,
            prenom: user.prenom,
            fullName: user.fullName,
            email: user.email,
            emailVerified: true,
            dateNaissance: user.dateNaissance,
            sexe: user.sexe,
            hasPin: user.hasPin,
          ),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 Adresse email vérifiée avec succès !'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    } else {
      setState(() => _errorMessage = res.error ?? 'Code invalide ou expiré.');
    }
  }

  Future<void> _handleResend() async {
    setState(() {
      _resending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    final res = await AuthService().api.resendEmailCode(email: widget.email);

    setState(() => _resending = false);

    if (res.success) {
      setState(() => _successMessage = 'Un nouveau code a été envoyé à ${widget.email}.');
    } else {
      setState(() => _errorMessage = res.error ?? 'Impossible de renvoyer le code.');
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Vérification Email'),
        actions: [
          if (widget.fromRegister)
            TextButton(
              onPressed: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              },
              child: const Text('Plus tard', style: TextStyle(color: AppColors.textMuted)),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mark_email_read_outlined, size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 24),

              const Text(
                'Confirmez votre email',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nous avons envoyé un code de vérification à 6 chiffres à :\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textMuted, height: 1.4),
              ),
              const SizedBox(height: 32),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 13)),
                ),

              if (_successMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_successMessage!, style: const TextStyle(color: AppColors.success, fontSize: 13)),
                ),

              // Champ Code 6 chiffres
              TextField(
                controller: _codeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 10,
                  color: AppColors.primary,
                ),
                decoration: InputDecoration(
                  hintText: '••••••',
                  hintStyle: const TextStyle(letterSpacing: 8, color: Colors.grey),
                  counterText: '',
                  fillColor: AppColors.background,
                  filled: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleVerify,
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Confirmer le code'),
                ),
              ),
              const SizedBox(height: 20),

              TextButton.icon(
                onPressed: _resending ? null : _handleResend,
                icon: _resending
                    ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Renvoyer un nouveau code'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
