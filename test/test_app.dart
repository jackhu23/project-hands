import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hands/database.dart';
import 'package:hands/main.dart';

/// Launches the app as `main` does, on [database] or a fresh in-memory one,
/// on a landscape tablet of [size] logical pixels.
Future<HandsDatabase> pumpApp(
  WidgetTester tester, [
  HandsDatabase? database,
  Size size = const Size(1280, 800),
]) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final db = database ?? HandsDatabase(NativeDatabase.memory());
  if (database == null) addTearDown(db.close);
  final patientId = await db.launch();
  await tester.pumpWidget(HandsApp(database: db, patientId: patientId));
  return db;
}
