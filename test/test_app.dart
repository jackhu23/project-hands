import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hands/database.dart';
import 'package:hands/main.dart';

/// Launches the app as `main` does, on [database] or a fresh in-memory one.
Future<HandsDatabase> pumpApp(
  WidgetTester tester, [
  HandsDatabase? database,
]) async {
  final db = database ?? HandsDatabase(NativeDatabase.memory());
  if (database == null) addTearDown(db.close);
  final patientId = await db.launch();
  await tester.pumpWidget(HandsApp(database: db, patientId: patientId));
  return db;
}
