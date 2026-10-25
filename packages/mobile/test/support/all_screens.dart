import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/budgets/presentation/bloc/budget_state.dart';
import 'package:expense_tracker/features/dashboard/domain/entities/date_range.dart';
import 'package:expense_tracker/features/dashboard/presentation/bloc/dashboard_state.dart';
import 'package:expense_tracker/features/parsing_rules/presentation/bloc/parsing_rules_state.dart';
import 'package:expense_tracker/features/records/presentation/bloc/record_state.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_state.dart';
import 'package:expense_tracker/features/reports/domain/entities/granularity.dart';
import 'package:expense_tracker/features/reports/domain/entities/spending_insights.dart';
import 'package:expense_tracker/features/reports/presentation/bloc/reports_state.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

import 'core_screens.dart';
import 'more_screens.dart';
import 'settings_screens.dart';

/// One screen in one state, for the accessibility, large-text and keyboard
/// tests.
class ScreenCase {
  final String name;
  final Widget Function() build;

  /// The page file under `lib/features/` this case renders, for the check
  /// that every page is covered.
  final String? page;

  /// The button that submits the form, for forms.
  final Finder Function()? submit;

  /// Repeats an animation forever, so the tests pump fixed frames instead of
  /// settling.
  final bool animates;

  const ScreenCase(
    this.name,
    this.build, {
    this.page,
    this.submit,
    this.animates = false,
  });
}

/// Page files that are not screens users see.
const pagesWithoutCase = {
  // Debug builds only, behind a developer setting.
  'settings/presentation/pages/debug_db_inspector_page.dart',
};

const _error = 'Something went wrong';

