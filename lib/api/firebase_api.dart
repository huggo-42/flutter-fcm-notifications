import 'dart:convert';
import 'dart:math';
import 'package:flutter_fcm_notifications/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_fcm_notifications/pages/notification_screen.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('handleBackgroundMessage: $message');
  print('title: ${message.notification?.title}');
  print('body: ${message.notification?.body}');
  print('payload: ${message.data}');
}

void handleMessage(RemoteMessage? message) {
  if (message == null) return;

  navigatorKey.currentState
      ?.pushNamed(NotificationScreen.route, arguments: message);
}

Future initLocalNotifications(localNotifications, androidChannel) async {
  // const iOS = IOSInitializationSettings();

// ios InitializationSettings
  const iOS = DarwinInitializationSettings();

  const android = AndroidInitializationSettings('@drawable/ic_launcher');
  const settings = InitializationSettings(iOS: iOS, android: android);

  await localNotifications.initialize(
    settings,
    onSelectNotification: (payload) {
      final message = RemoteMessage.fromMap(jsonDecode(payload));
      handleMessage(message);
    },
  );
  final platform = localNotifications.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  await platform?.createNotificationChannel(androidChannel);
}

Future initPushNotifications(localNotifications, androidChannel) async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    final notification = message.notification;

    if (notification == null) return;

    localNotifications.show(
      notification.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          androidChannel.id,
          androidChannel.name,
          channelDescription: androidChannel.description,
          icon: '@drawable/ic_launcher',
        ),
      ),
      payload: jsonEncode(message.toMap()),
    );
  });
}

class FirebaseApi {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  final AndroidNotificationChannel androidChannel =
      const AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.defaultImportance,
  );

  final FlutterLocalNotificationsPlugin localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final String? fcmToken = await _firebaseMessaging.getToken();
    print('fcmToken: $fcmToken');

    initPushNotifications(localNotifications, androidChannel);
    initLocalNotifications(localNotifications, androidChannel);
  }
}
