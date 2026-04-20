import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings = InitializationSettings(android: androidSettings);
    await _notificationsPlugin.initialize(settings);
  }

  static Future<void> scheduleNotification(TimeOfDay time) async {
    // Hủy các thông báo cũ trước khi đặt lịch mới
    await _notificationsPlugin.cancelAll();

    final now = DateTime.now();
    var scheduledDate = DateTime(now.year, now.month, now.day, time.hour, time.minute);

    // Nếu giờ đã qua, hẹn cho ngày mai
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    await _notificationsPlugin.zonedSchedule(
      0,
      'Nhật ký hôm nay? ✍️',
      'Đừng quên ghi lại những khoảnh khắc đáng nhớ nhé!',
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'diary_channel_id', // ID kênh
          'Nhắc nhở viết nhật ký', // Tên kênh
          channelDescription: 'Thông báo nhắc nhở ghi chép hàng ngày',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // Dòng này cực kỳ quan trọng cho Android 12+
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // Lặp lại hàng ngày
    );
  }

  // THÊM HÀM NÀY ĐỂ HẾT LỖI TRONG SETTINGS_VIEW
  static Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}