import 'package:flutter/material.dart';

import '../theme.dart';

/// The Balloon Touch Exercise Run. A placeholder until the balloons arrive (#12).
class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key, required this.balloonCount});

  final int balloonCount;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Balloon Touch: $balloonCount balloons',
          style: handsText(28),
        ),
      ),
    );
  }
}
