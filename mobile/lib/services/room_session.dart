import 'chat_session_store.dart';

/// Aktif oda — ekrandan cikinca socket baglantisi korunur.
class RoomSession {
  RoomSession._();

  static String? activeRoomCode;
  static String? activeRoomNick;
  static Map<String, dynamic>? lastRoomState;

  static void setActive({
    required String code,
    required String nick,
    Map<String, dynamic>? state,
  }) {
    activeRoomCode = code;
    activeRoomNick = nick;
    if (state != null) lastRoomState = state;
  }

  static void updateState(Map<String, dynamic> state) {
    lastRoomState = state;
  }

  static void clear() {
    final code = activeRoomCode;
    if (code != null && code.isNotEmpty) {
      ChatSessionStore.clearForRoom(code);
    }
    activeRoomCode = null;
    activeRoomNick = null;
    lastRoomState = null;
  }

  static bool get hasActiveRoom =>
      activeRoomCode != null && activeRoomCode!.isNotEmpty;
}
