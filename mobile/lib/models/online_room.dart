class OnlineRoomPlayer {
  OnlineRoomPlayer({
    required this.userId,
    required this.nick,
    required this.isHost,
  });

  final String userId;
  final String nick;
  final bool isHost;

  factory OnlineRoomPlayer.fromJson(Map<String, dynamic> j) {
    return OnlineRoomPlayer(
      userId: j['userId'] as String? ?? '',
      nick: j['nick'] as String? ?? '?',
      isHost: j['isHost'] == true,
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

class OnlineGameState {
  OnlineGameState({
    required this.phase,
    required this.dayNumber,
    this.message,
    this.lastVictimName,
    this.winner,
    required this.players,
    this.yourRole,
    this.canAct = false,
    this.validTargets = const [],
  });

  final String phase;
  final int dayNumber;
  final String? message;
  final String? lastVictimName;
  final String? winner;
  final List<OnlineGamePlayer> players;
  final String? yourRole;
  final bool canAct;
  final List<int> validTargets;

  factory OnlineGameState.fromJson(Map<String, dynamic> j) {
    final list = j['players'] as List<dynamic>? ?? [];
    final targets = j['validTargets'] as List<dynamic>? ?? [];
    return OnlineGameState(
      phase: j['phase'] as String? ?? 'night',
      dayNumber: j['dayNumber'] as int? ?? 1,
      message: j['message'] as String?,
      lastVictimName: j['lastVictimName'] as String?,
      winner: j['winner'] as String?,
      players: list
          .map((e) => OnlineGamePlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      yourRole: j['yourRole'] as String?,
      canAct: j['canAct'] == true,
      validTargets: targets.map((e) => e as int).toList(),
    );
  }
}

class OnlineRoomState {
  OnlineRoomState({
    required this.code,
    required this.status,
    required this.maxPlayers,
    required this.players,
    this.game,
  });

  final String code;
  final String status;
  final int maxPlayers;
  final List<OnlineRoomPlayer> players;
  final OnlineGameState? game;

  factory OnlineRoomState.fromJson(Map<String, dynamic> j) {
    final list = j['players'] as List<dynamic>? ?? [];
    final gameJson = j['game'] as Map<String, dynamic>?;
    return OnlineRoomState(
      code: j['code'] as String? ?? '',
      status: j['status'] as String? ?? 'lobby',
      maxPlayers: j['maxPlayers'] as int? ?? 6,
      players: list
          .map((e) => OnlineRoomPlayer.fromJson(e as Map<String, dynamic>))
          .toList(),
      game: gameJson != null ? OnlineGameState.fromJson(gameJson) : null,
    );
  }
}
