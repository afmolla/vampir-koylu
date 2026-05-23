import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'general_chat_hub.dart';

/// Klavye acilinca kapanmayan, sabit state'li sohbet paneli.
void showAppChatSheet({
  required BuildContext context,
  required io.Socket? socket,
  required String nick,
  String title = 'Sohbet',
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    enableDrag: true,
    backgroundColor: const Color(0xFF1A1218),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetContext) {
      return _ChatSheetBody(
        socket: socket,
        nick: nick,
        title: title,
      );
    },
  );
}

class _ChatSheetBody extends StatefulWidget {
  const _ChatSheetBody({
    required this.socket,
    required this.nick,
    required this.title,
  });

  final io.Socket? socket;
  final String nick;
  final String title;

  @override
  State<_ChatSheetBody> createState() => _ChatSheetBodyState();
}

class _ChatSheetBodyState extends State<_ChatSheetBody> {
  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.viewInsetsOf(context);
    final maxH = MediaQuery.sizeOf(context).height;
    final sheetH = (maxH * 0.88 - insets.bottom).clamp(320.0, maxH * 0.92);

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
              padding: const EdgeInsets.fromLTRB(12, 10, 8, 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GeneralChatHub(
                key: const ValueKey('app_chat_hub'),
                socket: widget.socket,
                nick: widget.nick,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
