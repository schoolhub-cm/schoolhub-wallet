import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import '../config/theme.dart';
import '../services/wallet_update_service.dart';

class WalletUpdateDialog {
  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes O';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} Ko';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} Mo';
  }

  static Future<void> showUpdatePrompt(
    BuildContext context,
    WalletUpdateInfo update,
  ) async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.system_update_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mise à jour disponible !',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.textDark),
                  ),
                  Text(
                    'Version ${update.version}',
                    style: const TextStyle(fontSize: 12, color: AppColors.accent, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.notes_rounded, size: 16, color: AppColors.textMuted),
                      SizedBox(width: 6),
                      Text('Nouveautés :', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    update.releaseNotes.isNotEmpty
                        ? update.releaseNotes
                        : 'Améliorations de la sécurité, corrections et mise à jour de l\'interface.',
                    style: const TextStyle(fontSize: 12, color: AppColors.textMuted, height: 1.45),
                  ),
                  if (update.apkSizeBytes != null) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.data_usage_rounded, size: 14, color: AppColors.accentGreen),
                        const SizedBox(width: 6),
                        Text(
                          'Taille : ${_formatBytes(update.apkSizeBytes!)}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accentGreen),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Plus tard', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(ctx, true),
            icon: const Icon(Icons.download_rounded, size: 18),
            label: const Text('Mettre à jour'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
          ),
        ],
      ),
    );

    if (accepted == true && context.mounted) {
      await _downloadAndInstall(context, update);
    }
  }

  static Future<void> _downloadAndInstall(
    BuildContext context,
    WalletUpdateInfo update,
  ) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    var progress = const WalletUpdateProgress(receivedBytes: 0);
    StateSetter? updateProgress;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) {
          updateProgress = setDialogState;
          final fraction = progress.fraction;

          return PopScope(
            canPop: false,
            child: AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: const Row(
                children: [
                  Icon(Icons.downloading_rounded, color: AppColors.accent),
                  SizedBox(width: 10),
                  Text('Téléchargement...', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 8,
                      backgroundColor: const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    fraction == null ? 'En cours...' : '${(fraction * 100).round()} %',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.textDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_formatBytes(progress.receivedBytes)} / ${progress.totalBytes == null ? '?' : _formatBytes(progress.totalBytes!)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Veuillez patienter pendant le téléchargement.',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    try {
      final apkPath = await WalletUpdateService().downloadUpdate(
        update,
        onProgress: (p) {
          progress = p;
          updateProgress?.call(() {});
        },
      );

      if (!context.mounted) return;
      navigator.pop(); // Ferme le dialogue de téléchargement

      // Lance l'installation de l'APK
      await OpenFilex.open(apkPath);
    } catch (e) {
      if (!context.mounted) return;
      navigator.pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de téléchargement : $e'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
