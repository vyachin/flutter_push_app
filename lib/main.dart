import 'package:flutter/material.dart';

void main() {
  runApp(const PushAppTest());
}

class PushAppTest extends StatelessWidget {
  static const String _title = 'Push app test';

  const PushAppTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: _title,
      home: Scaffold(
        appBar: AppBar(title: const Text(_title)),
        body: const Center(child: Text(_title)),
      ),
    );
  }
}
