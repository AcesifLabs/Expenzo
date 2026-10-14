import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/categories/presentation/pages/category_list_page.dart';
import 'package:expense_tracker/features/parsing_rules/domain/entities/parsing_rule.dart';
import 'package:expense_tracker/features/parsing_rules/presentation/bloc/parsing_rules_bloc.dart';
import 'package:expense_tracker/features/parsing_rules/presentation/bloc/parsing_rules_state.dart';
import 'package:expense_tracker/features/parsing_rules/presentation/pages/rules_list_page.dart';
import 'package:expense_tracker/features/records/domain/usecases/get_category_record_counts.dart';
import 'package:expense_tracker/features/recurring/application/recurring_auto_poster.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_state.dart';
import 'package:expense_tracker/features/recurring/presentation/pages/recurring_list_page.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/settings/presentation/pages/appearance_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/currency_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/font_size_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/language_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/number_format_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/settings_page.dart';

import 'core_screens.dart';
import 'factories/category_factory.dart';
import 'factories/recurring_factory.dart';
import 'factories/user_settings_factory.dart';

/// The Settings list and every page it opens that the large-text overflow
/// test covers, each with mocked blocs. Same contract as `core_screens.dart`:
/// call the builders inside the test body.

class MockRecurringBloc extends Mock implements RecurringBloc {}

class MockAutoPoster extends Mock implements RecurringAutoPoster {}

class MockGetCategoryRecordCounts extends Mock
    implements GetCategoryRecordCounts {}

class MockParsingRulesBloc extends Mock implements ParsingRulesBloc {}

SettingsBloc _loadedSettingsBloc() {
  return mockBloc<MockSettingsBloc, SettingsState>(
    MockSettingsBloc(),
    SettingsLoaded(makeUserSettings()),
  );
}

/// A settings page that only reads the app-wide SettingsBloc.
Widget _withSettings(Widget view) {
  return BlocProvider<SettingsBloc>.value(
    value: _loadedSettingsBloc(),
    child: view,
  );
}

/// The named Settings pages, in Settings row order.
Map<String, Widget Function()> get settingsScreens => {
  'Settings list': _settingsListScreen,
  'Default currency': () => _withSettings(const CurrencyView()),
  'Number format': () => _withSettings(const NumberFormatView()),
  'Font size': () => _withSettings(const FontSizeView()),
  'Appearance': () => _withSettings(const AppearanceView()),
  'Notifications': _notificationsScreen,
  'Recurring transactions': _recurringScreen,
  'Matching rules': _matchingRulesScreen,
  'Language': () => _withSettings(const LanguageView()),
  'Categories': _categoriesScreen,
};

Widget _settingsListScreen() {
  return MultiBlocProvider(
    providers: [
      BlocProvider<SettingsBloc>.value(value: _loadedSettingsBloc()),
      BlocProvider<AuthBloc>.value(
        value: mockBloc<MockAuthBloc, AuthState>(
          MockAuthBloc(),
          const Unauthenticated(),
        ),
      ),
    ],
    child: const SettingsView(),
  );
}

Widget _notificationsScreen() {
  return _withSettings(
    NotificationSettingsView(
      requestNotificationPermission: () async => true,
      notificationPermissionGranted: () async => true,
    ),
  );
}

Widget _recurringScreen() {
  final autoPoster = MockAutoPoster();
  when(() => autoPoster.isReadyToPost()).thenAnswer((_) async => true);
  di.getIt.registerSingleton<RecurringAutoPoster>(autoPoster);

  return MultiBlocProvider(
    providers: [
      BlocProvider<RecurringBloc>.value(
        value: mockBloc<MockRecurringBloc, RecurringState>(
          MockRecurringBloc(),
          RecurringLoaded([makeRecurring(id: 'rent', description: 'Rent')]),
        ),
      ),
      BlocProvider<SettingsBloc>.value(value: _loadedSettingsBloc()),
    ],
    child: const RecurringListView(),
  );
}

Widget _categoriesScreen() {
  final getCounts = MockGetCategoryRecordCounts();
  when(
    () => getCounts(any()),
  ).thenAnswer((_) async => const Right({'food': 42}));

  return BlocProvider<CategoryBloc>.value(
    value: mockBloc<MockCategoryBloc, CategoryState>(
      MockCategoryBloc(),
      CategoryLoaded([
        makeCategory(id: 'food', name: 'Food & Dining'),
        makeCategory(id: 'salary', name: 'Salary', type: RecordType.income),
      ]),
    ),
    child: CategoryListPage(getCounts: getCounts),
  );
}

Widget _matchingRulesScreen() {
  final now = DateTime(2026);

  return BlocProvider<ParsingRulesBloc>.value(
    value: mockBloc<MockParsingRulesBloc, ParsingRulesState>(
      MockParsingRulesBloc(),
      ParsingRulesLoaded(
        rules: [
          ParsingRule(
            id: 'rule-1',
            name: 'Bank debit alerts',
            triggerWords: const ['debited'],
            amountPattern: r'Tk ([\d,.]+)',
            sourceType: SourceType.sms,
            isEnabled: true,
            priority: 1,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      ),
    ),
    child: const RulesListPage(),
  );
}
