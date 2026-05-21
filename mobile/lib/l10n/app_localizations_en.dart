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
  String get forceUpdateTitle => 'Update required';

  @override
  String get forceUpdateBody =>
      'This version is no longer supported. Please install the latest release to continue.';

  @override
  String get updateButton => 'Download update';

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
  String get homeSubtitle => 'Online rooms (6–8 players) — coming soon';

  @override
  String get language => 'Language';

  @override
  String get errorNetwork =>
      'Connection error. Check your network and try again.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';
}
