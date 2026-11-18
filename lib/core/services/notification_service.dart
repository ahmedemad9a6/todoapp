import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  // إنشاء وتأمين النسخة الوحيدة من الكلاس
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  // المحرك الرئيسي لمكتبة الإشعارات المحلية
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // إعدادات أندرويد: نحدد أيقونة التطبيق الافتراضية
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // إعدادات iOS: طلب أذونات التنبيهات والصوت والشارات
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // إعدادات قناة الإشعار في نظام أندرويد (مطلوبة لأندرويد 8.0 فما فوق)
    const androidDetails = AndroidNotificationDetails(
      'tasks_channel', // معرف القناة الفريد
      'تنبيهات المهام', // اسم القناة الظاهر في إعدادات الهاتف
      channelDescription: 'قناة إرسال تذكيرات مهام التطبيق',
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _notificationsPlugin.show(id, title, body, details);
  }

  Future<void> requestPermissions() async {
    final androidImplementation =
        _notificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();
  }
}
