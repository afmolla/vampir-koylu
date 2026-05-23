import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'multi_channel_chat.dart';
import 'voice_chat_strip.dart';

/// Oda / genel sohbet + ses — acilir kapanir panel.
void showRoomCommunicationSheet({
  required BuildContext context,
  required io.Socket? socket,
  required String nick,
  String title = 'Sohbet & ses',
  String? roomChannel,
  List<Map<String, dynamic>>? gameChannels,
  bool generalVoice = false,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFF1A1218),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final h = MediaQuery.sizeOf(ctx).height * 0.78;
      final channels = gameChannels ??
          [
            if (roomChannel != null)
              {'id': roomChannel, 'type': 'room'}
            else
              {'id': 'general', 'type': 'general'},
          ];
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
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
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              VoiceChatStrip(
                socket: socket,
                enabled: socket != null,
                generalVoice: generalVoice,
              ),
              Expanded(
                child: MultiChannelChat(
                  socket: socket,
                  nick: nick,
                  channels: channels,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
