import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../services/session_store.dart';
import '../services/voice_rtc_manager.dart';

/// Oda sesli sohbet — WebRTC; mikrofon ikonu gercek track ac/kapa.
class VoiceChatStrip extends StatefulWidget {
  const VoiceChatStrip({
    super.key,
    required this.socket,
    this.enabled = true,
    this.compact = false,
    this.autoJoin = false,
  });

  final io.Socket? socket;
  final bool enabled;
  /// AppBar icin tek satir ikon modu.
  final bool compact;
  /// Oyun/lobi acilinca bir kez ses kanalina katil.
  final bool autoJoin;

  @override
  State<VoiceChatStrip> createState() => _VoiceChatStripState();
}

class _VoiceChatStripState extends State<VoiceChatStrip> {
  bool _joined = false;
  bool _micMuted = false;
  bool _joining = false;
  VoiceRtcManager? _rtc;
  String? _myUserId;

  @override
  void initState() {
    super.initState();
    if (widget.autoJoin && widget.enabled) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _joinVoice());
    }
  }

  @override
  void didUpdateWidget(covariant VoiceChatStrip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.autoJoin &&
        widget.enabled &&
        !_joined &&
        !_joining &&
        widget.socket != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _joinVoice());
    }
  }

  @override
  void dispose() {
    unawaited(_leaveVoice());
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
          content: Text('Sesli sohbet icin mikrofon izni gerekli.'),
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
    if (mounted) {
      setState(() {
        _joined = false;
        _micMuted = false;
        _joining = false;
      });
    }
  }

  Future<void> _joinVoice() async {
    final socket = widget.socket;
    if (socket == null || !widget.enabled || _joined || _joining) return;

    setState(() => _joining = true);
    try {
      if (!await _ensureMicPermission()) return;

      _myUserId ??= await SessionStore().getUserId();
      if (_myUserId == null) return;

      final completer = Completer<bool>();
      socket.emitWithAck('voice:join', {}, ack: (data) async {
        try {
          if (data is Map && data['ok'] == true) {
            _rtc = VoiceRtcManager(socket: socket, myUserId: _myUserId!);
            await _rtc!.start();
            await _rtc!.setMicrophoneMuted(_micMuted);
            final peers = data['peers'] as List<dynamic>? ?? [];
            _rtc!.handlePeersList(peers);
            if (mounted) setState(() => _joined = true);
          } else if (mounted) {
            final err = data is Map ? data['error'] : 'voice_join_failed';
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Ses: $err')),
            );
          }
        } finally {
          if (!completer.isCompleted) completer.complete(true);
        }
      });
      await completer.future.timeout(const Duration(seconds: 12));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ses baglantisi: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _joining = false);
    }
  }

  Future<void> _toggleVoiceChannel() async {
    if (_joined) {
      await _leaveVoice();
    } else {
      await _joinVoice();
    }
  }

  Future<void> _toggleMicMute() async {
    if (!_joined || _rtc == null) return;
    final next = !_micMuted;
    await _rtc!.setMicrophoneMuted(next);
    if (mounted) setState(() => _micMuted = next);
  }

  IconData get _micIcon {
    if (!_joined) return Icons.mic_none;
    return _micMuted ? Icons.mic_off : Icons.mic;
  }

  Color get _micColor {
    if (!_joined) return Colors.white54;
    return _micMuted ? Colors.orangeAccent : Colors.greenAccent;
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) return const SizedBox.shrink();

    if (widget.compact) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: _joined
                ? (_micMuted ? 'Mikrofon kapali' : 'Mikrofon acik')
                : 'Sesli sohbete katil',
            onPressed: _joining
                ? null
                : (_joined ? _toggleMicMute : _toggleVoiceChannel),
            icon: _joining
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(_micIcon, color: _micColor),
          ),
          if (_joined)
            IconButton(
              tooltip: 'Sesi kapat',
              icon: const Icon(Icons.call_end, color: Colors.redAccent, size: 22),
              onPressed: _leaveVoice,
            ),
        ],
      );
    }

    return Card(
      color: Colors.black.withValues(alpha: 0.4),
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(
              _joined ? Icons.headset_mic : Icons.hearing_disabled,
              color: _joined ? Colors.greenAccent : Colors.white54,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _joining
                    ? 'Ses baglaniyor...'
                    : _joined
                        ? (_micMuted
                            ? 'Sesli sohbet — mikrofon kapali'
                            : 'Sesli sohbet — mikrofon acik')
                        : 'Sesli sohbet (odaya konus)',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
            IconButton(
              tooltip: _joined
                  ? (_micMuted ? 'Mikrofonu ac' : 'Mikrofonu kapat')
                  : 'Sesli sohbete katil',
              onPressed: _joining
                  ? null
                  : (_joined ? _toggleMicMute : _toggleVoiceChannel),
              icon: Icon(_micIcon, color: _micColor),
            ),
            if (_joined)
              IconButton(
                tooltip: 'Kanaldan cik',
                icon: const Icon(Icons.call_end, color: Colors.redAccent),
                onPressed: _leaveVoice,
              )
            else
              FilledButton.tonal(
                onPressed: _joining ? null : _joinVoice,
                child: const Text('Katil'),
              ),
          ],
        ),
      ),
    );
  }
}
