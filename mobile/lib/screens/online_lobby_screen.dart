import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../core/config.dart';
import '../l10n/app_localizations.dart';
import '../services/session_store.dart';
import '../services/socket_service.dart';
import '../widgets/chat_popup_launcher.dart';
import 'online_room_screen.dart';

class OnlineLobbyScreen extends StatefulWidget {
  const OnlineLobbyScreen({
    super.key,
    required this.nick,
    this.socketService,
    this.joinCode,
  });

  final String nick;
  final SocketService? socketService;
  final String? joinCode;

  @override
  State<OnlineLobbyScreen> createState() => _OnlineLobbyScreenState();
}

class _OnlineLobbyScreenState extends State<OnlineLobbyScreen> {
  final _joinController = TextEditingController();
  late final SocketService _socketService =
      widget.socketService ?? SocketService();
  bool get _ownsSocket => widget.socketService == null;
  List<Map<String, dynamic>> _rooms = [];
  bool _loading = true;
  bool _socketReady = false;
  String? _error;
  int _minPlayers = 4;
  int _maxPlayers = 6;
  String _botDifficulty = 'normal';
  bool _fillWithBots = true;
  Timer? _roomRefreshTimer;

  @override
  void initState() {
    super.initState();
    _loadRooms();
    _connectSocket();
    _roomRefreshTimer = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _loadRooms(silent: true),
    );
    if (widget.joinCode != null) {
      _joinController.text = widget.joinCode!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _joinRoom(widget.joinCode);
      });
    }
  }

  @override
  void dispose() {
    _roomRefreshTimer?.cancel();
    _joinController.dispose();
    if (_ownsSocket) _socketService.disconnect();
    super.dispose();
  }

  Future<void> _connectSocket() async {
    try {
      final token = await SessionStore().getToken();
      if (token == null || token.isEmpty) return;
      await _socketService.connect(token: token);
      _socketService.socket?.emit('chat:join', {'channel': 'general'});
      if (mounted) setState(() => _socketReady = true);
    } catch (_) {
      if (mounted) setState(() => _socketReady = false);
    }
  }

  Future<void> _loadRooms({bool silent = false}) async {
    if (!silent && mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final res = await http
          .get(Uri.parse('${AppConfig.apiBaseUrl}/api/rooms'))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) throw Exception('HTTP ${res.statusCode}');
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final list = data['rooms'] as List<dynamic>? ?? [];
      if (mounted) {
        setState(() {
          _rooms = list.cast<Map<String, dynamic>>();
          _loading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          if (!silent) _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _withSocket(Future<void> Function(dynamic socket) fn) async {
    if (!_socketReady) await _connectSocket();
    final socket = _socketService.socket;
    if (socket == null) throw Exception('no_socket');
    await fn(socket);
  }

  Future<void> _createRoom() async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _withSocket((socket) async {
        final completer = Completer<Map<String, dynamic>?>();
        socket.emitWithAck(
          'room:create',
          {
            'nick': widget.nick,
            'minPlayers': _minPlayers,
            'maxPlayers': _maxPlayers,
            'fillWithBots': _fillWithBots,
            'botDifficulty': _botDifficulty,
          },
          ack: (data) {
            if (data is Map && data['ok'] == true) {
              completer.complete(data['room'] as Map<String, dynamic>?);
            } else {
              completer.completeError(
                Exception(data?.toString() ?? 'create_failed'),
              );
            }
          },
        );
        final room =
            await completer.future.timeout(const Duration(seconds: 10));
        if (!mounted || room == null) return;
        await _loadRooms(silent: true);
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OnlineRoomScreen(
              nick: widget.nick,
              socketService: _socketService,
              initialRoom: room,
            ),
          ),
        );
        _loadRooms();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorGeneric}\n$e')),
        );
      }
    }
  }

  Future<void> _joinRoom([String? code]) async {
    final l10n = AppLocalizations.of(context)!;
    final c = (code ?? _joinController.text).trim().toUpperCase();
    if (c.length < 4) return;
    try {
      await _withSocket((socket) async {
        final completer = Completer<Map<String, dynamic>?>();
        socket.emitWithAck(
          'room:join',
          {'code': c, 'nick': widget.nick},
          ack: (data) {
            if (data is Map && data['ok'] == true) {
              completer.complete(data['room'] as Map<String, dynamic>?);
            } else {
              final err = data is Map ? data['error'] : 'join_failed';
              completer.completeError(Exception('$err'));
            }
          },
        );
        final room =
            await completer.future.timeout(const Duration(seconds: 10));
        if (!mounted || room == null) return;
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => OnlineRoomScreen(
              nick: widget.nick,
              socketService: _socketService,
              initialRoom: room,
            ),
          ),
        );
        _loadRooms();
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${l10n.errorGeneric}\n$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.onlinePlay),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadRooms),
        ],
      ),
      floatingActionButton: _socketReady
          ? ChatFab(socket: _socketService.socket, nick: widget.nick)
          : null,
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
                Text(
                  l10n.onlineLobbyTitle,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.onlineLobbyDesc,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _joinController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: l10n.roomCodeHint,
                          hintText: 'ABC123',
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () => _joinRoom(),
                      child: Text(l10n.joinRoom),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Min'),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _minPlayers,
                      items: [4, 5, 6, 7, 8]
                          .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                          .toList(),
                      onChanged: (v) => setState(() {
                        _minPlayers = v ?? 4;
                        if (_maxPlayers < _minPlayers) _maxPlayers = _minPlayers;
                      }),
                    ),
                    const SizedBox(width: 16),
                    Text(l10n.maxPlayers),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _maxPlayers,
                      items: [4, 5, 6, 7, 8]
                          .where((n) => n >= _minPlayers)
                          .map((n) => DropdownMenuItem(value: n, child: Text('$n')))
                          .toList(),
                      onChanged: (v) => setState(() => _maxPlayers = v ?? 6),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: _botDifficulty,
                  decoration: const InputDecoration(labelText: 'Bot zorluğu'),
                  items: const [
                    DropdownMenuItem(value: 'easy', child: Text('Kolay')),
                    DropdownMenuItem(value: 'normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'hard', child: Text('Zor')),
                  ],
                  onChanged: (v) => setState(() => _botDifficulty = v ?? 'normal'),
                ),
                const SizedBox(height: 8),
                FilledButton.icon(
                  onPressed: _createRoom,
                  icon: const Icon(Icons.add),
                  label: Text(l10n.createRoom),
                ),
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Eksik oyuncuları bot ile doldur',
                    style: TextStyle(fontSize: 14),
                  ),
                  subtitle: Text(
                    'En az $_minPlayers oyuncu · tek başına başlayabilirsin.',
                    style: const TextStyle(fontSize: 12, color: Colors.white54),
                  ),
                  value: _fillWithBots,
                  onChanged: (v) => setState(() => _fillWithBots = v ?? true),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Text(
                      l10n.openRooms,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const Spacer(),
                    if (!_loading)
                      Text(
                        '${_rooms.length}',
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                if (_loading) const Center(child: CircularProgressIndicator()),
                if (_error != null)
                  Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                if (!_loading && _rooms.isEmpty)
                  Text(
                    l10n.noOpenRooms,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ..._rooms.map((r) {
                  final count = r['playerCount'] as int? ?? 0;
                  final max = r['maxPlayers'] as int? ?? 2;
                  return Card(
                    child: ListTile(
                      title: Text('${r['code']} — $count/$max'),
                      subtitle: Text(
                        l10n.hostLabel(r['hostNick'] as String? ?? '?'),
                      ),
                      trailing: count < max
                          ? const Icon(Icons.chevron_right)
                          : Text(
                              l10n.roomFull,
                              style: const TextStyle(color: Colors.white38),
                            ),
                      onTap: count < max
                          ? () => _joinRoom(r['code'] as String?)
                          : null,
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
