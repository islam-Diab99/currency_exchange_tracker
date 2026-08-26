import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:requests_inspector/requests_inspector.dart';

import 'core/di/injector.dart';
import 'core/theme/app_theme.dart';
import 'features/rates/presentation/bloc/rates_list_bloc.dart';
import 'features/rates/presentation/pages/rates_page.dart';

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
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.system,
        home: BlocProvider(
          create: (_) => sl<RatesListBloc>()..add(const RatesListRequested()),
          child: const RatesPage(),
        ),
      ),
    );
  }
}
