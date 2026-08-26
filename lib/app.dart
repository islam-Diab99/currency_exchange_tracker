import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:requests_inspector/requests_inspector.dart';

class CurrencyTrackerApp extends StatelessWidget {
  const CurrencyTrackerApp({super.key});
  @override
  Widget build(BuildContext context) {
    // Wraps the app so requests can be inspected in-app (shake to open).
    // Enabled outside release builds only.
    return RequestsInspector(
      enabled: !kReleaseMode,
      child: MaterialApp(
        title: 'Currency Exchange Tracker',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
      ),
    );
  }
}
