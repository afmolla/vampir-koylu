import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Vampire Village'**
  String get appTitle;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Checking for updates…'**
  String get splashLoading;

  /// No description provided for @splashConnectingServer.
  ///
  /// In en, this message translates to:
  /// **'Checking server connection…'**
  String get splashConnectingServer;

  /// No description provided for @splashCheckingVersion.
  ///
  /// In en, this message translates to:
  /// **'Checking app version…'**
  String get splashCheckingVersion;

  /// No description provided for @splashServerHost.
  ///
  /// In en, this message translates to:
  /// **'Server: {host}'**
  String splashServerHost(String host);

  /// No description provided for @splashYourVersion.
  ///
  /// In en, this message translates to:
  /// **'Installed: {version}'**
  String splashYourVersion(String version);

  /// No description provided for @splashServerVersion.
  ///
  /// In en, this message translates to:
  /// **'Server version: {version}'**
  String splashServerVersion(String version);

  /// No description provided for @splashRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get splashRetry;

  /// No description provided for @splashServerUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Could not reach the server. Check your internet or try again later.'**
  String get splashServerUnreachable;

  /// No description provided for @continueOffline.
  ///
  /// In en, this message translates to:
  /// **'Continue offline'**
  String get continueOffline;

  /// No description provided for @continueOfflineHint.
  ///
  /// In en, this message translates to:
  /// **'6-player room: you + 5 bots. No server required.'**
  String get continueOfflineHint;

  /// No description provided for @offlineModeTitle.
  ///
  /// In en, this message translates to:
  /// **'Offline play'**
  String get offlineModeTitle;

  /// No description provided for @offlineModeBody.
  ///
  /// In en, this message translates to:
  /// **'Play vampire vs villagers with bots without the server. Reconnect from home when you\'re back online.'**
  String get offlineModeBody;

  /// No description provided for @offlinePlayWithBots.
  ///
  /// In en, this message translates to:
  /// **'Play with bots'**
  String get offlinePlayWithBots;

  /// No description provided for @offlineBackToSplash.
  ///
  /// In en, this message translates to:
  /// **'Back — retry connection'**
  String get offlineBackToSplash;

  /// No description provided for @offlineModeBanner.
  ///
  /// In en, this message translates to:
  /// **'Offline mode — bot matches only'**
  String get offlineModeBanner;

  /// No description provided for @offlineTryOnline.
  ///
  /// In en, this message translates to:
  /// **'Connect to server'**
  String get offlineTryOnline;

  /// No description provided for @offlineSoloDesc.
  ///
  /// In en, this message translates to:
  /// **'You + 5 bots — full game offline'**
  String get offlineSoloDesc;

  /// No description provided for @offlineOnlineDisabled.
  ///
  /// In en, this message translates to:
  /// **'Unavailable offline. Connect to the server first.'**
  String get offlineOnlineDisabled;

  /// No description provided for @forceUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get forceUpdateTitle;

  /// No description provided for @forceUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'This version is no longer supported. Please install the latest release to continue.'**
  String get forceUpdateBody;

  /// No description provided for @updateButton.
  ///
  /// In en, this message translates to:
  /// **'Download update'**
  String get updateButton;

  /// No description provided for @downloadAndInstall.
  ///
  /// In en, this message translates to:
  /// **'Download and install'**
  String get downloadAndInstall;

  /// No description provided for @downloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading… %{percent}'**
  String downloading(int percent);

  /// No description provided for @downloadFailed.
  ///
  /// In en, this message translates to:
  /// **'Download failed'**
  String get downloadFailed;

  /// No description provided for @installOpened.
  ///
  /// In en, this message translates to:
  /// **'Installer opened. Tap Install / Update.'**
  String get installOpened;

  /// No description provided for @installConflictHint.
  ///
  /// In en, this message translates to:
  /// **'Package conflict means the old install was signed differently. Tap Uninstall, then Download and install.'**
  String get installConflictHint;

  /// No description provided for @packageConflictTitle.
  ///
  /// In en, this message translates to:
  /// **'Package conflict'**
  String get packageConflictTitle;

  /// No description provided for @packageConflictBody.
  ///
  /// In en, this message translates to:
  /// **'The app could not be installed because it conflicts with an existing package — the old version was signed differently. You must uninstall it first.'**
  String get packageConflictBody;

  /// No description provided for @packageConflictAfterInstall.
  ///
  /// In en, this message translates to:
  /// **'Still conflicting? You may not have uninstalled. Tap Uninstall again, confirm, then download.'**
  String get packageConflictAfterInstall;

  /// No description provided for @uninstallAppButton.
  ///
  /// In en, this message translates to:
  /// **'Uninstall app'**
  String get uninstallAppButton;

  /// No description provided for @uninstallDialogOpened.
  ///
  /// In en, this message translates to:
  /// **'Uninstall screen opened. Tap OK / Uninstall, return here, then check the box below.'**
  String get uninstallDialogOpened;

  /// No description provided for @confirmUninstalled.
  ///
  /// In en, this message translates to:
  /// **'I uninstalled — download the new version'**
  String get confirmUninstalled;

  /// No description provided for @mustConfirmUninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall the app first and check «I uninstalled».'**
  String get mustConfirmUninstall;

  /// No description provided for @uninstallSettingsOpened.
  ///
  /// In en, this message translates to:
  /// **'Settings opened. Tap Uninstall, return here, then download the update.'**
  String get uninstallSettingsOpened;

  /// No description provided for @uninstallSettingsFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open settings. Go to Settings → Apps → Vampire Village → Uninstall.'**
  String get uninstallSettingsFailed;

  /// No description provided for @forceUpdateSteps.
  ///
  /// In en, this message translates to:
  /// **'1) Uninstall  2) Download and install  3) Future updates work in-app'**
  String get forceUpdateSteps;

  /// No description provided for @installedVersion.
  ///
  /// In en, this message translates to:
  /// **'Installed version:'**
  String get installedVersion;

  /// No description provided for @updateApkTarget.
  ///
  /// In en, this message translates to:
  /// **'Download version: v{version}'**
  String updateApkTarget(String version);

  /// No description provided for @openInBrowser.
  ///
  /// In en, this message translates to:
  /// **'Open in browser (fallback)'**
  String get openInBrowser;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get loginTitle;

  /// No description provided for @guestNickHint.
  ///
  /// In en, this message translates to:
  /// **'Nickname'**
  String get guestNickHint;

  /// No description provided for @guestPlay.
  ///
  /// In en, this message translates to:
  /// **'Play as guest'**
  String get guestPlay;

  /// No description provided for @googleSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get googleSignIn;

  /// No description provided for @facebookSignIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Facebook'**
  String get facebookSignIn;

  /// No description provided for @homeWelcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome, {nick}'**
  String homeWelcome(String nick);

  /// No description provided for @homeSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a mode'**
  String get homeSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @errorNetwork.
  ///
  /// In en, this message translates to:
  /// **'Connection error. Check your network and try again.'**
  String get errorNetwork;

  /// No description provided for @errorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get errorGeneric;

  /// No description provided for @soloPlay.
  ///
  /// In en, this message translates to:
  /// **'Play solo'**
  String get soloPlay;

  /// No description provided for @soloPlayDesc.
  ///
  /// In en, this message translates to:
  /// **'6-player room (you + 5 bots) — quick match'**
  String get soloPlayDesc;

  /// No description provided for @onlinePlay.
  ///
  /// In en, this message translates to:
  /// **'Play online'**
  String get onlinePlay;

  /// No description provided for @onlinePlayDesc.
  ///
  /// In en, this message translates to:
  /// **'2–8 real players — join with room code'**
  String get onlinePlayDesc;

  /// No description provided for @onlineSoon.
  ///
  /// In en, this message translates to:
  /// **'Online mode coming soon'**
  String get onlineSoon;

  /// No description provided for @onlineLobbyTitle.
  ///
  /// In en, this message translates to:
  /// **'Online lobbies'**
  String get onlineLobbyTitle;

  /// No description provided for @onlineLobbyDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a room or join open lobbies. Game starts with at least 2 players.'**
  String get onlineLobbyDesc;

  /// No description provided for @soloRoomHint.
  ///
  /// In en, this message translates to:
  /// **'You can open a room alone; it appears in the open rooms list while you wait.'**
  String get soloRoomHint;

  /// No description provided for @roomFull.
  ///
  /// In en, this message translates to:
  /// **'Full'**
  String get roomFull;

  /// No description provided for @roomCodeHint.
  ///
  /// In en, this message translates to:
  /// **'Room code'**
  String get roomCodeHint;

  /// No description provided for @joinRoom.
  ///
  /// In en, this message translates to:
  /// **'Join'**
  String get joinRoom;

  /// No description provided for @createRoom.
  ///
  /// In en, this message translates to:
  /// **'Create room'**
  String get createRoom;

  /// No description provided for @maxPlayers.
  ///
  /// In en, this message translates to:
  /// **'Max players'**
  String get maxPlayers;

  /// No description provided for @openRooms.
  ///
  /// In en, this message translates to:
  /// **'Open rooms'**
  String get openRooms;

  /// No description provided for @noOpenRooms.
  ///
  /// In en, this message translates to:
  /// **'No open rooms — create one.'**
  String get noOpenRooms;

  /// No description provided for @hostLabel.
  ///
  /// In en, this message translates to:
  /// **'Host: {nick}'**
  String hostLabel(String nick);

  /// No description provided for @roomCode.
  ///
  /// In en, this message translates to:
  /// **'Room'**
  String get roomCode;

  /// No description provided for @roomWaiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting for players…'**
  String get roomWaiting;

  /// No description provided for @playersCount.
  ///
  /// In en, this message translates to:
  /// **'{current} / {max} players'**
  String playersCount(int current, int max);

  /// No description provided for @host.
  ///
  /// In en, this message translates to:
  /// **'Host'**
  String get host;

  /// No description provided for @needSixPlayers.
  ///
  /// In en, this message translates to:
  /// **'At least 6 players required to start.'**
  String get needSixPlayers;

  /// No description provided for @needTwoPlayers.
  ///
  /// In en, this message translates to:
  /// **'At least 2 players required to start.'**
  String get needTwoPlayers;

  /// No description provided for @startGame.
  ///
  /// In en, this message translates to:
  /// **'Start game'**
  String get startGame;

  /// No description provided for @backToLobby.
  ///
  /// In en, this message translates to:
  /// **'Back to menu'**
  String get backToLobby;

  /// No description provided for @yourRole.
  ///
  /// In en, this message translates to:
  /// **'Your role: {role}'**
  String yourRole(String role);

  /// No description provided for @lastVictim.
  ///
  /// In en, this message translates to:
  /// **'Last eliminated: {name}'**
  String lastVictim(String name);

  /// No description provided for @eliminated.
  ///
  /// In en, this message translates to:
  /// **'Eliminated'**
  String get eliminated;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get chatHint;

  /// No description provided for @chatGeneral.
  ///
  /// In en, this message translates to:
  /// **'General chat'**
  String get chatGeneral;

  /// No description provided for @chatRoom.
  ///
  /// In en, this message translates to:
  /// **'Room chat'**
  String get chatRoom;

  /// No description provided for @soloTitle.
  ///
  /// In en, this message translates to:
  /// **'Solo'**
  String get soloTitle;

  /// No description provided for @phaseNight.
  ///
  /// In en, this message translates to:
  /// **'Night phase'**
  String get phaseNight;

  /// No description provided for @phaseDay.
  ///
  /// In en, this message translates to:
  /// **'Day vote'**
  String get phaseDay;

  /// No description provided for @phaseDawn.
  ///
  /// In en, this message translates to:
  /// **'Dawn breaks'**
  String get phaseDawn;

  /// No description provided for @phaseGameOver.
  ///
  /// In en, this message translates to:
  /// **'Game over'**
  String get phaseGameOver;

  /// No description provided for @phaseHintNight.
  ///
  /// In en, this message translates to:
  /// **'The vampire is hunting…'**
  String get phaseHintNight;

  /// No description provided for @phaseHintDayVote.
  ///
  /// In en, this message translates to:
  /// **'Vote to eliminate a suspect.'**
  String get phaseHintDayVote;

  /// No description provided for @roleRevealVampire.
  ///
  /// In en, this message translates to:
  /// **'You are the Vampire'**
  String get roleRevealVampire;

  /// No description provided for @roleRevealVillager.
  ///
  /// In en, this message translates to:
  /// **'You are a Villager'**
  String get roleRevealVillager;

  /// No description provided for @roleRevealVampireHint.
  ///
  /// In en, this message translates to:
  /// **'Hunt at night. Keep your identity secret.'**
  String get roleRevealVampireHint;

  /// No description provided for @roleRevealVillagerHint.
  ///
  /// In en, this message translates to:
  /// **'Vote by day to find the vampire.'**
  String get roleRevealVillagerHint;

  /// No description provided for @dayLabel.
  ///
  /// In en, this message translates to:
  /// **'Day'**
  String get dayLabel;

  /// No description provided for @you.
  ///
  /// In en, this message translates to:
  /// **'you'**
  String get you;

  /// No description provided for @waitingVampire.
  ///
  /// In en, this message translates to:
  /// **'The vampire is choosing…'**
  String get waitingVampire;

  /// No description provided for @tapToVote.
  ///
  /// In en, this message translates to:
  /// **'Tap a player to vote them out'**
  String get tapToVote;

  /// No description provided for @villagersWin.
  ///
  /// In en, this message translates to:
  /// **'Villagers win!'**
  String get villagersWin;

  /// No description provided for @vampiresWin.
  ///
  /// In en, this message translates to:
  /// **'Vampires win!'**
  String get vampiresWin;

  /// No description provided for @playAgain.
  ///
  /// In en, this message translates to:
  /// **'Play again'**
  String get playAgain;

  /// No description provided for @matchSummaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Match summary'**
  String get matchSummaryTitle;

  /// No description provided for @summaryKills.
  ///
  /// In en, this message translates to:
  /// **'Who eliminated whom'**
  String get summaryKills;

  /// No description provided for @summaryLies.
  ///
  /// In en, this message translates to:
  /// **'Who lied'**
  String get summaryLies;

  /// No description provided for @summaryMostAccused.
  ///
  /// In en, this message translates to:
  /// **'Most accused'**
  String get summaryMostAccused;

  /// No description provided for @summaryMvp.
  ///
  /// In en, this message translates to:
  /// **'MVP'**
  String get summaryMvp;

  /// No description provided for @summaryNone.
  ///
  /// In en, this message translates to:
  /// **'No records'**
  String get summaryNone;

  String get emailLabel;
  String get loginIdentifier;
  String get passwordLabel;
  String get rememberMe;
  String get signIn;
  String get createAccount;
  String get forgotPassword;
  String get enterEmailForReset;
  String get resetLinkSent;
  String get accountTab;
  String get guestTab;
  String get registerTitle;
  String get usernameLabel;
  String get passwordMinHint;
  String get registerButton;
  String get alreadyHaveAccount;
  String get registerFailed;
  String get loginFailed;
  String get googleLoginFailed;
  String get errorNickTaken;
  String get errorNickInUse;
  String get errorInvalidNick;
  String get errorCannotDmSelf;
  String get errorDmOpenFailed;
  String get errorInvalidCredentials;
  String get errorEmailTaken;
  String get errorWeakPassword;
  String get errorGoogleNotConfigured;
  String get errorFacebookNotConfigured;
  String get errorSocialToken;
  String get errorLoginFailed;
  String get chatAndVoice;
  String get voiceChat;
  String get joinVoice;
  String get leaveVoice;
  String get chat;
  String get openChat;
  String get closeChat;
  String get ready;
  String get notReady;
  String get minimizeRoom;
  String get leaveRoom;
  String get transferHost;
  String get closeRoom;
  String get copyCode;
  String get codeCopied;
  String get youAreHost;
  String get generalVoice;
  String get generalVoiceHint;
  String get coins;
  String get dailyReward;
  String get tournamentRolePick;
  String get roleFee;
  String get joinTournament;
  String get splashConnecting;
  String get splashOffline;
  String get googleLoginCancelled;
  String get facebookLoginCancelled;
  String get googleConfiguring;
  String get leaveRoomConfirm;
  String get leaveRoomHint;
  String get hostLeaveWarning;
  String get readyCheck;
  String get generalChatTitle;
  String roomChatTitle(String code);
  String get minimize;
  String get cancel;
  String get exit;
  String get stay;
  String get quitGameConfirm;
  String get quitGamePenalty;
  String inviteToRoom(String nick, String code);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
