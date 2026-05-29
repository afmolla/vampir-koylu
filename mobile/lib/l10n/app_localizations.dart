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

  /// No description provided for @emailLabel.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get emailLabel;

  /// No description provided for @loginIdentifier.
  ///
  /// In en, this message translates to:
  /// **'Email or username'**
  String get loginIdentifier;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @rememberMe.
  ///
  /// In en, this message translates to:
  /// **'Remember me'**
  String get rememberMe;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @createAccount.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get createAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @enterEmailForReset.
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get enterEmailForReset;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'Reset link sent (check email / server log)'**
  String get resetLinkSent;

  /// No description provided for @accountTab.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTab;

  /// No description provided for @guestTab.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get guestTab;

  /// No description provided for @registerTitle.
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get registerTitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @passwordMinHint.
  ///
  /// In en, this message translates to:
  /// **'Password (min 6)'**
  String get passwordMinHint;

  /// No description provided for @registerButton.
  ///
  /// In en, this message translates to:
  /// **'Register'**
  String get registerButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In en, this message translates to:
  /// **'I already have an account'**
  String get alreadyHaveAccount;

  /// No description provided for @registerFailed.
  ///
  /// In en, this message translates to:
  /// **'Registration failed. Check your connection.'**
  String get registerFailed;

  /// No description provided for @loginFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed'**
  String get loginFailed;

  /// No description provided for @googleLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in failed'**
  String get googleLoginFailed;

  /// No description provided for @errorNickTaken.
  ///
  /// In en, this message translates to:
  /// **'This username is already taken.'**
  String get errorNickTaken;

  /// No description provided for @errorNickInUse.
  ///
  /// In en, this message translates to:
  /// **'This nickname is used by an online player. Try another.'**
  String get errorNickInUse;

  /// No description provided for @errorInvalidNick.
  ///
  /// In en, this message translates to:
  /// **'Nickname must be 2–24 characters.'**
  String get errorInvalidNick;

  /// No description provided for @errorCannotDmSelf.
  ///
  /// In en, this message translates to:
  /// **'You cannot open a private chat with yourself.'**
  String get errorCannotDmSelf;

  /// No description provided for @errorDmOpenFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not open private chat.'**
  String get errorDmOpenFailed;

  /// No description provided for @errorInvalidCredentials.
  ///
  /// In en, this message translates to:
  /// **'Email, username or password is incorrect.'**
  String get errorInvalidCredentials;

  /// No description provided for @errorEmailTaken.
  ///
  /// In en, this message translates to:
  /// **'This email is already registered.'**
  String get errorEmailTaken;

  /// No description provided for @errorWeakPassword.
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters.'**
  String get errorWeakPassword;

  /// No description provided for @errorGoogleNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in is not configured on the server.'**
  String get errorGoogleNotConfigured;

  /// No description provided for @errorGoogleNoIdToken.
  ///
  /// In en, this message translates to:
  /// **'Google did not return a sign-in token. Check OAuth client ID and app SHA-1 in Google Cloud.'**
  String get errorGoogleNoIdToken;

  /// No description provided for @errorFacebookNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'Facebook sign-in is not configured on the server.'**
  String get errorFacebookNotConfigured;

  /// No description provided for @errorSocialToken.
  ///
  /// In en, this message translates to:
  /// **'Social sign-in could not be verified.'**
  String get errorSocialToken;

  /// No description provided for @errorLoginFailed.
  ///
  /// In en, this message translates to:
  /// **'Sign in failed.'**
  String get errorLoginFailed;

  /// No description provided for @chatAndVoice.
  ///
  /// In en, this message translates to:
  /// **'Chat & voice'**
  String get chatAndVoice;

  /// No description provided for @voiceChat.
  ///
  /// In en, this message translates to:
  /// **'Voice chat'**
  String get voiceChat;

  /// No description provided for @joinVoice.
  ///
  /// In en, this message translates to:
  /// **'Join voice'**
  String get joinVoice;

  /// No description provided for @leaveVoice.
  ///
  /// In en, this message translates to:
  /// **'Leave voice'**
  String get leaveVoice;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @openChat.
  ///
  /// In en, this message translates to:
  /// **'Open chat'**
  String get openChat;

  /// No description provided for @closeChat.
  ///
  /// In en, this message translates to:
  /// **'Close chat'**
  String get closeChat;

  /// No description provided for @ready.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get ready;

  /// No description provided for @notReady.
  ///
  /// In en, this message translates to:
  /// **'Not ready'**
  String get notReady;

  /// No description provided for @minimizeRoom.
  ///
  /// In en, this message translates to:
  /// **'Minimize room'**
  String get minimizeRoom;

  /// No description provided for @leaveRoom.
  ///
  /// In en, this message translates to:
  /// **'Leave room'**
  String get leaveRoom;

  /// No description provided for @transferHost.
  ///
  /// In en, this message translates to:
  /// **'Transfer host'**
  String get transferHost;

  /// No description provided for @closeRoom.
  ///
  /// In en, this message translates to:
  /// **'Close room'**
  String get closeRoom;

  /// No description provided for @copyCode.
  ///
  /// In en, this message translates to:
  /// **'Copy code'**
  String get copyCode;

  /// No description provided for @codeCopied.
  ///
  /// In en, this message translates to:
  /// **'Code copied'**
  String get codeCopied;

  /// No description provided for @youAreHost.
  ///
  /// In en, this message translates to:
  /// **'You are the host'**
  String get youAreHost;

  /// No description provided for @generalVoice.
  ///
  /// In en, this message translates to:
  /// **'General voice'**
  String get generalVoice;

  /// No description provided for @generalVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Talk with everyone in the lobby'**
  String get generalVoiceHint;

  /// No description provided for @coins.
  ///
  /// In en, this message translates to:
  /// **'Coins'**
  String get coins;

  /// No description provided for @dailyReward.
  ///
  /// In en, this message translates to:
  /// **'Daily reward'**
  String get dailyReward;

  /// No description provided for @tournamentRolePick.
  ///
  /// In en, this message translates to:
  /// **'Preferred role'**
  String get tournamentRolePick;

  /// No description provided for @roleFee.
  ///
  /// In en, this message translates to:
  /// **'Role fee'**
  String get roleFee;

  /// No description provided for @joinTournament.
  ///
  /// In en, this message translates to:
  /// **'Join tournament'**
  String get joinTournament;

  /// No description provided for @splashConnecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting to server…'**
  String get splashConnecting;

  /// No description provided for @splashOffline.
  ///
  /// In en, this message translates to:
  /// **'Server unreachable — offline mode available'**
  String get splashOffline;

  /// No description provided for @googleLoginCancelled.
  ///
  /// In en, this message translates to:
  /// **'Google sign-in cancelled or failed'**
  String get googleLoginCancelled;

  /// No description provided for @facebookLoginCancelled.
  ///
  /// In en, this message translates to:
  /// **'Facebook sign-in cancelled or failed'**
  String get facebookLoginCancelled;

  /// No description provided for @googleConfiguring.
  ///
  /// In en, this message translates to:
  /// **'Google (configuring…)'**
  String get googleConfiguring;

  /// No description provided for @leaveRoomConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave room?'**
  String get leaveRoomConfirm;

  /// No description provided for @leaveRoomHint.
  ///
  /// In en, this message translates to:
  /// **'Minimize: room stays open, return to main menu.\nLeave: you exit the room completely.'**
  String get leaveRoomHint;

  /// No description provided for @hostLeaveWarning.
  ///
  /// In en, this message translates to:
  /// **'As host, leaving cancels the game and costs 25 coins.'**
  String get hostLeaveWarning;

  /// No description provided for @readyCheck.
  ///
  /// In en, this message translates to:
  /// **'Ready ✓'**
  String get readyCheck;

  /// No description provided for @generalChatTitle.
  ///
  /// In en, this message translates to:
  /// **'General chat & voice'**
  String get generalChatTitle;

  /// No description provided for @roomChatTitle.
  ///
  /// In en, this message translates to:
  /// **'Room: {code}'**
  String roomChatTitle(String code);

  /// No description provided for @minimize.
  ///
  /// In en, this message translates to:
  /// **'Minimize'**
  String get minimize;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In en, this message translates to:
  /// **'Leave'**
  String get exit;

  /// No description provided for @stay.
  ///
  /// In en, this message translates to:
  /// **'Stay'**
  String get stay;

  /// No description provided for @quitGameConfirm.
  ///
  /// In en, this message translates to:
  /// **'Leave game?'**
  String get quitGameConfirm;

  /// No description provided for @quitGamePenalty.
  ///
  /// In en, this message translates to:
  /// **'Leave (-25 coins)'**
  String get quitGamePenalty;

  /// No description provided for @adminTabProfile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get adminTabProfile;

  /// No description provided for @adminTabMembers.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get adminTabMembers;

  /// No description provided for @adminSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search nick or email'**
  String get adminSearchHint;

  /// No description provided for @adminFilterRegistered.
  ///
  /// In en, this message translates to:
  /// **'Members'**
  String get adminFilterRegistered;

  /// No description provided for @adminFilterGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get adminFilterGuest;

  /// No description provided for @adminFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get adminFilterAll;

  /// No description provided for @adminTotalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total: {count} users'**
  String adminTotalUsers(int count);

  /// No description provided for @adminNoUsers.
  ///
  /// In en, this message translates to:
  /// **'No users found'**
  String get adminNoUsers;

  /// No description provided for @adminBadgeGuest.
  ///
  /// In en, this message translates to:
  /// **'Guest'**
  String get adminBadgeGuest;

  /// No description provided for @adminBadgeMember.
  ///
  /// In en, this message translates to:
  /// **'Member'**
  String get adminBadgeMember;

  /// No description provided for @inviteToRoom.
  ///
  /// In en, this message translates to:
  /// **'{nick} invites you to room {code}'**
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
