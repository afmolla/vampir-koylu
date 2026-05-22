// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Vampire Village';

  @override
  String get splashLoading => 'Checking for updates…';

  @override
  String get splashConnectingServer => 'Checking server connection…';

  @override
  String get splashCheckingVersion => 'Checking app version…';

  @override
  String splashServerHost(String host) => 'Server: $host';

  @override
  String splashYourVersion(String version) => 'Installed: $version';

  @override
  String splashServerVersion(String version) => 'Server version: $version';

  @override
  String get splashRetry => 'Try again';

  @override
  String get forceUpdateTitle => 'Update required';

  @override
  String get forceUpdateBody =>
      'This version is no longer supported. Please install the latest release to continue.';

  @override
  String get updateButton => 'Download update';

  @override
  String get downloadAndInstall => 'Download and install';

  @override
  String downloading(int percent) {
    return 'Downloading… %$percent';
  }

  @override
  String get downloadFailed => 'Download failed';

  @override
  String get installOpened => 'Installer opened. Tap Install / Update.';

  @override
  String get installConflictHint =>
      'Package conflict means the old install was signed differently. Tap Uninstall, then Download and install.';

  @override
  String get uninstallAppButton => 'Uninstall app (settings)';

  @override
  String get uninstallSettingsOpened =>
      'Settings opened. Tap Uninstall, return here, then download the update.';

  @override
  String get uninstallSettingsFailed =>
      'Could not open settings. Go to Settings → Apps → Vampire Village → Uninstall.';

  @override
  String get forceUpdateSteps =>
      '1) Uninstall  2) Download and install  3) Future updates work in-app';

  @override
  String get installedVersion => 'Installed version:';

  @override
  String get openInBrowser => 'Open in browser (fallback)';

  @override
  String get loginTitle => 'Sign in';

  @override
  String get guestNickHint => 'Nickname';

  @override
  String get guestPlay => 'Play as guest';

  @override
  String get googleSignIn => 'Sign in with Google';

  @override
  String get facebookSignIn => 'Sign in with Facebook';

  @override
  String homeWelcome(String nick) {
    return 'Welcome, $nick';
  }

  @override
  String get homeSubtitle => 'Choose a mode';

  @override
  String get language => 'Language';

  @override
  String get errorNetwork =>
      'Connection error. Check your network and try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get soloPlay => 'Play solo';

  @override
  String get soloPlayDesc => '6-player room (you + 5 bots) — quick match';

  @override
  String get onlinePlay => 'Play online';

  @override
  String get onlinePlayDesc => '2–8 real players — join with room code';

  @override
  String get onlineSoon => 'Online mode coming soon';

  @override
  String get onlineLobbyTitle => 'Online lobbies';

  @override
  String get onlineLobbyDesc =>
      'Create a room or join open lobbies. Game starts with at least 2 players.';

  @override
  String get soloRoomHint =>
      'You can open a room alone; it appears in the open rooms list while you wait.';

  @override
  String get roomFull => 'Full';

  @override
  String get roomCodeHint => 'Room code';

  @override
  String get joinRoom => 'Join';

  @override
  String get createRoom => 'Create room';

  @override
  String get maxPlayers => 'Max players';

  @override
  String get openRooms => 'Open rooms';

  @override
  String get noOpenRooms => 'No open rooms — create one.';

  @override
  String hostLabel(String nick) {
    return 'Host: $nick';
  }

  @override
  String get roomCode => 'Room';

  @override
  String get roomWaiting => 'Waiting for players…';

  @override
  String playersCount(int current, int max) {
    return '$current / $max players';
  }

  @override
  String get host => 'Host';

  @override
  String get needSixPlayers => 'At least 6 players required to start.';

  @override
  String get needTwoPlayers => 'At least 2 players required to start.';

  @override
  String get startGame => 'Start game';

  @override
  String get backToLobby => 'Back to menu';

  @override
  String yourRole(String role) {
    return 'Your role: $role';
  }

  @override
  String lastVictim(String name) {
    return 'Last eliminated: $name';
  }

  @override
  String get eliminated => 'Eliminated';

  @override
  String get chatHint => 'Type a message…';

  @override
  String get chatGeneral => 'General chat';

  @override
  String get chatRoom => 'Room chat';

  @override
  String get soloTitle => 'Solo';

  @override
  String get phaseNight => 'Night phase';

  @override
  String get phaseDay => 'Day vote';

  @override
  String get phaseDawn => 'Dawn breaks';

  @override
  String get phaseGameOver => 'Game over';

  @override
  String get phaseHintNight => 'The vampire is hunting…';

  @override
  String get phaseHintDayVote => 'Vote to eliminate a suspect.';

  @override
  String get roleRevealVampire => 'You are the Vampire';

  @override
  String get roleRevealVillager => 'You are a Villager';

  @override
  String get roleRevealVampireHint => 'Hunt at night. Keep your identity secret.';

  @override
  String get roleRevealVillagerHint => 'Vote by day to find the vampire.';

  @override
  String get dayLabel => 'Day';

  @override
  String get you => 'you';

  @override
  String get waitingVampire => 'The vampire is choosing…';

  @override
  String get tapToVote => 'Tap a player to vote them out';

  @override
  String get villagersWin => 'Villagers win!';

  @override
  String get vampiresWin => 'Vampires win!';

  @override
  String get playAgain => 'Play again';

  @override
  String get matchSummaryTitle => 'Match summary';

  @override
  String get summaryKills => 'Who eliminated whom';

  @override
  String get summaryLies => 'Who lied';

  @override
  String get summaryMostAccused => 'Most accused';

  @override
  String get summaryMvp => 'MVP';

  @override
  String get summaryNone => 'No records';
}
