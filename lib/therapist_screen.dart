import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'database.dart';
import 'theme.dart';

/// The OT's settings. A stub until Therapist mode lands.
class TherapistScreen extends StatelessWidget {
  const TherapistScreen({super.key, required this.database});

  final HandsDatabase database;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Therapist', style: HandsText.sectionTitle)),
      body: Padding(
        padding: const EdgeInsets.all(HandsSizes.pagePadH),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: HandsSizes.gap,
          children: [
            Text('Therapist settings are coming soon.', style: HandsText.body),
            // Compiled out of release builds, so a Patient can't wipe history.
            if (kDebugMode)
              OutlinedButton(
                onPressed: () async {
                  await database.clearAll();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data cleared')),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, HandsSizes.minTouch),
                ),
                child: Text('Clear all data', style: HandsText.link),
              ),
          ],
        ),
      ),
    );
  }
}
