import 'package:firebase_messaging/firebase_messaging.dart';
// top class function -> meaning, doesn't need initialization of a class

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print('handleBackgroundMessage: $message');
  print('title: ${message.notification?.title}');
  print('body: ${message.notification?.body}');
  print('payload: ${message.data}');
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final fcmToken = await _firebaseMessaging.getToken();
    print('fcmToken: $fcmToken');
    // can not use a anonymous function for onBackgroundMessage
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}
