import 'dart:math';

enum SoloRole { villager, vampire }

enum SoloPhase { night, dayVote, gameOver }

class SoloPlayer {
  SoloPlayer({
    required this.id,
    required this.name,
    required this.isHuman,
    required this.role,
    this.alive = true,
  });

  final int id;
  final String name;
  final bool isHuman;
  SoloRole role;
  bool alive;
}

class SoloGameState {
  SoloGameState({
    required this.players,
    required this.phase,
    required this.dayNumber,
    this.lastVictimName,
    this.winner,
    this.message,
  });

  final List<SoloPlayer> players;
  final SoloPhase phase;
  final int dayNumber;
  final String? lastVictimName;
  final String? winner; // 'villager' | 'vampire'
  final String? message;

  List<SoloPlayer> get alivePlayers =>
      players.where((p) => p.alive).toList();

  SoloPlayer? get human =>
      players.cast<SoloPlayer?>().firstWhere((p) => p!.isHuman, orElse: () => null);

  bool get humanIsVampire => human?.role == SoloRole.vampire;

  int get vampireCount =>
      alivePlayers.where((p) => p.role == SoloRole.vampire).length;

  int get villagerCount =>
      alivePlayers.where((p) => p.role == SoloRole.villager).length;
}

class SoloGame {
  SoloGame({required this.humanNick, this.rng});

  final String humanNick;
  final Random? rng;
  Random get _rng => rng ?? Random();

  late SoloGameState _state;
  SoloGameState get state => _state;

  static const _botNames = ['Ayşe', 'Mehmet', 'Zeynep', 'Can', 'Elif'];

  void start() {
    final players = <SoloPlayer>[
      SoloPlayer(
        id: 0,
        name: humanNick,
        isHuman: true,
        role: SoloRole.villager,
      ),
      ...List.generate(5, (i) {
        return SoloPlayer(
          id: i + 1,
          name: _botNames[i],
          isHuman: false,
          role: SoloRole.villager,
        );
      }),
    ];

    // 1 vampir, 5 köylü
    final vampIndex = _rng.nextInt(6);
    players[vampIndex].role = SoloRole.vampire;

    _state = SoloGameState(
      players: players,
      phase: SoloPhase.night,
      dayNumber: 1,
      message: 'Gece oldu. Vampir avını seçiyor…',
    );
  }

  String _roleLabel(SoloPlayer p) {
    if (p.isHuman) {
      return p.role == SoloRole.vampire ? 'Sen: Vampir' : 'Sen: Köylü';
    }
    return p.alive ? 'Oyuncu' : 'Ölü';
  }

  SoloGameState _checkWin() {
    if (_state.vampireCount == 0) {
      return SoloGameState(
        players: _state.players,
        phase: SoloPhase.gameOver,
        dayNumber: _state.dayNumber,
        winner: 'villager',
        message: 'Tüm vampirler elendi. Köylüler kazandı!',
      );
    }
    if (_state.vampireCount >= _state.villagerCount) {
      return SoloGameState(
        players: _state.players,
        phase: SoloPhase.gameOver,
        dayNumber: _state.dayNumber,
        winner: 'vampire',
        message: 'Vampirler çoğunlukta. Vampirler kazandı!',
      );
    }
    return _state;
  }

  /// Gece: vampir (insan veya bot) bir kurban seçer.
  SoloGameState nightKill(int targetId) {
    if (_state.phase != SoloPhase.night) return _state;

    final target = _state.players.firstWhere((p) => p.id == targetId);
    if (!target.alive) return _state;

    target.alive = false;
    _state = SoloGameState(
      players: _state.players,
      phase: SoloPhase.dayVote,
      dayNumber: _state.dayNumber,
      lastVictimName: target.name,
      message: '${target.name} gece öldürüldü. Gündüz oylaması başlıyor.',
    );
    return _state;
  }

  /// Bot vampir gece otomatik avlanır.
  SoloGameState autoNightIfNeeded() {
    if (_state.phase != SoloPhase.night) return _state;

    final vampires = _state.alivePlayers.where((p) => p.role == SoloRole.vampire);
    final humanVamp = vampires.any((p) => p.isHuman);
    if (humanVamp) return _state;

    final victims = _state.alivePlayers.where((p) => p.role == SoloRole.villager).toList();
    if (victims.isEmpty) return _checkWin();
    final victim = victims[_rng.nextInt(victims.length)];
    return nightKill(victim.id);
  }

  /// Gündüz oylama — en çok oy alan elenir (basit).
  SoloGameState dayVote(int targetId) {
    if (_state.phase != SoloPhase.dayVote) return _state;

    final votes = <int, int>{};
    for (final p in _state.alivePlayers) {
      int choice;
      if (p.isHuman) {
        choice = targetId;
      } else {
        final candidates = _state.alivePlayers.where((x) => x.id != p.id).toList();
        choice = candidates[_rng.nextInt(candidates.length)].id;
      }
      votes[choice] = (votes[choice] ?? 0) + 1;
    }

    var maxVotes = 0;
    var eliminatedId = targetId;
    votes.forEach((id, count) {
      if (count > maxVotes) {
        maxVotes = count;
        eliminatedId = id;
      }
    });

    final eliminated = _state.players.firstWhere((p) => p.id == eliminatedId);
    eliminated.alive = false;

    _state = SoloGameState(
      players: _state.players,
      phase: SoloPhase.night,
      dayNumber: _state.dayNumber + 1,
      lastVictimName: eliminated.name,
      message: '${eliminated.name} oylandı ve elendi. Yeni gece başlıyor.',
    );

    _state = _checkWin();
    if (_state.phase == SoloPhase.gameOver) return _state;

    return autoNightIfNeeded();
  }

  String roleRevealForHuman() {
    final h = _state.human;
    if (h == null) return '';
    return _roleLabel(h);
  }
}
