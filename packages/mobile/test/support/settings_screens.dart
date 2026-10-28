import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/auth/domain/entities/user.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/categories/presentation/pages/category_list_page.dart';
import 'package:expense_tracker/features/data_wipe/domain/entities/local_data_summary.dart';
import 'package:expense_tracker/features/data_wipe/presentation/bloc/delete_all_data_bloc.dart';
import 'package:expense_tracker/features/data_wipe/presentation/bloc/delete_all_data_state.dart';
import 'package:expense_tracker/features/data_wipe/presentation/pages/delete_all_data_page.dart';
import 'package:expense_tracker/features/export/presentation/bloc/export_bloc.dart';
import 'package:expense_tracker/features/export/presentation/bloc/export_state.dart';
import 'package:expense_tracker/features/export/presentation/pages/export_data_page.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/message_source.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/watched_sender.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/sms_watchlist_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/sms_watchlist_state.dart';
import 'package:expense_tracker/features/message_templates/presentation/pages/sms_watchlist_page.dart';
import 'package:expense_tracker/features/records/domain/usecases/get_category_record_counts.dart';
import 'package:expense_tracker/features/recurring/application/recurring_auto_poster.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_state.dart';
import 'package:expense_tracker/features/recurring/presentation/pages/recurring_list_page.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/settings_state.dart';
import 'package:expense_tracker/features/settings/presentation/pages/appearance_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/calendar_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/currency_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/font_size_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/home_page_settings_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/language_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/notification_settings_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/number_format_page.dart';
import 'package:expense_tracker/features/settings/presentation/pages/settings_page.dart';
import 'package:expense_tracker/features/sync/domain/entities/sync_overview.dart';
import 'package:expense_tracker/features/sync/presentation/bloc/sync_screen_bloc.dart';
import 'package:expense_tracker/features/sync/presentation/bloc/sync_screen_state.dart';
import 'package:expense_tracker/features/sync/presentation/pages/sync_settings_page.dart';

import 'core_screens.dart';
import 'factories/category_factory.dart';
import 'factories/recurring_factory.dart';
import 'factories/user_settings_factory.dart';

class MockRecurringBloc extends Mock implements RecurringBloc {}

class MockAutoPoster extends Mock implements RecurringAutoPoster {}

class MockGetCategoryRecordCounts extends Mock
    implements GetCategoryRecordCounts {}

class MockSmsWatchlistBloc extends Mock implements SmsWatchlistBloc {}

class MockExportBloc extends Mock implements ExportBloc {}

class MockSyncScreenBloc extends Mock implements SyncScreenBloc {}

class MockDeleteAllDataBloc extends Mock implements DeleteAllDataBloc {}

SettingsBloc _loadedSettingsBloc() {
  return mockBloc<MockSettingsBloc, SettingsState>(
    MockSettingsBloc(),
    SettingsLoaded(makeUserSettings()),
  );
}

Widget _withSettings(Widget view) {
  return BlocProvider<SettingsBloc>.value(
    value: _loadedSettingsBloc(),
    child: view,
  );
}

Map<String, Widget Function()> get settingsScreens => {
  'Settings list': _settingsListScreen,
  'Default currency': () => _withSettings(const CurrencyView()),
  'Number format': () => _withSettings(const NumberFormatView()),
  'Font size': () => _withSettings(const FontSizeView()),
  'Appearance': () => _withSettings(const AppearanceView()),
  'Calendar': () => _withSettings(const CalendarView()),
  'Home page': () => _withSettings(const HomePageSettingsView()),
  'Notifications': _notificationsScreen,
  'Recurring transactions': recurringScreen,
  'Sync': _syncScreen,
  'Export data': _exportScreen,
  'Delete all data': _deleteDataScreen,
  'SMS Watchlist': smsWatchlistScreen,
  'Language': () => _withSettings(const LanguageView()),
  'Categories': _categoriesScreen,
};

