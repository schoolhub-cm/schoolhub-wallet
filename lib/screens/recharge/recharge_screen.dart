// lib/screens/recharge/recharge_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/auth_service.dart';

class RechargeScreen extends StatefulWidget {
  final VoidCallback? onRechargeSuccess;

  const RechargeScreen({super.key, this.onRechargeSuccess});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final _amountController = TextEditingController(text: '1000');
  final _phoneController = TextEditingController();
  String _selectedOperator = 'MTN'; // 'MTN' ou 'ORANGE'
  bool _loading = false;
  String? _errorMessage;

  final List<int> _quickAmounts = [500, 1000, 2000, 5000, 10000, 25000];

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    if (user != null && user.phoneNumber.isNotEmpty) {
      _phoneController.text = user.phoneNumber;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleRecharge() async {
    final amountText = _amountController.text.trim().replaceAll(' ', '');
    final amount = double.tryParse(amountText);
    final phone = _phoneController.text.trim();

    if (amount == null || amount < 100) {
      setState(() => _errorMessage = 'Le montant minimum est de 100 FCFA.');
      return;
    }

    if (phone.isEmpty || phone.length < 9) {
      setState(() => _errorMessage = 'Veuillez saisir un numéro Mobile Money valide.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    final res = await AuthService().api.rechargeDirect(
      montant: amount,
      phoneNumber: phone,
      operator: _selectedOperator,
    );

    setState(() => _loading = false);

    if (res.success && res.data != null) {
      final transId = res.data!['transaction_id'] as int;
      if (!mounted) return;
      _showPollingDialog(transId, amount, phone);
    } else {
      setState(() => _errorMessage = res.error ?? 'Erreur lors de l’envoi de la recharge.');
    }
  }

  void _showPollingDialog(int transId, double amount, String phone) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _PushValidationDialog(
        transId: transId,
        amount: amount,
        phone: phone,
        operator: _selectedOperator,
        onSuccess: () {
          widget.onRechargeSuccess?.call();
          Navigator.of(context).pop(); // Fermer l'écran de recharge
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Recharger mon Wallet'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bannière info direct pay
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.bolt_rounded, color: AppColors.accent, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Recharge Instantanée Mobile Money',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textDark),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Une invite USSD apparaîtra directement sur votre téléphone. Validez avec votre code secret.',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

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

              // Choix de l'opérateur
              const Text('Choisissez votre opérateur', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 12),
              Row(
                children: [
                  // MTN MoMo
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedOperator = 'MTN'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: _selectedOperator == 'MTN'
                              ? const LinearGradient(colors: [Color(0xFFFFFBEA), Color(0xFFFFF3C4)])
                              : null,
                          color: _selectedOperator == 'MTN' ? null : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedOperator == 'MTN' ? AppColors.mtnYellow : Colors.grey.shade300,
                            width: _selectedOperator == 'MTN' ? 2.2 : 1,
                          ),
                          boxShadow: _selectedOperator == 'MTN'
                              ? [BoxShadow(color: AppColors.mtnYellow.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: const BoxDecoration(
                                    color: AppColors.mtnYellow,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.phone_android_rounded, color: Colors.black, size: 22),
                                ),
                                if (_selectedOperator == 'MTN')
                                  const Positioned(
                                    right: -4,
                                    top: -4,
                                    child: Icon(Icons.check_circle_rounded, color: Colors.black, size: 16),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'MTN MoMo',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Orange Money
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedOperator = 'ORANGE'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: _selectedOperator == 'ORANGE'
                              ? const LinearGradient(colors: [Color(0xFFFFF4EB), Color(0xFFFFDEC2)])
                              : null,
                          color: _selectedOperator == 'ORANGE' ? null : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedOperator == 'ORANGE' ? AppColors.orangeMomo : Colors.grey.shade300,
                            width: _selectedOperator == 'ORANGE' ? 2.2 : 1,
                          ),
                          boxShadow: _selectedOperator == 'ORANGE'
                              ? [BoxShadow(color: AppColors.orangeMomo.withOpacity(0.35), blurRadius: 12, offset: const Offset(0, 4))]
                              : null,
                        ),
                        child: Column(
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(9),
                                  decoration: const BoxDecoration(
                                    color: AppColors.orangeMomo,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.phone_android_rounded, color: Colors.white, size: 22),
                                ),
                                if (_selectedOperator == 'ORANGE')
                                  const Positioned(
                                    right: -4,
                                    top: -4,
                                    child: Icon(Icons.check_circle_rounded, color: AppColors.orangeMomo, size: 16),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Orange Money',
                              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Colors.black),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Numéro à débiter
              const Text('Numéro de compte Mobile Money', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '6XXXXXXXX',
                  prefixIcon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🇨🇲 +237', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(width: 1, height: 20, color: Colors.grey.shade300),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Montant
              const Text('Montant à recharger (FCFA)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.textDark),
                decoration: const InputDecoration(
                  hintText: 'Ex: 1000',
                  suffixText: 'FCFA',
                  suffixStyle: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                  prefixIcon: Icon(Icons.payments_outlined, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 14),

              // Montants rapides
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _quickAmounts.map((amt) {
                  final isSelected = _amountController.text == amt.toString();
                  return InkWell(
                    onTap: () => setState(() => _amountController.text = amt.toString()),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        '${amt.toString()} FCFA',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : AppColors.textDark,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),

              // Bouton Recharger
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _handleRecharge,
                  icon: _loading
                      ? const SizedBox.shrink()
                      : const Icon(Icons.bolt_rounded, color: Colors.white),
                  label: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        )
                      : const Text('Recharger maintenant'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DIALOGUE D'ATTENTE DE VALIDATION DIRECT PUSH USSD
// ============================================================

class _PushValidationDialog extends StatefulWidget {
  final int transId;
  final double amount;
  final String phone;
  final String operator;
  final VoidCallback onSuccess;

  const _PushValidationDialog({
    required this.transId,
    required this.amount,
    required this.phone,
    required this.operator,
    required this.onSuccess,
  });

  @override
  State<_PushValidationDialog> createState() => _PushValidationDialogState();
}

class _PushValidationDialogState extends State<_PushValidationDialog> {
  Timer? _timer;
  int _secondsLeft = 60;
  String _status = 'EN_ATTENTE';
  String _statusMessage = 'Demande envoyée sur votre téléphone...';

  @override
  void initState() {
    super.initState();
    _startPolling();
  }

  void _startPolling() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      if (_secondsLeft <= 0) {
        timer.cancel();
        setState(() {
          _status = 'TIMEOUT';
          _statusMessage = 'Délai dépassé. Si vous avez validé, votre solde sera crédité sous peu.';
        });
        return;
      }

      setState(() => _secondsLeft -= 3);

      final res = await AuthService().api.checkTransaction(widget.transId);
      if (res.success && res.data != null) {
        final st = res.data!['statut'] as String;
        if (st == 'SUCCES') {
          timer.cancel();
          setState(() {
            _status = 'SUCCES';
            _statusMessage = res.data!['message'] ?? 'Recharge validée avec succès !';
          });
          await Future.delayed(const Duration(milliseconds: 1400));
          if (!mounted) return;
          Navigator.of(context).pop();
          widget.onSuccess();
        } else if (st == 'ECHEC' || st == 'ANNULE') {
          timer.cancel();
          setState(() {
            _status = 'ECHEC';
            _statusMessage = 'La transaction a été annulée ou refusée.';
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      contentPadding: const EdgeInsets.all(24),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_status == 'EN_ATTENTE') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  color: AppColors.accent,
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Validation en cours...',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              'Veuillez saisir votre code secret Mobile Money sur votre téléphone (${widget.phone}).',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted, height: 1.4),
            ),
            const SizedBox(height: 16),
            Text(
              '${_secondsLeft}s restantes',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textMuted, fontSize: 12),
            ),
          ] else if (_status == 'SUCCES') ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 54),
            ),
            const SizedBox(height: 20),
            const Text(
              '🎉 Félicitations !',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 54),
            ),
            const SizedBox(height: 20),
            const Text(
              'Paiement non confirmé',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
            ),
            const SizedBox(height: 8),
            Text(
              _statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: AppColors.textMuted),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Fermer'),
            ),
          ],
        ],
      ),
    );
  }
}
