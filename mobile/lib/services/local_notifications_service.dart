import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Firebase olmadan günlük bonus hatırlatması (yerel bildirim).
class LocalNotificationsService {
  LocalNotificationsService._();
  static final instance = LocalNotificationsService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

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
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);

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
}
