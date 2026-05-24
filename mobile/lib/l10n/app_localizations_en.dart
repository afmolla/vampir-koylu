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
  String splashServerHost(String host) {
    return 'Server: $host';
  }

  @override
  String splashYourVersion(String version) {
    return 'Installed: $version';
  }

  @override
  String splashServerVersion(String version) {
    return 'Server version: $version';
  }

  @override
  String get splashRetry => 'Try again';

  @override
  String get splashServerUnreachable =>
      'Could not reach the server. Check your internet or try again later.';

  @override
  String get continueOffline => 'Continue offline';

  @override
  String get continueOfflineHint =>
      '6-player room: you + 5 bots. No server required.';

  @override
  String get offlineModeTitle => 'Offline play';

  @override
  String get offlineModeBody =>
      'Play vampire vs villagers with bots without the server. Reconnect from home when you\'re back online.';

  @override
  String get offlinePlayWithBots => 'Play with bots';

  @override
  String get offlineBackToSplash => 'Back — retry connection';

  @override
  String get offlineModeBanner => 'Offline mode — bot matches only';

  @override
  String get offlineTryOnline => 'Connect to server';

  @override
  String get offlineSoloDesc => 'You + 5 bots — full game offline';

  @override
  String get offlineOnlineDisabled =>
      'Unavailable offline. Connect to the server first.';

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
  String get packageConflictTitle => 'Package conflict';

  @override
  String get packageConflictBody =>
      'The app could not be installed because it conflicts with an existing package — the old version was signed differently. You must uninstall it first.';

  @override
  String get packageConflictAfterInstall =>
      'Still conflicting? You may not have uninstalled. Tap Uninstall again, confirm, then download.';

  @override
  String get uninstallAppButton => 'Uninstall app';

  @override
  String get uninstallDialogOpened =>
      'Uninstall screen opened. Tap OK / Uninstall, return here, then check the box below.';

  @override
  String get confirmUninstalled => 'I uninstalled — download the new version';

  @override
  String get mustConfirmUninstall =>
      'Uninstall the app first and check «I uninstalled».';

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
  String updateApkTarget(String version) {
    return 'Download version: v$version';
  }

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
  String get roleRevealVampireHint =>
      'Hunt at night. Keep your identity secret.';

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

  @override
  String get emailLabel => 'Email';

  @override
  String get loginIdentifier => 'Email or username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get signIn => 'Sign in';

  @override
  String get createAccount => 'Create account';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get enterEmailForReset => 'Enter your email address';

  @override
  String get resetLinkSent =>
      'Reset link sent (check email / server log)';

  @override
  String get accountTab => 'Account';

  @override
  String get guestTab => 'Guest';

  @override
  String get registerTitle => 'Create account';

  @override
  String get usernameLabel => 'Username';

  @override
  String get passwordMinHint => 'Password (min 6)';

  @override
  String get registerButton => 'Register';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get registerFailed =>
      'Registration failed. Check your connection.';

  @override
  String get loginFailed => 'Sign in failed';

  @override
  String get googleLoginFailed => 'Google sign-in failed';

  @override
  String get errorNickTaken => 'This username is already taken.';

  @override
  String get errorNickInUse =>
      'This nickname is used by an online player. Try another.';

  @override
  String get errorInvalidNick => 'Nickname must be 2–24 characters.';

  @override
  String get errorCannotDmSelf =>
      'You cannot open a private chat with yourself.';

  @override
  String get errorDmOpenFailed => 'Could not open private chat.';

  @override
  String get errorInvalidCredentials =>
      'Email, username or password is incorrect.';

  @override
  String get errorEmailTaken => 'This email is already registered.';

  @override
  String get errorWeakPassword => 'Password must be at least 6 characters.';

  @override
  String get errorGoogleNotConfigured =>
      'Google sign-in is not configured on the server.';

  @override
  String get errorGoogleNoIdToken =>
      'Google did not return a sign-in token. Check OAuth client ID and app SHA-1 in Google Cloud.';

  @override
  String get errorFacebookNotConfigured =>
      'Facebook sign-in is not configured on the server.';

  @override
  String get errorSocialToken => 'Social sign-in could not be verified.';

  @override
  String get errorLoginFailed => 'Sign in failed.';

  @override
  String get chatAndVoice => 'Chat & voice';

  @override
  String get voiceChat => 'Voice chat';

  @override
  String get joinVoice => 'Join voice';

  @override
  String get leaveVoice => 'Leave voice';

  @override
  String get chat => 'Chat';

  @override
  String get openChat => 'Open chat';

  @override
  String get closeChat => 'Close chat';

  @override
  String get ready => 'Ready';

  @override
  String get notReady => 'Not ready';

  @override
  String get minimizeRoom => 'Minimize room';

  @override
  String get leaveRoom => 'Leave room';

  @override
  String get transferHost => 'Transfer host';

  @override
  String get closeRoom => 'Close room';

  @override
  String get copyCode => 'Copy code';

  @override
  String get codeCopied => 'Code copied';

  @override
  String get youAreHost => 'You are the host';

  @override
  String get generalVoice => 'General voice';

  @override
  String get generalVoiceHint => 'Talk with everyone in the lobby';

  @override
  String get coins => 'Coins';

  @override
  String get dailyReward => 'Daily reward';

  @override
  String get tournamentRolePick => 'Preferred role';

  @override
  String get roleFee => 'Role fee';

  @override
  String get joinTournament => 'Join tournament';

  @override
  String get splashConnecting => 'Connecting to server…';

  @override
  String get splashOffline =>
      'Server unreachable — offline mode available';

  @override
  String get googleLoginCancelled => 'Google sign-in cancelled or failed';

  @override
  String get facebookLoginCancelled =>
      'Facebook sign-in cancelled or failed';

  @override
  String get googleConfiguring => 'Google (configuring…)';

  @override
  String get leaveRoomConfirm => 'Leave room?';

  @override
  String get leaveRoomHint =>
      'Minimize: room stays open, return to main menu.\n'
      'Leave: you exit the room completely.';

  @override
  String get hostLeaveWarning =>
      'As host, leaving cancels the game and costs 25 coins.';

  @override
  String get readyCheck => 'Ready ✓';

  @override
  String get generalChatTitle => 'General chat & voice';

  @override
  String roomChatTitle(String code) => 'Room: $code';

  @override
  String get minimize => 'Minimize';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Leave';

  @override
  String get stay => 'Stay';

  @override
  String get quitGameConfirm => 'Leave game?';

  @override
  String get quitGamePenalty => 'Leave (-25 coins)';

  @override
  String inviteToRoom(String nick, String code) =>
      '$nick invites you to room $code';
}
