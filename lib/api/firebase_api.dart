import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_fcm_notifications/main.dart';
import 'package:flutter_fcm_notifications/pages/notification_screen.dart';
// top class function -> meaning, doesn't need initialization of a class

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

Future initPushNotifications() async {
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.instance.getInitialMessage().then(handleMessage);
  FirebaseMessaging.onMessageOpenedApp.listen(handleMessage);
  FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final fcmToken = await _firebaseMessaging.getToken();
    print('fcmToken: $fcmToken');

    initPushNotifications();
  }
}
