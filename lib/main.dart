import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

Future<void> _messageHandler(RemoteMessage message) async {
  print('background message ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

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
            Text('message', style: Theme.of(context).textTheme.headline5),
            StreamBuilder(
              stream: FirebaseMessaging.onMessage,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
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
            Text('message opened app', style: Theme.of(context).textTheme.headline5),
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
