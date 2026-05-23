import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'chat_bottom_sheet.dart';

/// Alttan acilan sohbet — klavye ile state kaybolmaz.
void showChatPopup({
  required BuildContext context,
  required io.Socket? socket,
  required String nick,
}) {
  showAppChatSheet(context: context, socket: socket, nick: nick);
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