/// Every screen of the app, plus the empty, loading and error states of the
/// list screens.
List<ScreenCase> get allScreens => [
  // Tabs.
  const ScreenCase(
    'Home',
    homeScreen,
    page: 'dashboard/presentation/pages/dashboard_page.dart',
  ),
  ScreenCase(
    'Home (loading)',
    () => homeScreen(state: const DashboardLoading()),
  ),
  ScreenCase(
    'Home (error)',
    () => homeScreen(state: const DashboardError(message: _error)),
  ),
  ScreenCase(
    'Home (empty)',
    () => homeScreen(
      state: DashboardLoaded(
        summary: emptyDashboardSummary,
        dateRange: DateRange.thisMonth(),
      ),
    ),
  ),
  const ScreenCase('Bottom navigation', appShellScreen),
  const ScreenCase(
    'Activity',
    activityScreen,
    page: 'records/presentation/pages/record_list_page.dart',
  ),
  ScreenCase(
    'Activity (empty)',
    () => activityScreen(state: const RecordLoaded(records: [])),
  ),
  ScreenCase(
    'Activity (loading)',
    () => activityScreen(state: RecordLoading()),
  ),
  ScreenCase(
    'Activity (error)',
    () => activityScreen(state: const RecordError(_error)),
  ),
  const ScreenCase(
    'Budgets',
    budgetsScreen,
    page: 'budgets/presentation/pages/budget_list_page.dart',
  ),
  ScreenCase(
    'Budgets (empty)',
    () => budgetsScreen(state: const BudgetLoaded([])),
  ),
  ScreenCase('Budgets (loading)', () => budgetsScreen(state: BudgetLoading())),
  ScreenCase(
    'Budgets (error)',
    () => budgetsScreen(state: const BudgetError(_error)),
  ),
  const ScreenCase(
    'Budget details',
    budgetDetailsScreen,
    page: 'budgets/presentation/pages/budget_details_page.dart',
  ),
  ScreenCase(
    'Budget form',
    budgetFormScreen,
    page: 'budgets/presentation/pages/budget_form_page.dart',
    submit: () => find.text(t.common.save),
  ),
  const ScreenCase(
    'Reports',
    reportsScreen,
    page: 'reports/presentation/pages/reports_screen.dart',
  ),
  ScreenCase(
    'Reports (empty)',
    () => reportsScreen(
      state: ReportsLoaded(
        spendingTrend: const [],
        categoryBreakdown: const [],
        insights: const SpendingInsights(
          highestDayAmount: 0,
          avgDailySpending: 0,
          totalTransactionCount: 0,
          totalSpent: 0,
        ),
        startDate: DateTime(2026, 10),
        endDate: DateTime(2026, 10, 31),
        granularity: Granularity.daily,
      ),
    ),
  ),
  ScreenCase('Reports (loading)', () => reportsScreen(state: ReportsLoading())),
  ScreenCase(
    'Reports (error)',
    () => reportsScreen(state: const ReportsError(message: _error)),
  ),
  ScreenCase(
    'Transaction sheet',
    transactionSheetScreen,
    submit: () => find.text(t.common.addExpense),
  ),
  // Settings.
  for (final MapEntry(key: name, value: build) in settingsScreens.entries)
    ScreenCase('Settings / $name', build, page: settingsPages[name]),
  ScreenCase(
    'Settings / Recurring transactions (empty)',
    () => recurringScreen(state: const RecurringLoaded([])),
  ),
  ScreenCase(
    'Settings / Recurring transactions (error)',
    () => recurringScreen(state: const RecurringError(_error)),
  ),
  ScreenCase(
    'Settings / Matching rules (empty)',
    () => matchingRulesScreen(state: const ParsingRulesLoaded(rules: [])),
  ),
  ScreenCase(
    'Settings / Matching rules (error)',
    () => matchingRulesScreen(state: const ParsingRulesError(message: _error)),
  ),
  // Everything else.
  const ScreenCase(
    'Sign in',
    loginScreen,
    page: 'auth/presentation/pages/login_page.dart',
  ),
  const ScreenCase(
    'Sync conflict',
    syncConflictScreen,
    page: 'auth/presentation/pages/sync_conflict_page.dart',
  ),
  ScreenCase(
    'AI assistant',
    aiAssistantScreen,
    page: 'ai_assistant/presentation/pages/ai_assistant_page.dart',
    submit: () => find.bySemanticsLabel(t.aiAssistant.send),
  ),
  const ScreenCase(
    'Budget picker',
    allBudgetsPickerScreen,
    page: 'budgets/presentation/pages/all_budgets_picker_page.dart',
  ),
  ScreenCase(
    'Category form',
    categoryFormScreen,
    page: 'categories/presentation/pages/category_form_page.dart',
    submit: () => find.text(t.common.save),
  ),
  const ScreenCase(
    'Category picker',
    allCategoriesPickerScreen,
    page: 'records/presentation/pages/all_categories_picker_page.dart',
  ),
  const ScreenCase(
    'Family home',
    familyHomeScreen,
    page: 'family/presentation/pages/family_home_page.dart',
  ),
  const ScreenCase('Family home (no group)', familyHomeNoGroupScreen),
  const ScreenCase(
    'Family invite',
    familyInviteScreen,
    page: 'family/presentation/pages/family_invite_page.dart',
  ),
  ScreenCase(
    'Family join',
    familyJoinScreen,
    page: 'family/presentation/pages/family_join_page.dart',
    submit: () => find.text(t.family.join.submit),
  ),
  const ScreenCase(
    'Family members',
    familyMembersScreen,
    page: 'family/presentation/pages/family_members_page.dart',
  ),
  ScreenCase(
    'Goal form',
    goalFormScreen,
    page: 'goals/presentation/pages/goal_form_page.dart',
    submit: () => find.text(t.common.save),
  ),
  const ScreenCase(
    'Contact selector',
    contactSelectorScreen,
    page: 'message_templates/presentation/pages/contact_selector_page.dart',
  ),
  const ScreenCase(
    'Sample analyzer',
    sampleAnalyzerScreen,
    page: 'message_templates/presentation/pages/sample_analyzer_page.dart',
  ),
  const ScreenCase(
    'Template editor',
    templateEditorScreen,
    page: 'message_templates/presentation/pages/template_editor_page.dart',
  ),
  const ScreenCase(
    'Onboarding',
    onboardingScreen,
    page: 'onboarding/presentation/pages/onboarding_page.dart',
  ),
  for (final MapEntry(key: name, value: build) in onboardingSteps.entries)
    ScreenCase(name, build),
  const ScreenCase(
    'Tutorial',
    tutorialScreen,
    page: 'onboarding/presentation/pages/tutorial_page.dart',
  ),
  const ScreenCase(
    'Receipt camera',
    receiptCameraScreen,
    page: 'receipt_scan/presentation/pages/receipt_scan_camera_page.dart',
    animates: true,
  ),
  ScreenCase(
    'Recurring form',
    recurringFormScreen,
    page: 'recurring/presentation/pages/recurring_form_page.dart',
    submit: () => find.text(t.common.add),
  ),
  const ScreenCase(
    'Auto import',
    autoImportScreen,
    page: 'sms_parser/presentation/pages/auto_import_page.dart',
  ),
  const ScreenCase(
    'SMS scan results',
    smsScanResultsScreen,
    page: 'sms_parser/presentation/pages/sms_scan_results_page.dart',
  ),
  const ScreenCase(
    'Profile',
    profileScreen,
    page: 'settings/presentation/pages/profile_page.dart',
  ),
  const ScreenCase(
    'Delete account dialog',
    deleteAccountDialogScreen,
    page: 'settings/presentation/pages/delete_account_dialog.dart',
  ),
  const ScreenCase(
    'About',
    aboutScreen,
    page: 'support/presentation/pages/about_page.dart',
  ),
  const ScreenCase(
    'FAQ',
    faqScreen,
    page: 'support/presentation/pages/faq_page.dart',
  ),
  const ScreenCase(
    'Help',
    helpScreen,
    page: 'support/presentation/pages/help_page.dart',
  ),
  const ScreenCase(
    'Rate the app',
    rateAppScreen,
    page: 'support/presentation/pages/rate_app_page.dart',
  ),
];
