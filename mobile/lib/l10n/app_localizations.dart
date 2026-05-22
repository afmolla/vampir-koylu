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
  /// **'If you see package conflict or parse error: uninstall the app first, then download again from this screen.'**
  String get installConflictHint;

  /// No description provided for @installedVersion.
  ///
  /// In en, this message translates to:
  /// **'Installed version:'**
  String get installedVersion;

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
  /// **'6–8 real players — join with room code'**
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
  /// **'Create a room or join with a code. Game starts with 6+ players.'**
  String get onlineLobbyDesc;

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

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @generalChat.
  ///
  /// In en, this message translates to:
  /// **'General chat'**
  String get generalChat;

  /// No description provided for @roomChat.
  ///
  /// In en, this message translates to:
  /// **'Room chat'**
  String get roomChat;

  /// No description provided for @chatHint.
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get chatHint;

  /// No description provided for @send.
  ///
  /// In en, this message translates to:
  /// **'Send'**
  String get send;
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
