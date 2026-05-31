class OnlineRoomPlayer {
  OnlineRoomPlayer({
    required this.userId,
    required this.nick,
    required this.isHost,
    this.isBot = false,
    this.ready = false,
  });

  final String userId;
  final String nick;
  final bool isHost;
  final bool isBot;
  final bool ready;

  factory OnlineRoomPlayer.fromJson(Map<String, dynamic> j) {
    return OnlineRoomPlayer(
      userId: j['userId'] as String? ?? '',
      nick: j['nick'] as String? ?? '?',
      isHost: j['isHost'] == true,
      isBot: j['isBot'] == true,
      ready: j['ready'] == true,
    );
  }
}

class OnlineGamePlayer {
  OnlineGamePlayer({
    required this.id,
    required this.nick,
    required this.alive,
  });

  final int id;
  final String nick;
  final bool alive;

  factory OnlineGamePlayer.fromJson(Map<String, dynamic> j) {
    return OnlineGamePlayer(
      id: j['id'] as int? ?? 0,
      nick: j['nick'] as String? ?? '?',
      alive: j['alive'] != false,
    );
  }
}

class NightInsight {
  NightInsight({
    required this.kind,
    required this.nick,
    this.alignment,
    this.role,
  });

  final String kind;
  final String nick;
  final String? alignment;
  final String? role;

  factory NightInsight.fromJson(Map<String, dynamic>? j) {
    if (j == null) {
      return NightInsight(kind: '', nick: '');
    }
    return NightInsight(
      kind: j['kind'] as String? ?? '',
      nick: j['nick'] as String? ?? '?',
      alignment: j['alignment'] as String?,
      role: j['role'] as String?,
    );
  }
}

class RevealedRole {
  RevealedRole({
    required this.nick,
    required this.role,
    required this.alive,
  });

  final String nick;
  final String role;
  final bool alive;

  factory RevealedRole.fromJson(Map<String, dynamic> j) {
    return RevealedRole(
      nick: j['nick'] as String? ?? '?',
      role: j['role'] as String? ?? '',
      alive: j['alive'] != false,
    );
  }
}

class OnlineGameState {
  OnlineGameState({
    required this.phase,
    required this.dayNumber,
    this.message,
    this.lastVictimName,
    this.winner,
    this.noKillNight = false,
    this.hunterRevengeNick,
    required this.players,
    this.yourRole,
    this.canAct = false,
    this.validTargets = const [],
    this.nightInsight,
    this.revealedRoles = const [],
    this.chatChannels = const [],
    this.matchSummary,
  });

  final String phase;
  final int dayNumber;
  final String? message;
  final String? lastVictimName;
  final String? winner;
  final bool noKillNight;
  final String? hunterRevengeNick;
  final List<OnlineGamePlayer> players;
  final String? yourRole;
  final bool canAct;
  final List<int> validTargets;
  final NightInsight? nightInsight;
  final List<RevealedRole> revealedRoles;
  final List<Map<String, dynamic>> chatChannels;
  final Map<String, dynamic>? matchSummary;

  factory OnlineGameState.fromJson(Map<String, dynamic> j) {
    final list = j['players'] as List<dynamic>? ?? [];
    final targets = j['validTargets'] as List<dynamic>? ?? [];
    final revealed = j['revealedRoles'] as List<dynamic>? ?? [];
    final insightRaw = j['nightInsight'];
    return OnlineGameState(
      phase: j['phase'] as String? ?? 'night',
      dayNumber: j['dayNumber'] as int? ?? 1,
      message: j['message'] as String?,
      lastVictimName: j['lastVictimName'] as String?,
      winner: j['winner'] as String?,
      noKillNight: j['noKillNight'] == true,
      hunterRevengeNick: j['hunterRevengeNick'] as String?,
      players: list
          .map((e) => OnlineGamePlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      yourRole: j['yourRole'] as String?,
      canAct: j['canAct'] == true,
      validTargets: targets.map((e) => e as int).toList(),
      nightInsight: insightRaw is Map<String, dynamic>
          ? NightInsight.fromJson(insightRaw)
          : null,
      revealedRoles: revealed
          .map((e) => RevealedRole.fromJson(e as Map<String, dynamic>))
          .toList(),
      chatChannels: (j['chatChannels'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      matchSummary: j['matchSummary'] as Map<String, dynamic>?,
    );
  }
}

class OnlineRoomState {
  OnlineRoomState({
    required this.code,
    required this.status,
    required this.maxPlayers,
    this.minPlayers = 6,
    required this.players,
    this.fillWithBots = false,
    this.game,
  });

  final String code;
  final String status;
  final int maxPlayers;
  final int minPlayers;
  final bool fillWithBots;
  final List<OnlineRoomPlayer> players;
  final OnlineGameState? game;

  Map<String, dynamic> toJson() => {
        'code': code,
        'status': status,
        'maxPlayers': maxPlayers,
        'minPlayers': minPlayers,
        'fillWithBots': fillWithBots,
        'players': players
            .map(
              (p) => {
                'userId': p.userId,
                'nick': p.nick,
                'isHost': p.isHost,
                'isBot': p.isBot,
                'ready': p.ready,
              },
            )
            .toList(),
        if (game != null) 'game': {'phase': game!.phase},
      };

  factory OnlineRoomState.fromJson(Map<String, dynamic> j) {
    final list = j['players'] as List<dynamic>? ?? [];
    final gameJson = j['game'] as Map<String, dynamic>?;
    return OnlineRoomState(
      code: j['code'] as String? ?? '',
      status: j['status'] as String? ?? 'lobby',
      maxPlayers: j['maxPlayers'] as int? ?? 6,
      minPlayers: j['minPlayers'] as int? ?? 6,
      fillWithBots: j['fillWithBots'] == true,
      players: list
          .map((e) => OnlineRoomPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      game: gameJson != null ? OnlineGameState.fromJson(gameJson) : null,
    );
  }
}
