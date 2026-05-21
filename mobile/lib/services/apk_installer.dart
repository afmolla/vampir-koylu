import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class ApkInstaller {
  ApkInstaller({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                followRedirects: true,
                maxRedirects: 8,
                receiveTimeout: const Duration(minutes: 15),
                headers: const {
                  'User-Agent': 'VampirKoylu-Android',
                  'Accept': 'application/octet-stream',
                },
              ),
            );

  final Dio _dio;

  Future<void> _ensureInstallPermission() async {
    if (!Platform.isAndroid) return;
    final status = await Permission.requestInstallPackages.status;
    if (status.isGranted) return;
    final result = await Permission.requestInstallPackages.request();
    if (!result.isGranted) {
      await openAppSettings();
      throw ApkInstallException(
        'Kurulum izni gerekli. Açılan ayarlardan «Bilinmeyen uygulamaları yükle»yi aç, sonra tekrar dene.',
      );
    }
  }

  Future<String> downloadApk({
    required String url,
    void Function(double progress)? onProgress,
  }) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/vampir_koylu_update.apk';

    await _dio.download(
      url,
      path,
      onReceiveProgress: (received, total) {
        if (total > 0 && onProgress != null) {
          onProgress(received / total);
        }
      },
    );

    final file = File(path);
    if (!await file.exists() || await file.length() < 1024) {
      throw ApkInstallException('İndirilen dosya geçersiz.');
    }
    return path;
  }

  Future<void> openInstaller(String apkPath) async {
    final result = await OpenFilex.open(
      apkPath,
      type: 'application/vnd.android.package-archive',
    );
    switch (result.type) {
      case ResultType.done:
        return;
      case ResultType.noAppToOpen:
        throw ApkInstallException('APK kurulumu açılamadı.');
      case ResultType.fileNotFound:
        throw ApkInstallException('İndirilen APK bulunamadı.');
      case ResultType.permissionDenied:
        throw ApkInstallException(
          'Dosya izni reddedildi. Ayarlardan depolama iznini kontrol et.',
        );
      case ResultType.error:
        throw ApkInstallException(
          result.message.isNotEmpty ? result.message : 'Kurulum ekranı açılamadı.',
        );
    }
  }

  Future<void> downloadAndInstall({
    required String url,
    void Function(double progress)? onProgress,
  }) async {
    await _ensureInstallPermission();
    final path = await downloadApk(url: url, onProgress: onProgress);
    await openInstaller(path);
  }
}

class ApkInstallException implements Exception {
  ApkInstallException(this.message);
  final String message;

  @override
  String toString() => message;
}
