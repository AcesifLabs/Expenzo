import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/app_colors.dart';
import 'package:expense_tracker/features/message_templates/presentation/widgets/template_editor_components.dart';

Widget _wrapInApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

/// Finds the row-level AnimatedContainer inside AmountRow (the one with
/// borderRadius, not the radio button's circle container).
AnimatedContainer _findAmountRowContainer(WidgetTester tester) {
  final containers = tester.widgetList<AnimatedContainer>(
    find.descendant(
      of: find.byType(AmountRow),
      matching: find.byType(AnimatedContainer),
    ),
  );
  return containers.firstWhere((c) {
    final deco = c.decoration;
    if (deco is! BoxDecoration) return false;
    return deco.borderRadius != null;
  });
}

void main() {
  group('StepProgressIndicator', () {
    testWidgets('renders 3 dots and 2 lines when totalSteps is 3', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapInApp(const StepProgressIndicator(currentStep: 1)),
      );

      // Find Containers scoped within the StepProgressIndicator
      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(StepProgressIndicator),
          matching: find.byType(Container),
        ),
      );
      final dots = containers.where((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        return deco.shape == BoxShape.circle;
      });
      expect(dots.length, 3);
    });

    testWidgets('step 1 active highlights only the first dot', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(const StepProgressIndicator(currentStep: 1)),
      );

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(StepProgressIndicator),
          matching: find.byType(Container),
        ),
      );
      final dots = containers.where((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        return deco.shape == BoxShape.circle;
      }).toList();

      // First dot should be active (AppColors.primary)
      final firstDot = dots[0].decoration as BoxDecoration;
      expect(firstDot.color, AppColors.primary);

      // Second dot should be inactive
      final secondDot = dots[1].decoration as BoxDecoration;
      expect(secondDot.color, isNot(AppColors.primary));
    });

    testWidgets('step 2 shows completed dot 1 and active dot 2', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapInApp(const StepProgressIndicator(currentStep: 2)),
      );

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(StepProgressIndicator),
          matching: find.byType(Container),
        ),
      );
      final dots = containers.where((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        return deco.shape == BoxShape.circle;
      }).toList();

      expect(dots.length, 3);

      final firstDot = dots[0].decoration as BoxDecoration;
      final secondDot = dots[1].decoration as BoxDecoration;
      final thirdDot = dots[2].decoration as BoxDecoration;

      // Dot 1 is completed (green)
      expect(firstDot.color, AppColors.secondary);
      // Dot 2 is active (purple)
      expect(secondDot.color, AppColors.primary);
      // Dot 3 is inactive
      expect(thirdDot.color, isNot(AppColors.primary));
      expect(thirdDot.color, isNot(AppColors.secondary));
    });

    testWidgets('step 3 shows completed dots 1-2 and active dot 3', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapInApp(const StepProgressIndicator(currentStep: 3)),
      );

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(StepProgressIndicator),
          matching: find.byType(Container),
        ),
      );
      final dots = containers.where((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        return deco.shape == BoxShape.circle;
      }).toList();

      // Dots 1-2 are completed (green)
      expect((dots[0].decoration as BoxDecoration).color, AppColors.secondary);
      expect((dots[1].decoration as BoxDecoration).color, AppColors.secondary);
      // Dot 3 is active (purple)
      expect((dots[2].decoration as BoxDecoration).color, AppColors.primary);
    });

    testWidgets('respects custom totalSteps', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(const StepProgressIndicator(currentStep: 1, totalSteps: 5)),
      );

      final containers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(StepProgressIndicator),
          matching: find.byType(Container),
        ),
      );
      final dots = containers.where((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        return deco.shape == BoxShape.circle;
      });
      expect(dots.length, 5);
    });
  });

  group('MessagePreviewCard', () {
    testWidgets('renders sender name and message body', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          const MessagePreviewCard(
            senderName: 'bKash',
            messageBody: 'Tk 500.00 debited from A/C',
          ),
        ),
      );

      expect(find.text('bKash'), findsOneWidget);
      expect(find.text('Tk 500.00 debited from A/C'), findsOneWidget);
    });

    testWidgets('sender name is styled with primary color', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          const MessagePreviewCard(
            senderName: 'TestSender',
            messageBody: 'Test body',
          ),
        ),
      );

      final senderText = tester.widget<Text>(find.text('TestSender'));
      final style = senderText.style;
      expect(style?.color, AppColors.primary);
      expect(style?.fontWeight, FontWeight.w600);
    });

    testWidgets('message body uses textPrimaryDark color', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          const MessagePreviewCard(
            senderName: 'Sender',
            messageBody: 'Hello world',
          ),
        ),
      );

      final bodyText = tester.widget<Text>(find.text('Hello world'));
      expect(bodyText.style?.color, AppColors.textPrimaryDark);
    });

    testWidgets('card has dark surface background', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          const MessagePreviewCard(senderName: 'Sender', messageBody: 'Body'),
        ),
      );

      // Find the Container that is a descendant of MessagePreviewCard
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(MessagePreviewCard),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.surfaceDark);
    });
  });

  group('TriggerWordChip', () {
    testWidgets('renders word text', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          TriggerWordChip(word: 'debited', isSelected: false, onTap: () {}),
        ),
      );

      expect(find.text('debited'), findsOneWidget);
    });

    testWidgets('has default dark background when unselected', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          TriggerWordChip(word: 'paid', isSelected: false, onTap: () {}),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, const Color(0xFF2B292C));
    });

    testWidgets('has purple-tinted background when selected', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          TriggerWordChip(word: 'debited', isSelected: true, onTap: () {}),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.primary.withAlpha(0x20));
    });

    testWidgets('selected chip has primary border', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          TriggerWordChip(word: 'spent', isSelected: true, onTap: () {}),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.border, isA<Border>());
      final border = decoration.border as Border;
      expect(border.top.color, AppColors.primary);
    });

    testWidgets('unselected chip has transparent border', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          TriggerWordChip(word: 'paid', isSelected: false, onTap: () {}),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.color, Colors.transparent);
    });

    testWidgets('selected text uses primary color and bold', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          TriggerWordChip(word: 'debited', isSelected: true, onTap: () {}),
        ),
      );

      final text = tester.widget<Text>(find.text('debited'));
      expect(text.style?.color, AppColors.primary);
      expect(text.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('unselected text uses textPrimaryDark and normal weight', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapInApp(
          TriggerWordChip(word: 'paid', isSelected: false, onTap: () {}),
        ),
      );

      final text = tester.widget<Text>(find.text('paid'));
      expect(text.style?.color, AppColors.textPrimaryDark);
      expect(text.style?.fontWeight, FontWeight.normal);
    });

    testWidgets('onTap is called when chip is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrapInApp(
          TriggerWordChip(
            word: 'debited',
            isSelected: false,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('debited'));
      expect(tapped, isTrue);
    });

    testWidgets('has 16px border radius', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          TriggerWordChip(word: 'test', isSelected: false, onTap: () {}),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(16));
    });

    testWidgets('has correct padding', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          TriggerWordChip(word: 'test', isSelected: false, onTap: () {}),
        ),
      );

      final container = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(
        container.padding,
        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      );
    });
  });

  group('AmountRow', () {
    testWidgets('renders amount text', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          AmountRow(amount: '500.00', isSelected: false, onTap: () {}),
        ),
      );

      expect(find.text('500.00'), findsOneWidget);
    });

    testWidgets('selected state has purple border', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(AmountRow(amount: '100', isSelected: true, onTap: () {})),
      );

      final container = _findAmountRowContainer(tester);
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.color, AppColors.primary);
    });

    testWidgets('unselected state has transparent border', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(AmountRow(amount: '100', isSelected: false, onTap: () {})),
      );

      final container = _findAmountRowContainer(tester);
      final decoration = container.decoration as BoxDecoration;
      final border = decoration.border as Border;
      expect(border.top.color, Colors.transparent);
    });

    testWidgets('has dark surface background', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(AmountRow(amount: '100', isSelected: false, onTap: () {})),
      );

      final container = _findAmountRowContainer(tester);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.surfaceDark);
    });

    testWidgets('has 12px border radius', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(AmountRow(amount: '100', isSelected: false, onTap: () {})),
      );

      final container = _findAmountRowContainer(tester);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(12));
    });

    testWidgets('onTap is called when row is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _wrapInApp(
          AmountRow(
            amount: '500.00',
            isSelected: false,
            onTap: () => tapped = true,
          ),
        ),
      );

      await tester.tap(find.text('500.00'));
      expect(tapped, isTrue);
    });

    testWidgets('amount text has 18px font size and w600 weight', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrapInApp(AmountRow(amount: '99.99', isSelected: false, onTap: () {})),
      );

      final text = tester.widget<Text>(find.text('99.99'));
      expect(text.style?.fontSize, 18);
      expect(text.style?.fontWeight, FontWeight.w600);
      expect(text.style?.color, AppColors.primary);
    });

    testWidgets('selected shows filled radio button', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(AmountRow(amount: '100', isSelected: true, onTap: () {})),
      );

      // The radio button inner dot (10x10 circle with backgroundDark color)
      // should be present when selected
      final radioContainers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(AmountRow),
          matching: find.byType(Container),
        ),
      );

      // Find the radio button outer circle (22x22 with primary fill)
      final radioOuter = radioContainers.where((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        return deco.shape == BoxShape.circle && deco.color == AppColors.primary;
      });
      expect(radioOuter.length, 1);
    });

    testWidgets('unselected shows empty radio button', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(AmountRow(amount: '100', isSelected: false, onTap: () {})),
      );

      final radioContainers = tester.widgetList<Container>(
        find.descendant(
          of: find.byType(AmountRow),
          matching: find.byType(Container),
        ),
      );

      // Find the radio button outer circle (22x22 with transparent fill)
      final radioOuter = radioContainers.where((c) {
        final deco = c.decoration;
        if (deco is! BoxDecoration) return false;
        return deco.shape == BoxShape.circle &&
            deco.color == Colors.transparent;
      });
      expect(radioOuter.length, 1);
    });
  });
}