const settingsPages = {
  'Settings list': 'settings/presentation/pages/settings_page.dart',
  'Default currency': 'settings/presentation/pages/currency_page.dart',
  'Number format': 'settings/presentation/pages/number_format_page.dart',
  'Font size': 'settings/presentation/pages/font_size_page.dart',
  'Appearance': 'settings/presentation/pages/appearance_page.dart',
  'Calendar': 'settings/presentation/pages/calendar_page.dart',
  'Home page': 'settings/presentation/pages/home_page_settings_page.dart',
  'Notifications':
      'settings/presentation/pages/notification_settings_page.dart',
  'Recurring transactions':
      'recurring/presentation/pages/recurring_list_page.dart',
  'Sync': 'sync/presentation/pages/sync_settings_page.dart',
  'Export data': 'export/presentation/pages/export_data_page.dart',
  'Delete all data': 'data_wipe/presentation/pages/delete_all_data_page.dart',
  'SMS Watchlist':
      'message_templates/presentation/pages/sms_watchlist_page.dart',
  'Language': 'settings/presentation/pages/language_page.dart',
  'Categories': 'categories/presentation/pages/category_list_page.dart',
};

Widget _syncScreen() {
  return MultiBlocProvider(
    providers: [
      BlocProvider<SettingsBloc>.value(value: _loadedSettingsBloc()),
      BlocProvider<AuthBloc>.value(
        value: mockBloc<MockAuthBloc, AuthState>(
          MockAuthBloc(),
          const Authenticated(User(uid: 'u1', displayName: 'Sam')),
        ),
      ),
      BlocProvider<SyncScreenBloc>.value(
        value: mockBloc<MockSyncScreenBloc, SyncScreenState>(
          MockSyncScreenBloc(),
          SyncScreenState(
            loadStatus: SyncScreenLoadStatus.loaded,
            overview: SyncOverview(
              isSignedIn: true,
              lastFailedSyncAt: DateTime(2026, 9, 30, 21, 45),
              consecutiveFailures: 3,
              pendingCount: 128,
            ),
          ),
        ),
      ),
    ],
    child: const SyncSettingsView(),
  );
}

Widget _exportScreen() {
  return BlocProvider<ExportBloc>.value(
    value: mockBloc<MockExportBloc, ExportState>(
      MockExportBloc(),
      const ExportState(),
    ),
    child: const ExportDataView(),
  );
}

Widget _deleteDataScreen() {
  return BlocProvider<DeleteAllDataBloc>.value(
    value: mockBloc<MockDeleteAllDataBloc, DeleteAllDataState>(
      MockDeleteAllDataBloc(),
      const DeleteAllDataState(
        status: DeleteAllDataStatus.ready,
        isSignedIn: true,
        summary: LocalDataSummary(
          transactions: 247,
          budgets: 5,
          categories: 18,
          recurring: 3,
          smsRules: 4,
          goals: 2,
        ),
      ),
    ),
    child: const DeleteAllDataView(),
  );
}

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

Widget recurringScreen({RecurringState? state}) {
  final autoPoster = MockAutoPoster();
  when(() => autoPoster.isReadyToPost()).thenAnswer((_) async => true);
  di.getIt.registerSingleton<RecurringAutoPoster>(autoPoster);

  return MultiBlocProvider(
    providers: [
      BlocProvider<RecurringBloc>.value(
        value: mockBloc<MockRecurringBloc, RecurringState>(
          MockRecurringBloc(),
          state ??
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

Widget smsWatchlistScreen({SmsWatchlistState? state}) {
  final now = DateTime(2026);
  MessageSource source(String id, String name, {bool monitored = true}) =>
      MessageSource(
        id: id,
        contactId: id.toUpperCase(),
        contactName: name,
        isMonitored: monitored,
        createdAt: now,
        updatedAt: now,
      );

  return BlocProvider<SmsWatchlistBloc>.value(
    value: mockBloc<MockSmsWatchlistBloc, SmsWatchlistState>(
      MockSmsWatchlistBloc(),
      state ??
          SmsWatchlistReady(
            senders: [
              WatchedSender(source: source('bkash', 'bKash'), formatCount: 2),
              WatchedSender(
                source: source('citybank', 'City Bank', monitored: false),
                formatCount: 1,
              ),
            ],
          ),
    ),
    child: const Scaffold(body: SmsWatchlistView()),
  );
}
