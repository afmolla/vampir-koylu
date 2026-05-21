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
  String get downloadAndInstall => 'İndir ve yükle';

  @override
  String downloading(int percent) {
    return 'İndiriliyor… %$percent';
  }

  @override
  String get downloadFailed => 'İndirme başarısız';

  @override
  String get installOpened =>
      'Kurulum ekranı açıldı. «Yükle» / «Güncelle» ye dokun.';

  @override
  String get installConflictHint =>
      '«Paket çakışması» veya «ayrıştırma hatası» görürsen: önce uygulamayı kaldır, sonra bu ekrandan tekrar indir.';

  @override
  String get installedVersion => 'Yüklü sürüm:';

  @override
  String get openInBrowser => 'Tarayıcıda aç (yedek)';

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
  String get homeSubtitle => 'Bir mod seç';

  @override
  String get language => 'Dil';

  @override
  String get errorNetwork =>
      'Bağlantı hatası. İnterneti kontrol edip tekrar dene.';

  @override
  String get errorGeneric => 'Bir şeyler ters gitti. Lütfen tekrar dene.';

  @override
  String get soloPlay => 'Tek başına oyna';

  @override
  String get soloPlayDesc => '6 kişilik oda (sen + 5 bot) — hızlı maç';

  @override
  String get onlinePlay => 'Online oyna';

  @override
  String get onlinePlayDesc => '6–8 kişi, gerçek oyuncular';

  @override
  String get onlineSoon => 'Online mod yakında';

  @override
  String get soloTitle => 'Tek oyuncu';

  @override
  String get phaseNight => 'Gece fazı';

  @override
  String get phaseDay => 'Gündüz oylaması';

  @override
  String get dayLabel => 'Gün';

  @override
  String get you => 'sen';

  @override
  String get waitingVampire => 'Vampir avını seçiyor…';

  @override
  String get tapToVote => 'Elenmesini istediğin oyuncuya dokun';

  @override
  String get villagersWin => 'Köylüler kazandı!';

  @override
  String get vampiresWin => 'Vampirler kazandı!';

  @override
  String get playAgain => 'Tekrar oyna';
}
