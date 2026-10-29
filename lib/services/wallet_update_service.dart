import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import '../config/app_config.dart';

import 'wallet_update_file_stub.dart'
    if (dart.library.io) 'wallet_update_file_io.dart' as update_file;

class WalletUpdateInfo {
  const WalletUpdateInfo({
    required this.version,
    required this.build,
    required this.downloadUrl,
    required this.releaseNotes,
    required this.apkSizeBytes,
    required this.hasUpdate,
  });

  final String version;
  final int build;
  final Uri? downloadUrl;
  final String releaseNotes;
  final int? apkSizeBytes;
  final bool hasUpdate;
}

class WalletUpdateProgress {
  const WalletUpdateProgress({required this.receivedBytes, this.totalBytes});

  final int receivedBytes;
  final int? totalBytes;

  double? get fraction {
    final total = totalBytes;
    if (total == null || total <= 0) return null;
    return (receivedBytes / total).clamp(0, 1).toDouble();
  }
}

class WalletUpdateService {
  static final WalletUpdateService _instance = WalletUpdateService._internal();
  factory WalletUpdateService() => _instance;
  WalletUpdateService._internal({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<WalletUpdateInfo?> checkForUpdate({bool forceCheck = false}) async {
    try {
      final base = AppConfig.activeBaseUrl.replaceAll(RegExp(r'/+$'), '');
      final uri = Uri.parse('$base/app/version/');

      final response = await _client.get(
        uri,
        headers: const {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body);
      if (body is! Map) return null;

      final serverBuild = int.tryParse('${body['build']}') ?? 1;
      final serverVersion = body['version']?.toString() ?? '1.0.0';
      final downloadUrlStr = body['download_url']?.toString();
      final releaseNotes = body['release_notes']?.toString() ?? '';
      final apkSizeBytes = int.tryParse('${body['apk_size_bytes']}');

      int currentBuild = 1;
      try {
        final info = await PackageInfo.fromPlatform();
        currentBuild = int.tryParse(info.buildNumber) ?? 1;
      } catch (_) {}

      final hasUpdate = forceCheck ? true : (serverBuild > currentBuild);
      final downloadUri = (downloadUrlStr != null && downloadUrlStr.isNotEmpty)
          ? Uri.tryParse(downloadUrlStr)
          : null;

      return WalletUpdateInfo(
        version: serverVersion,
        build: serverBuild,
        downloadUrl: downloadUri,
        releaseNotes: releaseNotes,
        apkSizeBytes: apkSizeBytes,
        hasUpdate: hasUpdate,
      );
    } catch (e) {
      debugPrint('WalletUpdateService error: $e');
      return null;
    }
  }

  Future<String> downloadUpdate(
    WalletUpdateInfo update, {
    required ValueChanged<WalletUpdateProgress> onProgress,
  }) async {
    if (update.downloadUrl == null) {
      throw StateError('Aucun lien de téléchargement disponible.');
    }

    final request = http.Request('GET', update.downloadUrl!)
      ..headers['Accept'] = 'application/vnd.android.package-archive';

    final response = await _client.send(request).timeout(const Duration(minutes: 5));
    if (response.statusCode != 200) {
      throw StateError('Échec du téléchargement (Code HTTP: ${response.statusCode})');
    }

    var receivedBytes = 0;
    final totalBytes = response.contentLength ?? update.apkSizeBytes;

    onProgress(WalletUpdateProgress(
      receivedBytes: receivedBytes,
      totalBytes: totalBytes,
    ));

    final progressStream = response.stream.timeout(const Duration(minutes: 5)).map((chunk) {
      receivedBytes += chunk.length;
      onProgress(WalletUpdateProgress(
        receivedBytes: receivedBytes,
        totalBytes: totalBytes,
      ));
      return chunk;
    });

    final apkPath = await update_file.writeApk(
      progressStream,
      update.build,
      expectedBytes: totalBytes,
    );

    return apkPath;
  }
}
