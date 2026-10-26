import 'package:expense_tracker/core/constants/digit_grouping.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/number_display_format.dart';
import 'package:expense_tracker/shared/presentation/widgets/currency_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Amount extends StatelessWidget {
  const _Amount();

  @override
  Widget build(BuildContext context) => Text(CurrencyFormatter.format(1234.5));
}

void main() {
  tearDown(
    () => CurrencyFormatter.displayFormat.value = NumberDisplayFormat.standard,
  );

  testWidgets('changing the number format rebuilds formatted amounts', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CurrencyScope(child: Scaffold(body: _Amount())),
      ),
    );
    expect(find.text('৳1,234.50'), findsOneWidget);

    CurrencyFormatter.displayFormat.value = const NumberDisplayFormat(
      decimalPlaces: 2,
      grouping: DigitGrouping.dot,
    );
    await tester.pump();

    expect(find.text('৳1.234,50'), findsOneWidget);
  });
}
