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
  String get splashConnectingServer => 'Sunucu bağlantısı kontrol ediliyor…';

  @override
  String get splashCheckingVersion => 'Sürüm kontrol ediliyor…';

  @override
  String splashServerHost(String host) => 'Sunucu: $host';

  @override
  String splashYourVersion(String version) => 'Yüklü sürüm: $version';

  @override
  String splashServerVersion(String version) => 'Sunucu sürümü: $version';

  @override
  String get splashRetry => 'Tekrar dene';

  @override
  String get splashServerUnreachable =>
      'Sunucuya bağlanılamadı. İnternet veya sunucu kapalı olabilir.';

  @override
  String get continueOffline => 'Internetsiz devam et';

  @override
  String get continueOfflineHint =>
      '6 kişilik oda: sen + 5 bot. Sunucu gerekmez.';

  @override
  String get offlineModeTitle => 'Çevrimdışı oyun';

  @override
  String get offlineModeBody =>
      'Sunucu olmadan botlarla vampir–köylü oynayabilirsin. İnternet gelince ana ekrandan tekrar bağlan.';

  @override
  String get offlinePlayWithBots => 'Botlarla oyna';

  @override
  String get offlineBackToSplash => 'Geri — tekrar dene';

  @override
  String get offlineModeBanner => 'Çevrimdışı mod — sadece botlu oyun';

  @override
  String get offlineTryOnline => 'Sunucuya bağlan';

  @override
  String get offlineSoloDesc => 'Sen + 5 bot — internetsiz tam oyun';

  @override
  String get offlineOnlineDisabled =>
      'Çevrimdışı modda kapalı. Sunucuya bağlanınca açılır.';

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
      '«Paket çakışması» = eski kurulum farklı imzalı. Önce «Uygulamayı kaldır» ile sil, sonra «İndir ve yükle».';

  @override
  String get packageConflictTitle => 'Paket çakışması';

  @override
  String get packageConflictBody =>
      'Mevcut bir paketle çakıştığından uygulama yüklenemedi — eski sürüm farklı imzayla kurulu. Önce uygulamayı tamamen kaldırman gerekir.';

  @override
  String get packageConflictAfterInstall =>
      'Kurulum yine çakıştıysa: uygulamayı kaldırmayı unutmuş olabilirsin. Tekrar «Uygulamayı kaldır» → onayla → indir.';

  @override
  String get uninstallAppButton => 'Uygulamayı kaldır';

  @override
  String get uninstallDialogOpened =>
      'Kaldır ekranı açıldı. «Tamam» / «Kaldır» de, sonra bu ekrana dön ve kutuyu işaretle.';

  @override
  String get confirmUninstalled =>
      'Uygulamayı kaldırdım — şimdi yeni sürümü indir';

  @override
  String get mustConfirmUninstall =>
      'Önce uygulamayı kaldır ve «Uygulamayı kaldırdım» kutusunu işaretle.';

  @override
  String get uninstallSettingsOpened =>
      'Ayarlar açıldı. «Kaldır»a dokun, sonra bu ekrana dönüp güncellemeyi indir.';

  @override
  String get uninstallSettingsFailed =>
      'Ayarlar açılamadı. Telefonda Ayarlar → Uygulamalar → Vampir Köylü → Kaldır.';

  @override
  String get forceUpdateSteps =>
      '1) Kaldır  2) İndir ve yükle  3) Sonraki güncellemeler otomatik olur';

  @override
  String get installedVersion => 'Yüklü sürüm:';

  @override
  String updateApkTarget(String version) => 'İndirilecek sürüm: v$version';

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
  String get onlinePlayDesc => '2–8 kişi, gerçek oyuncular — oda kodu ile';

  @override
  String get onlineSoon => 'Online mod yakında';

  @override
  String get onlineLobbyTitle => 'Online lobiler';

  @override
  String get onlineLobbyDesc =>
      'Oda oluştur veya açık odalara katıl. Oyun en az 2 oyuncu ile başlar.';

  @override
  String get soloRoomHint =>
      'Tek başına oda açabilirsin; odan açık odalar listesinde görünür, oyuncu bekleyebilirsin.';

  @override
  String get roomFull => 'Dolu';

  @override
  String get roomCodeHint => 'Oda kodu';

  @override
  String get joinRoom => 'Katıl';

  @override
  String get createRoom => 'Oda oluştur';

  @override
  String get maxPlayers => 'Maks. oyuncu';

  @override
  String get openRooms => 'Açık odalar';

  @override
  String get noOpenRooms => 'Açık oda yok — yeni oda oluştur.';

  @override
  String hostLabel(String nick) {
    return 'Kurucu: $nick';
  }

  @override
  String get roomCode => 'Oda';

  @override
  String get roomWaiting => 'Oyuncular bekleniyor…';

  @override
  String playersCount(int current, int max) {
    return '$current / $max oyuncu';
  }

  @override
  String get host => 'Kurucu';

  @override
  String get needSixPlayers => 'Başlatmak için en az 6 oyuncu gerekli.';

  @override
  String get needTwoPlayers => 'Başlatmak için en az 2 oyuncu gerekli.';

  @override
  String get startGame => 'Oyunu başlat';

  @override
  String get backToLobby => 'Ana menüye dön';

  @override
  String yourRole(String role) {
    return 'Rolün: $role';
  }

  @override
  String lastVictim(String name) {
    return 'Son elenen: $name';
  }

  @override
  String get eliminated => 'Elenmiş';

  @override
  String get chatHint => 'Mesaj yaz…';

  @override
  String get chatGeneral => 'Genel sohbet';

  @override
  String get chatRoom => 'Oda sohbeti';

  @override
  String get soloTitle => 'Tek oyuncu';

  @override
  String get phaseNight => 'Gece fazı';

  @override
  String get phaseDay => 'Gündüz oylaması';

  @override
  String get phaseDawn => 'Şafak vakti';

  @override
  String get phaseGameOver => 'Oyun bitti';

  @override
  String get phaseHintNight => 'Vampir avını seçiyor…';

  @override
  String get phaseHintDayVote => 'Şüpheliyi oylayarak elenebilir.';

  @override
  String get roleRevealVampire => 'Sen Vampirsin';

  @override
  String get roleRevealVillager => 'Sen Köylüsün';

  @override
  String get roleRevealVampireHint => 'Geceleri avlan. Kimliğini gizle.';

  @override
  String get roleRevealVillagerHint => 'Gündüz oylama ile vampiri bul.';

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

  @override
  String get matchSummaryTitle => 'Maç özeti';

  @override
  String get summaryKills => 'Kim kimi öldürdü';

  @override
  String get summaryLies => 'Kim yalan söyledi';

  @override
  String get summaryMostAccused => 'En çok suçlanan';

  @override
  String get summaryMvp => 'MVP';

  @override
  String get summaryNone => 'Kayıt yok';
}
