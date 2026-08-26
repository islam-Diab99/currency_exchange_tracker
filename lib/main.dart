import 'package:axis_assessment/app.dart';
import 'package:axis_assessment/core/di/injector.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await configureDependencies();
  runApp(const CurrencyTrackerApp());
}
