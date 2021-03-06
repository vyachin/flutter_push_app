import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  final initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');

  final initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

  FirebaseMessaging.onBackgroundMessage(_messageHandler);
  runApp(const PushAppTest());
}

class PushAppTest extends StatelessWidget {
  static const String _title = 'Push app test';

  const PushAppTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: HomeScreen(title: _title),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String title;

  const HomeScreen({Key? key, required this.title}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late FirebaseMessaging messaging;

  @override
  void initState() {
    super.initState();
    messaging = FirebaseMessaging.instance;
  }

  Future<void> showNotification(
      int id, String title, String body, String? payload) async {
    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      'your channel description',
      importance: Importance.max,
      priority: Priority.high,
    );
    final iOSPlatformChannelSpecifics = IOSNotificationDetails();
    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );
    await _flutterLocalNotificationsPlugin
        .show(id, title, body, platformChannelSpecifics, payload: payload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text('token', style: Theme.of(context).textTheme.headline5),
            FutureBuilder(
              future: messaging.getToken(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final token = (snapshot.data as String?) ?? '';
                  print("Token: $token");
                  return Text(token);
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 20),
            Text('refresh token', style: Theme.of(context).textTheme.headline5),
            StreamBuilder(
              stream: messaging.onTokenRefresh,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final token = snapshot.data as String;
                  print("Refresh token: $token");
                  return Text(token);
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 20),
            Text('message', style: Theme.of(context).textTheme.headline5),
            StreamBuilder(
              stream: FirebaseMessaging.onMessage,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final remoteMessage = snapshot.data as RemoteMessage;
                  showNotification(
                    (remoteMessage.messageId ?? '').hashCode,
                    remoteMessage.notification!.title ?? '',
                    remoteMessage.notification!.body ?? '',
                    remoteMessage.data.toString(),
                  );

                  return Column(
                    children: [
                      Text(remoteMessage.data.toString()),
                      Text('from ${remoteMessage.from}'),
                      Text('messageId ${remoteMessage.messageId}'),
                      Text('title ${remoteMessage.notification!.title}'),
                      Text('body ${remoteMessage.notification!.body}'),
                    ],
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
            const SizedBox(height: 20),
            Text('message opened app',
                style: Theme.of(context).textTheme.headline5),
            StreamBuilder(
              stream: FirebaseMessaging.onMessageOpenedApp,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print('Message clicked!');
                  final remoteMessage = snapshot.data as RemoteMessage;
                  return Column(
                    children: [
                      Text(remoteMessage.data.toString()),
                      Text('category ${remoteMessage.category}'),
                      Text('from ${remoteMessage.from}'),
                      Text('messageId ${remoteMessage.messageId}'),
                      Text('messageType ${remoteMessage.messageType}'),
                      Text('senderId ${remoteMessage.senderId}'),
                      Text('threadId ${remoteMessage.threadId}'),
                      Text('title ${remoteMessage.notification!.title}'),
                      Text('body ${remoteMessage.notification!.body}'),
                    ],
                  );
                }
                return const CircularProgressIndicator();
              },
            ),
          ],
        ),
      ),
    );
  }
}
