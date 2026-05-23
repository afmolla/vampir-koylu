import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'general_chat_hub.dart';

/// Alttan acilan sohbet — uygulama kapaninca UI sifirlanir, mesajlar DB'den yuklenir.
void showChatPopup({
  required BuildContext context,
  required io.Socket? socket,
  required String nick,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1A1218),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final h = MediaQuery.of(ctx).size.height * 0.72;
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SizedBox(
          height: h,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  'Sohbet',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Expanded(
                child: GeneralChatHub(
                  key: ValueKey('chat_${DateTime.now().millisecondsSinceEpoch}'),
                  socket: socket,
                  nick: nick,
                  height: h - 80,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class ChatFab extends StatelessWidget {
  const ChatFab({
    super.key,
    required this.socket,
    required this.nick,
  });

  final io.Socket? socket;
  final String nick;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => showChatPopup(context: context, socket: socket, nick: nick),
      icon: const Icon(Icons.chat_bubble_outline),
      label: const Text('Sohbet'),
    );
  }
}
