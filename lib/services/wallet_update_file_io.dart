import 'dart:io';
import 'package:path_provider/path_provider.dart';

Future<String> writeApk(
  Stream<List<int>> bytes,
  int build, {
  required int? expectedBytes,
}) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/schoolhub-wallet-$build.apk');
  final sink = file.openWrite();
  var receivedBytes = 0;
  try {
    await for (final chunk in bytes) {
      receivedBytes += chunk.length;
      sink.add(chunk);
    }
    await sink.flush();
    await sink.close();
    if (receivedBytes == 0 ||
        (expectedBytes != null && receivedBytes != expectedBytes)) {
      throw StateError('Le fichier APK reçu est incomplet.');
    }
    return file.path;
  } catch (_) {
    await sink.close();
    if (await file.exists()) await file.delete();
    rethrow;
  }
}
