import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'database.dart';
import 'home_screen.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // The run hides the system bars and restores this mode when it ends.
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  final database = HandsDatabase.onDevice();
  final patientId = await database.launch();
  runApp(HandsApp(database: database, patientId: patientId));
}

class HandsApp extends StatelessWidget {
  const HandsApp({super.key, required this.database, required this.patientId});

  final HandsDatabase database;

  /// The temporary Patient's pseudonymous ID.
  final String patientId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project HANDS',
      theme: handsTheme,
      home: HomeScreen(database: database, patientId: patientId),
    );
  }
}
