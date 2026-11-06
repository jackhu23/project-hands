import 'package:flutter/material.dart';

void main() {
  runApp(const   HandsApp());
}

class HandsApp extends StatelessWidget {
  const HandsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Project HANDS',
      home: Scaffold(body: Center(child: Text('Project HANDS'))),
    );
  }
}
