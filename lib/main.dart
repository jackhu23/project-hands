import 'package:flutter/material.dart';

import 'balloon_touch/setup_screen.dart';
import 'theme.dart';

void main() {
  runApp(const HandsApp());
}

class HandsApp extends StatelessWidget {
  const HandsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Project HANDS',
      theme: handsTheme,
      home: const HomeScreen(),
    );
  }
}

/// A bare list of Exercises; deliberately plain until it is redesigned.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox.square(
              dimension: 240,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const SetupScreen()),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: HandsColors.oliveGreen,
                    width: 3,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'Balloon Touch',
                  textAlign: TextAlign.center,
                  style: handsText(28),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
