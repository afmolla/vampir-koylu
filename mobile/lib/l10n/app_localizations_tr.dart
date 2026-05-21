// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appTitle => 'Vampir Köylü';

  @override
  String get splashLoading => 'Güncelleme kontrol ediliyor…';

  @override
  String get forceUpdateTitle => 'Güncelleme gerekli';

  @override
  String get forceUpdateBody =>
      'Bu sürüm artık desteklenmiyor. Oyuna devam etmek için lütfen en güncel sürümü yükleyin.';

  @override
  String get updateButton => 'Güncellemeyi indir';

  @override
  String get loginTitle => 'Giriş yap';

  @override
  String get guestNickHint => 'Takma ad';

  @override
  String get guestPlay => 'Misafir olarak oyna';

  @override
  String get googleSignIn => 'Google ile giriş';

  @override
  String get facebookSignIn => 'Facebook ile giriş';

  @override
  String homeWelcome(String nick) {
    return 'Hoş geldin, $nick';
  }

  @override
  String get homeSubtitle => 'Online odalar (6–8 kişi) — yakında';

  @override
  String get language => 'Dil';

  @override
  String get errorNetwork =>
      'Bağlantı hatası. İnterneti kontrol edip tekrar dene.';

  @override
  String get errorGeneric => 'Bir şeyler ters gitti. Lütfen tekrar dene.';
}
