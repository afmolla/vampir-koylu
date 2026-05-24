import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../l10n/app_localizations.dart';
import 'room_communication_sheet.dart';

/// Tek sohbet girisi — ses panelin icinde.
void showChatPopup({
  required BuildContext context,
  required io.Socket? socket,
  required String nick,
}) {
  showRoomCommunicationSheet(
    context: context,
    socket: socket,
    nick: nick,
    useGeneralHub: true,
    generalVoice: true,
    autoJoinVoice: false,
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
    final l10n = AppLocalizations.of(context)!;
    return FloatingActionButton.extended(
      onPressed: () => showChatPopup(context: context, socket: socket, nick: nick),
      icon: const Icon(Icons.forum_outlined),
      label: Text(l10n.chat),
    );
  }
}
