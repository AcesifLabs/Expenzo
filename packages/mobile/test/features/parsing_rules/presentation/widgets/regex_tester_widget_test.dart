import 'package:expense_tracker/core/constants/digit_grouping.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/number_display_format.dart';
import 'package:expense_tracker/features/parsing_rules/presentation/widgets/regex_tester_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(
    () => CurrencyFormatter.displayFormat.value = NumberDisplayFormat.standard,
  );

  testWidgets('the extracted amount shows at full precision, whatever the '
      'number format', (tester) async {
    CurrencyFormatter.displayFormat.value = const NumberDisplayFormat(
      decimalPlaces: 0,
      grouping: DigitGrouping.dot,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: RegexTesterWidget(pattern: r'Tk ([\d,.]+)'),
          ),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'Paid Tk 1,234.5 at shop');
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.text('1234.5'), findsOneWidget);
  });
}
