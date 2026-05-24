import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'chat_panel.dart';

/// Canlı / ölü / vampir gece kanalları.
class MultiChannelChat extends StatefulWidget {
  const MultiChannelChat({
    super.key,
    required this.socket,
    required this.nick,
    required this.channels,
    this.height = 160,
    this.expanded = false,
  });

  final io.Socket? socket;
  final String nick;
  final List<Map<String, dynamic>> channels;
  final double height;
  final bool expanded;

  @override
  State<MultiChannelChat> createState() => _MultiChannelChatState();
}

class _MultiChannelChatState extends State<MultiChannelChat> {
  int _index = 0;

  String _tabLabel(Map<String, dynamic> ch) {
    final type = ch['type'] as String? ?? '';
    switch (type) {
      case 'dead':
        return 'Ölüler';
      case 'vampire':
        return 'Vampir (gece)';
      case 'proximity':
        return 'Yakın';
      default:
        return 'Oda';
    }
  }

  @override
  Widget build(BuildContext context) {
    final channels = widget.channels;
    if (channels.isEmpty) {
      final panel = ChatPanel(
        socket: widget.socket,
        channel: 'general',
        nick: widget.nick,
      );
      if (widget.expanded) return panel;
      return SizedBox(height: widget.height, child: panel);
    }

    final safeIndex = _index.clamp(0, channels.length - 1);
    final active = channels[safeIndex];
    final channelId = active['id'] as String? ?? 'general';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(channels.length, (i) {
              final selected = i == safeIndex;
              return Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ChoiceChip(
                  label: Text(_tabLabel(channels[i])),
                  selected: selected,
                  onSelected: (_) => setState(() => _index = i),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 6),
        if (widget.expanded)
          Expanded(
            child: ChatPanel(
              socket: widget.socket,
              channel: channelId,
              nick: widget.nick,
            ),
          )
        else
          SizedBox(
            height: widget.height,
            child: ChatPanel(
              socket: widget.socket,
              channel: channelId,
              nick: widget.nick,
            ),
          ),
      ],
    );
  }
}
