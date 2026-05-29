import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../l10n/app_localizations.dart';
import 'general_chat_hub.dart';
import 'multi_channel_chat.dart';
import 'voice_chat_strip.dart';

List<Map<String, dynamic>> _textChannels(List<Map<String, dynamic>> channels) {
  return channels
      .where((c) => (c['type'] as String? ?? '') != 'proximity')
      .toList();
}

/// Tek panel: ustte ses, altta sohbet (genel+ozel veya oda kanallari).
void showRoomCommunicationSheet({
  required BuildContext context,
  required io.Socket? socket,
  required String nick,
  String? title,
  String? roomChannel,
  List<Map<String, dynamic>>? gameChannels,
  bool generalVoice = false,
  bool useGeneralHub = false,
  bool autoJoinVoice = false,
}) {
  final l10n = AppLocalizations.of(context)!;
  final sheetTitle = title ?? l10n.chat;

  final channels = gameChannels ??
      [
        if (roomChannel != null)
          {'id': roomChannel, 'type': 'room'}
        else
          {'id': 'general', 'type': 'general'},
      ];
  final textCh = _textChannels(channels);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: const Color(0xFF1A1218),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final insets = MediaQuery.viewInsetsOf(ctx);
      final maxH = MediaQuery.sizeOf(ctx).height;
      final sheetH = (maxH * 0.88 - insets.bottom).clamp(340.0, maxH * 0.92);

      return Padding(
        padding: EdgeInsets.only(bottom: insets.bottom),
        child: SizedBox(
          height: sheetH,
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
                        sheetTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    VoiceChatStrip(
                      socket: socket,
                      enabled: socket != null,
                      compact: true,
                      generalVoice: generalVoice,
                      autoJoin: autoJoinVoice,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Colors.white12),
              Expanded(
                child: useGeneralHub
                    ? GeneralChatHub(
                        socket: socket,
                        nick: nick,
                      )
                    : MultiChannelChat(
                        socket: socket,
                        nick: nick,
                        channels: textCh.isEmpty
                            ? [
                                {'id': 'general', 'type': 'general'},
                              ]
                            : textCh,
                        expanded: true,
                      ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
