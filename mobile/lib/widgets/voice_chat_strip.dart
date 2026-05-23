import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../services/session_store.dart';
import '../services/voice_rtc_manager.dart';

/// Yakın oyuncu sesi — WebRTC + socket sinyal.
class VoiceChatStrip extends StatefulWidget {
  const VoiceChatStrip({
    super.key,
    required this.socket,
    this.enabled = true,
  });

  final io.Socket? socket;
  final bool enabled;

  @override
  State<VoiceChatStrip> createState() => _VoiceChatStripState();
}

class _VoiceChatStripState extends State<VoiceChatStrip> {
  bool _joined = false;
  bool _muted = false;
  VoiceRtcManager? _rtc;
  String? _myUserId;

  @override
  void dispose() {
    _leaveVoice();
    super.dispose();
  }

  Future<bool> _ensureMicPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    final result = await Permission.microphone.request();
    if (result.isGranted) return true;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Yakın ses için mikrofon izni gerekli.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
    return false;
  }

  Future<void> _leaveVoice() async {
    widget.socket?.emit('voice:leave');
    await _rtc?.stop();
    _rtc = null;
    if (mounted) setState(() => _joined = false);
  }

  Future<void> _toggleVoice() async {
    final socket = widget.socket;
    if (socket == null || !widget.enabled) return;

    if (_joined) {
      await _leaveVoice();
      return;
    }

    if (!await _ensureMicPermission()) return;

    _myUserId ??= await SessionStore().getUserId();
    if (_myUserId == null) return;

    final completer = Completer<void>();
    socket.emitWithAck('voice:join', {}, ack: (data) async {
      if (data is Map && data['ok'] == true) {
        _rtc = VoiceRtcManager(socket: socket, myUserId: _myUserId!);
        await _rtc!.start();
        final peers = data['peers'] as List<dynamic>? ?? [];
        _rtc!.handlePeersList(peers);
        if (mounted) setState(() => _joined = true);
      }
      if (!completer.isCompleted) completer.complete();
    });
    await completer.future;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();

    return Card(
      color: Colors.black.withValues(alpha: 0.4),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              _joined ? Icons.graphic_eq : Icons.hearing_disabled,
              color: _joined ? Colors.greenAccent : Colors.white54,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _joined
                    ? 'Yakın ses (WebRTC) — ${_muted ? "sessiz" : "açık"}'
                    : 'Yakındaki oyuncuların sesi',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
            IconButton(
              icon: Icon(_muted ? Icons.mic_off : Icons.mic),
              onPressed: _joined
                  ? () => setState(() => _muted = !_muted)
                  : null,
            ),
            FilledButton.tonal(
              onPressed: _toggleVoice,
              child: Text(_joined ? 'Kapat' : 'Ses'),
            ),
          ],
        ),
      ),
    );
  }
}
