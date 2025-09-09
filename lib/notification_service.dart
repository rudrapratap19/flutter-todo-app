import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'todo_model.dart';

class NotificationService {
  static final NotificationService _singleton = NotificationService._internal();
  factory NotificationService() => _singleton;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocal =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await flutterLocal.initialize(settings);
  }

  Future<void> scheduleNotificationForTodo(TodoModel todo) async {
    final scheduledTime = todo.deadline.subtract(const Duration(hours: 1));
    if (scheduledTime.isBefore(DateTime.now())) return;

    final androidDetails = AndroidNotificationDetails(
      'todo-channel',
      'Todo Reminders',
      channelDescription: 'Reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);
    
    // Convert DateTime to TZDateTime
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await flutterLocal.zonedSchedule(
      todo.id.hashCode,
      'Reminder: ${todo.title}',
      'Due at ${todo.deadline}',
      tzScheduledTime,
      details,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      androidAllowWhileIdle: true,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelNotification(String id) async {
    await flutterLocal.cancel(id.hashCode);
  }
}
