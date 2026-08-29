import 'package:axis_assessment/features/rates/presentation/widgets/rates_message_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> pump(WidgetTester tester, Widget child) =>
      tester.pumpWidget(MaterialApp(home: Scaffold(body: child)));

  testWidgets('renders the title and message', (tester) async {
    await pump(
      tester,
      const RatesMessageView(
        icon: Icons.cloud_off_rounded,
        title: 'Couldn’t load rates',
        message: 'Check your connection.',
      ),
    );

    expect(find.text('Couldn’t load rates'), findsOneWidget);
    expect(find.text('Check your connection.'), findsOneWidget);
  });

  testWidgets('shows the retry action only when a callback is given and '
      'invokes it on tap', (tester) async {
    var retried = false;

    await pump(
      tester,
      RatesMessageView(
        icon: Icons.cloud_off_rounded,
        title: 'Couldn’t load rates',
        actionLabel: 'Try again',
        onAction: () => retried = true,
      ),
    );

    expect(find.text('Try again'), findsOneWidget);
    await tester.tap(find.text('Try again'));
    expect(retried, isTrue);
  });

  testWidgets('omits the action button when no callback is provided', (
    tester,
  ) async {
    await pump(
      tester,
      const RatesMessageView(
        icon: Icons.currency_exchange_rounded,
        title: 'No rates to show',
      ),
    );

    expect(find.byType(FilledButton), findsNothing);
  });
}
