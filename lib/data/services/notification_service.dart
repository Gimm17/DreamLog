import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _reminderId = 1;
  static const _previewId = 2;
  static const _title = 'Record last night dream';
  static const _body = 'Capture it before it fades.';

  static const _androidDetails = AndroidNotificationDetails(
    'dreamlog_morning',
    'DreamLog Morning Reminder',
    channelDescription: 'Daily reminder to record last night dream.',
    importance: Importance.defaultImportance,
    priority: Priority.defaultPriority,
  );

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    await _plugin.initialize(settings);
  }

  /// Repeats daily at [time] in the device's own zone.
  Future<void> scheduleMorning(TimeOfDay time) async {
    await _plugin.zonedSchedule(
      _reminderId,
      _title,
      _body,
      _nextInstanceOf(time),
      const NotificationDetails(
        android: _androidDetails,
        iOS: DarwinNotificationDetails(),
      ),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelMorning() => _plugin.cancel(_reminderId);

  /// Fires immediately, so the user sees what they just switched on.
  /// Uses its own id so dismissing it cannot disturb the pending daily alarm.
  Future<void> showMorningReminderPreview() async {
    await _plugin.show(
      _previewId,
      _title,
      _body,
      const NotificationDetails(
        android: _androidDetails,
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
