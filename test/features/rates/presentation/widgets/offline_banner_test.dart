import 'package:axis_assessment/features/rates/presentation/widgets/offline_banner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  testWidgets('tells the user the data is cached and when it is from', (
    tester,
  ) async {
    final lastUpdated = DateTime(2026, 6, 1);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: OfflineBanner(lastUpdated: lastUpdated)),
      ),
    );

    final date = DateFormat('MMM d, y').format(lastUpdated);
    expect(
      find.text('Offline — showing saved rates from $date'),
      findsOneWidget,
    );
    expect(find.byIcon(Icons.wifi_off_rounded), findsOneWidget);
  });
}
