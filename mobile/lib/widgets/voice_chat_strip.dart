import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

/// Yakın oyuncu sesi — WebRTC beta (sinyal relay sunucuda).
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

  Future<bool> _ensureMicPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    final result = await Permission.microphone.request();
    if (result.isGranted) return true;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Yakın ses için mikrofon izni gerekli. Ayarlardan izin ver.',
          ),
          duration: Duration(seconds: 4),
        ),
      );
    }
    return false;
  }

  Future<void> _toggleVoice() async {
    final socket = widget.socket;
    if (socket == null || !widget.enabled) return;

    if (_joined) {
      socket.emit('voice:leave');
      setState(() => _joined = false);
      return;
    }

    if (!await _ensureMicPermission()) return;

    socket.emitWithAck('voice:join', {}, ack: (data) {
      if (data is Map && data['ok'] == true && mounted) {
        setState(() => _joined = true);
      }
    });
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
                    ? 'Yakın ses aktif (beta) — ${_muted ? "sessiz" : "efekt: yakınlık"}'
                    : 'Yakındaki oyuncuların sesi (beta)',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
            ),
            IconButton(
              icon: Icon(_muted ? Icons.mic_off : Icons.mic),
              onPressed: () => setState(() => _muted = !_muted),
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
