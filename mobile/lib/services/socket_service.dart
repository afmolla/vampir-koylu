import 'dart:async';

import 'package:package_info_plus/package_info_plus.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../core/config.dart';
import 'wallet_refresh.dart';

class SocketService {
  io.Socket? _socket;

  static String socketBaseUrl() {
    final uri = Uri.parse(AppConfig.apiBaseUrl);
    final scheme = uri.scheme == 'https' ? 'wss' : 'ws';
    final port = uri.hasPort ? ':${uri.port}' : '';
    return '$scheme://${uri.host}$port';
  }

  Future<io.Socket> connect({required String token}) async {
    if (_socket?.connected == true) return _socket!;

    String version = AppConfig.clientVersion;
    try {
      final info = await PackageInfo.fromPlatform();
      if (info.version.isNotEmpty) version = info.version;
    } catch (_) {}

    _socket?.dispose();
    _socket = io.io(
      socketBaseUrl(),
      io.OptionBuilder()
          .setTransports(['websocket', 'polling'])
          .enableAutoConnect()
          .setAuth({'token': token, 'clientVersion': version})
          .build(),
    );

    final completer = Completer<io.Socket>();
    void done(io.Socket s) {
      if (!completer.isCompleted) completer.complete(s);
    }

    _socket!.onConnect((_) {
      _socket?.off('wallet:update');
      _socket?.on('wallet:update', (data) {
        if (data is Map) WalletRefresh.apply(Map<String, dynamic>.from(data));
      });
      done(_socket!);
    });
    _socket!.onConnectError((err) {
      if (!completer.isCompleted) {
        completer.completeError(Exception('Socket: $err'));
      }
    });

    _socket!.connect();
    return completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('Socket bağlantı zaman aşımı'),
    );
  }

  io.Socket? get socket => _socket;

  void onRoomState(void Function(dynamic data) handler) {
    _socket?.on('room:state', handler);
  }

  void offRoomState() {
    _socket?.off('room:state');
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}
