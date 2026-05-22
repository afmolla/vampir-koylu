import 'dart:io';

import 'package:dio/dio.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../core/version_utils.dart';

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

  static const _minApkBytes = 5 * 1024 * 1024; // ~5 MB; gercek APK ~50 MB

  Future<String> downloadApk({
    required String url,
    void Function(double progress)? onProgress,
  }) async {
    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/vampir_koylu_update.apk';
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    }

    await _dio.download(
      url,
      path,
      onReceiveProgress: (received, total) {
        if (total > 0 && onProgress != null) {
          onProgress(received / total);
        }
      },
    );

    if (!await file.exists()) {
      throw ApkInstallException('İndirilen dosya kaydedilemedi.');
    }

    final size = await file.length();
    if (size < _minApkBytes) {
      throw ApkInstallException(
        'APK bulunamadı veya henüz yayınlanmadı ($size bayt). '
        'GitHub Actions build bitene kadar bekleyin veya v0.2.7 yedeği deneniyor.',
      );
    }

    final header = await file.openRead(0, 4).first;
    // APK = ZIP → PK\x03\x04
    if (header.length < 2 || header[0] != 0x50 || header[1] != 0x4B) {
      throw ApkInstallException(
        'İndirilen dosya APK değil (bozuk veya HTML sayfası).',
      );
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
    ApkInstallException? lastError;
    final urls = apkDownloadCandidates(url);
    for (var i = 0; i < urls.length; i++) {
      try {
        final path = await downloadApk(url: urls[i], onProgress: onProgress);
        await openInstaller(path);
        return;
      } on ApkInstallException catch (e) {
        lastError = e;
        if (i < urls.length - 1) continue;
      }
    }
    throw lastError ??
        ApkInstallException(
          'Güncelleme indirilemedi. İnternet veya GitHub release kontrol edin.',
        );
  }
}

class ApkInstallException implements Exception {
  ApkInstallException(this.message);
  final String message;

  @override
  String toString() => message;
}
