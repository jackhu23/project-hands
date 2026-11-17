import 'package:flutter/material.dart';

import 'balloon_touch/history_screen.dart';
import 'balloon_touch/setup_screen.dart';
import 'database.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

/// A bare list of Exercises; deliberately plain until it is redesigned.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.database,
    required this.patientId,
  });

  final HandsDatabase database;
  final String patientId;

  Widget _square(BuildContext context, String label, Widget Function() page) =>
      SizedBox.square(
        dimension: 240,
        child: OutlinedButton(
          onPressed: () =>
              Navigator.of(context)
                  .push(MaterialPageRoute<void>(builder: (_) => page())),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: HandsColors.oliveGreen, width: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Text(label, textAlign: TextAlign.center, style: handsText(28)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Align(
            alignment: Alignment.topLeft,
            child: Wrap(
              spacing: 32,
              runSpacing: 32,
              children: [
                _square(
                  context,
                  'Balloon Touch',
                  () => SetupScreen(database: database, patientId: patientId),
                ),
                _square(
                  context,
                  'History',
                  () => HistoryScreen(database: database),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
