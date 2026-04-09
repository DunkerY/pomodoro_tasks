import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const settings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings);
  }

  static Future<void> showPomodoroFinished({
    required String title,
    required String body,
  }) async {
    // Notificação local só funciona em Android/iOS
    // No Windows exibe um print no console durante desenvolvimento
    if (!Platform.isAndroid && !Platform.isIOS) {
      print('[Notificação] $title — $body');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'pomodoro_channel',
      'Pomodoro',
      channelDescription: 'Notificações do timer Pomodoro',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(0, title, body, details);
  }
}
