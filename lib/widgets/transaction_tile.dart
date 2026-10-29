// lib/widgets/transaction_tile.dart

import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
  });

  void _showTransactionDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (transaction.isRecharge ? AppColors.accentGreen : AppColors.accent)
                    .withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                transaction.isRecharge
                    ? Icons.south_west_rounded
                    : Icons.north_east_rounded,
                color: transaction.isRecharge ? AppColors.accentGreen : AppColors.accent,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '${transaction.isRecharge ? '+' : '-'}${transaction.montant.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA',
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: (transaction.isSuccess
                        ? AppColors.accentGreen
                        : (transaction.isPending ? AppColors.warning : AppColors.error))
                    .withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                transaction.statutDisplay,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: transaction.isSuccess
                      ? AppColors.accentGreen
                      : (transaction.isPending ? AppColors.warning : AppColors.error),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildDetailRow('Type', transaction.typeDisplay),
            _buildDetailRow('Description', transaction.description.isNotEmpty ? transaction.description : 'Transaction standard'),
            _buildDetailRow('Date & Heure', transaction.createdAt),
            if (transaction.reference.isNotEmpty)
              _buildDetailRow('Référence Fapshi', transaction.reference),
            _buildDetailRow('Statut Sécurité', 'Scellé par Grand Livre SHA256'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(ctx).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Fermer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isRecharge = transaction.isRecharge;
    final isSuccess = transaction.isSuccess;
    final desc = transaction.description.toLowerCase();

    Color iconBg;
    Color iconColor;
    IconData iconData;

    if (desc.contains('mtn')) {
      iconBg = AppColors.mtnYellow.withOpacity(0.2);
      iconColor = const Color(0xFFB45309);
      iconData = Icons.phone_android_rounded;
    } else if (desc.contains('orange')) {
      iconBg = AppColors.orangeMomo.withOpacity(0.18);
      iconColor = AppColors.orangeMomo;
      iconData = Icons.phone_android_rounded;
    } else if (desc.contains('scolarité') || desc.contains('cantine') || desc.contains('cours')) {
      iconBg = AppColors.accent.withOpacity(0.15);
      iconColor = AppColors.accent;
      iconData = Icons.school_rounded;
    } else if (isRecharge) {
      iconBg = AppColors.accentGreen.withOpacity(0.15);
      iconColor = AppColors.accentGreen;
      iconData = Icons.south_west_rounded;
    } else {
      iconBg = const Color(0xFF6366F1).withOpacity(0.15);
      iconColor = const Color(0xFF6366F1);
      iconData = Icons.north_east_rounded;
    }

    final formattedAmount = '${isRecharge ? '+' : '-'}${transaction.montant.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]} ')} FCFA';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade100, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        onTap: () {
          if (onTap != null) {
            onTap!();
          } else {
            _showTransactionDetails(context);
          }
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(iconData, color: iconColor, size: 22),
        ),
        title: Text(
          transaction.description.isNotEmpty ? transaction.description : transaction.typeDisplay,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        subtitle: Row(
          children: [
            Text(
              transaction.createdAt,
              style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (isSuccess ? AppColors.accentGreen : (transaction.isPending ? AppColors.warning : AppColors.error)).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                transaction.statutDisplay,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: isSuccess ? AppColors.accentGreen : (transaction.isPending ? AppColors.warning : AppColors.error),
                ),
              ),
            ),
          ],
        ),
        trailing: Text(
          formattedAmount,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: isRecharge ? AppColors.accentGreen : AppColors.textDark,
          ),
        ),
      ),
    );
  }
}
