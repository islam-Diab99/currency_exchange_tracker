import 'package:axis_assessment/core/theme/app_colors.dart';
import 'package:axis_assessment/core/utils/rate_formatter.dart';
import 'package:axis_assessment/features/rates/domain/entities/exchange_rate.dart';
import 'package:axis_assessment/features/rates/presentation/widgets/rate_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/fixtures.dart';

void main() {
  // Pumps the card in a minimal light-themed app so trend colors resolve.
  Future<void> pumpCard(
    WidgetTester tester,
    ExchangeRate rate, {
    VoidCallback? onTap,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(brightness: Brightness.light),
        home: Scaffold(
          body: RateCard(rate: rate, onTap: onTap),
        ),
      ),
    );
  }

  String changeText(ExchangeRate rate) =>
      '${RateFormatter.signedChange(rate.changeAbsolute)} · '
      '${RateFormatter.signedPercent(rate.changePercent)}';

  testWidgets('shows the currency identity and the daily change '
      '(absolute + percent)', (tester) async {
    final rate = ExchangeRate(currency: usd, rate: 52.01, previousRate: 52.50);

    await pumpCard(tester, rate);

    expect(find.text('US Dollar'), findsOneWidget);
    expect(find.text('1 USD = '), findsOneWidget);
    // The spec requires BOTH the absolute and the percentage change.
    expect(find.text(changeText(rate)), findsOneWidget);
  });

  testWidgets('paints the change green when EGP strengthens (rate falls)', (
    tester,
  ) async {
    // rate below previous → one USD costs fewer EGP → EGP stronger → green.
    final rate = ExchangeRate(currency: usd, rate: 52.01, previousRate: 52.50);

    await pumpCard(tester, rate);

    final text = tester.widget<Text>(find.text(changeText(rate)));
    expect(text.style?.color, AppColors.up(Brightness.light));
  });

  testWidgets('paints the change red when EGP weakens (rate rises)', (
    tester,
  ) async {
    final rate = ExchangeRate(currency: usd, rate: 52.90, previousRate: 52.50);

    await pumpCard(tester, rate);

    final text = tester.widget<Text>(find.text(changeText(rate)));
    expect(text.style?.color, AppColors.down(Brightness.light));
  });

  testWidgets('shows a dash instead of a change when there is no history', (
    tester,
  ) async {
    final rate = ExchangeRate(currency: usd, rate: 52.01);

    await pumpCard(tester, rate);

    expect(find.text('—'), findsOneWidget);
  });

  testWidgets('invokes onTap when the row is tapped', (tester) async {
    var tapped = false;
    final rate = ExchangeRate(currency: usd, rate: 52.01, previousRate: 52.50);

    await pumpCard(tester, rate, onTap: () => tapped = true);
    await tester.tap(find.byType(InkWell));

    expect(tapped, isTrue);
  });
}
