import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Firebase olmadan günlük bonus hatırlatması (yerel bildirim).
class LocalNotificationsService {
  LocalNotificationsService._();
  static final instance = LocalNotificationsService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;
  static const _lastUpdateNotifiedKey = 'last_update_notified_version';

  Future<void> init() async {
    if (_ready) return;
    tz_data.initializeTimeZones();

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const init = InitializationSettings(android: android);
    await _plugin.initialize(init);

    const androidChannel = AndroidNotificationChannel(
      'daily_bonus',
      'Günlük bonus',
      description: 'Günlük giriş ödülü hatırlatması',
      importance: Importance.defaultImportance,
    );
    const updateChannel = AndroidNotificationChannel(
      'update_available',
      'Güncelleme',
      description: 'Yeni sürüm bildirimi',
      importance: Importance.high,
    );
    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.createNotificationChannel(androidChannel);
    await androidImpl?.createNotificationChannel(updateChannel);

    _ready = true;
    await scheduleDailyBonusReminder();
  }

  Future<void> scheduleDailyBonusReminder() async {
    if (!_ready) return;
    await _plugin.cancel(1);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      19,
      0,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_bonus',
        'Günlük bonus',
        channelDescription: 'Her gün 19:00 hatırlatma',
        icon: '@mipmap/ic_launcher',
      ),
    );

    await _plugin.zonedSchedule(
      1,
      'Vampir Köylü',
      'Günlük bonusunu almayı unutma!',
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Yeni sürüm bulunduğunda tek seferlik bip’li bildirim.
  Future<void> notifyUpdateAvailable({
    required String latestVersion,
  }) async {
    if (!_ready) return;
    final v = latestVersion.trim();
    if (v.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final last = prefs.getString(_lastUpdateNotifiedKey);
    if (last == v) return;
    await prefs.setString(_lastUpdateNotifiedKey, v);

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'update_available',
        'Güncelleme',
        channelDescription: 'Yeni sürüm bildirimi',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      ),
    );

    await _plugin.show(
      2,
      'Vampir Köylü',
      'Yeni güncelleme var: v$v',
      details,
    );
  }
}
