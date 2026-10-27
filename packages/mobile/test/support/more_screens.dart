import 'package:clock/clock.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/core/constants/source_types.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:expense_tracker/features/ai_assistant/presentation/bloc/ai_assistant_bloc.dart';
import 'package:expense_tracker/features/ai_assistant/presentation/bloc/ai_assistant_state.dart';
import 'package:expense_tracker/features/ai_assistant/presentation/pages/ai_assistant_page.dart';
import 'package:expense_tracker/features/auth/domain/entities/user.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:expense_tracker/features/auth/presentation/pages/login_page.dart';
import 'package:expense_tracker/features/auth/presentation/pages/sync_conflict_page.dart';
import 'package:expense_tracker/features/budgets/domain/usecases/get_budgets_with_progress.dart';
import 'package:expense_tracker/features/budgets/presentation/pages/all_budgets_picker_page.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/categories/presentation/pages/category_form_page.dart';
import 'package:expense_tracker/features/family/domain/entities/cached.dart';
import 'package:expense_tracker/features/family/domain/entities/invite_code.dart';
import 'package:expense_tracker/features/family/domain/entities/my_group.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_bloc.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_state.dart';
import 'package:expense_tracker/features/family/presentation/pages/family_home_page.dart';
import 'package:expense_tracker/features/family/presentation/pages/family_invite_page.dart';
import 'package:expense_tracker/features/family/presentation/pages/family_join_page.dart';
import 'package:expense_tracker/features/family/presentation/pages/family_members_page.dart';
import 'package:expense_tracker/features/goals/presentation/bloc/goal_form_bloc.dart';
import 'package:expense_tracker/features/goals/presentation/bloc/goal_form_state.dart';
import 'package:expense_tracker/features/goals/domain/entities/goal.dart';
import 'package:expense_tracker/features/goals/presentation/bloc/goal_bloc.dart';
import 'package:expense_tracker/features/goals/presentation/bloc/goal_state.dart';
import 'package:expense_tracker/features/goals/presentation/pages/goal_form_page.dart';
import 'package:expense_tracker/features/goals/presentation/pages/goals_page.dart';
import 'package:expense_tracker/features/message_templates/domain/entities/message_source.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/contact_selector_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/contact_selector_state.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/message_sources_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/message_sources_state.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/sample_analyzer_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/sample_analyzer_state.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/template_editor_bloc.dart';
import 'package:expense_tracker/features/message_templates/presentation/bloc/template_editor_state.dart';
import 'package:expense_tracker/features/message_templates/presentation/pages/contact_selector_page.dart';
import 'package:expense_tracker/features/message_templates/presentation/pages/sample_analyzer_page.dart';
import 'package:expense_tracker/features/message_templates/presentation/pages/template_editor_page.dart';
import 'package:expense_tracker/features/onboarding/presentation/bloc/onboarding_bloc.dart';
import 'package:expense_tracker/features/onboarding/presentation/bloc/onboarding_state.dart';
import 'package:expense_tracker/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:expense_tracker/features/onboarding/presentation/pages/tutorial_page.dart';
import 'package:expense_tracker/features/onboarding/presentation/widgets/onboarding_budget_plan_page.dart';
import 'package:expense_tracker/features/onboarding/presentation/widgets/onboarding_goal_page.dart';
import 'package:expense_tracker/features/onboarding/presentation/widgets/onboarding_income_page.dart';
import 'package:expense_tracker/features/onboarding/presentation/widgets/onboarding_recurring_page.dart';
import 'package:expense_tracker/features/onboarding/presentation/widgets/onboarding_timeline_page.dart';
import 'package:expense_tracker/features/receipt_scan/domain/usecases/extract_receipt.dart';
import 'package:expense_tracker/features/receipt_scan/presentation/pages/receipt_scan_camera_page.dart';
import 'package:expense_tracker/features/records/presentation/pages/all_categories_picker_page.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_bloc.dart';
import 'package:expense_tracker/features/recurring/presentation/bloc/recurring_state.dart';
import 'package:expense_tracker/features/recurring/presentation/pages/recurring_form_page.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/delete_account_bloc.dart';
import 'package:expense_tracker/features/settings/presentation/bloc/delete_account_state.dart';
import 'package:expense_tracker/features/settings/presentation/pages/delete_account_dialog.dart';
import 'package:expense_tracker/features/settings/presentation/pages/profile_page.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_bloc.dart';
import 'package:expense_tracker/features/sms_parser/presentation/bloc/sms_scanner_state.dart';
import 'package:expense_tracker/features/sms_parser/presentation/pages/auto_import_page.dart';
import 'package:expense_tracker/features/sms_parser/presentation/pages/sms_scan_results_page.dart';
import 'package:expense_tracker/features/support/data/services/app_review_service.dart';
import 'package:expense_tracker/features/support/presentation/pages/about_page.dart';
import 'package:expense_tracker/features/support/presentation/pages/faq_page.dart';
import 'package:expense_tracker/features/support/presentation/pages/help_page.dart';
import 'package:expense_tracker/features/support/presentation/pages/rate_app_page.dart';

import 'core_screens.dart';
import 'factories/category_factory.dart';
import 'factories/family_factory.dart';
import 'factories/sms_message_factory.dart';
import 'factories/sms_scan_result_item_factory.dart';
import 'family_bloc_mock.dart';
import 'receipt_camera.dart';

class MockAiAssistantBloc extends Mock implements AiAssistantBloc {}

class MockGoalFormBloc extends Mock implements GoalFormBloc {}

class MockOnboardingBloc extends Mock implements OnboardingBloc {}

class MockDeleteAccountBloc extends Mock implements DeleteAccountBloc {}

class MockSmsScannerBloc extends Mock implements SmsScannerBloc {}

class MockContactSelectorBloc extends Mock implements ContactSelectorBloc {}

class MockMessageSourcesBloc extends Mock implements MessageSourcesBloc {}

class MockSampleAnalyzerBloc extends Mock implements SampleAnalyzerBloc {}

class MockTemplateEditorBloc extends Mock implements TemplateEditorBloc {}

class MockRecurringFormBloc extends Mock implements RecurringBloc {}

class MockGetBudgetsWithProgress extends Mock
    implements GetBudgetsWithProgress {}

class MockExtractReceipt extends Mock implements ExtractReceipt {}

class MockAppReviewService extends Mock implements AppReviewService {}

const _user = User(
  uid: 'u1',
  email: 'sam@example.com',
  displayName: 'Sam Rahman',
);

AuthBloc _authBloc(AuthState state) =>
    mockBloc<MockAuthBloc, AuthState>(MockAuthBloc(), state);

CategoryBloc _categoryBloc() => mockBloc<MockCategoryBloc, CategoryState>(
  MockCategoryBloc(),
  CategoryLoaded([
    makeCategory(id: 'food', name: 'Food & Dining'),
    makeCategory(id: 'transport', name: 'Transport'),
  ]),
);

final _source = MessageSource(
  id: 'src-1',
  contactId: '16216',
  contactName: 'bKash',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

final _sms = makeSmsMessage(
  address: 'bKash',
  body:
      'Tk 500.00 debited from A/C XX1234 at Shwapno. Fee Tk 0. '
      'Balance Tk 12,340.00',
);

FamilyState _familyReady() {
  final now = clock.now();

  return FamilyState(
    status: FamilyStatus.ready,
    group: Cached<MyGroup?>(
      makeMyGroup(
        invite: InviteCode(
          code: 'RF4XK2',
          expiresAt: now.add(const Duration(hours: 48)),
        ),
      ),
      fetchedAt: now,
    ),
  );
}

Widget _withFamily(Widget page, [FamilyState? state]) =>
    BlocProvider<FamilyBloc>.value(
      value: familyBlocWith(state ?? _familyReady()),
      child: page,
    );

Widget _onboardingStep(Widget step, {int index = 0}) =>
    BlocProvider<OnboardingBloc>.value(
      value: mockBloc<MockOnboardingBloc, OnboardingState>(
        MockOnboardingBloc(),
        OnboardingState(step: index),
      ),
      child: Scaffold(body: step),
    );

Widget loginScreen() => BlocProvider<AuthBloc>.value(
  value: _authBloc(const Unauthenticated()),
  child: const LoginPage(),
);

Widget syncConflictScreen() => BlocProvider<AuthBloc>.value(
  value: _authBloc(const AuthSyncConflictPending(_user)),
  child: const SyncConflictPage(),
);

Widget aiAssistantScreen() {
  final at = DateTime(2026, 10, 5, 9, 30);
  final bloc = mockBloc<MockAiAssistantBloc, AiAssistantState>(
    MockAiAssistantBloc(),
    AiAssistantState(
      messages: [
        ChatMessage(
          role: ChatRole.user,
          content: 'How much did I spend on food?',
          timestamp: at,
        ),
        ChatMessage(
          role: ChatRole.assistant,
          content: 'You spent Tk 4,250 on Food & Dining this month.',
          timestamp: at,
        ),
      ],
    ),
  );
  di.getIt.registerFactory<AiAssistantBloc>(() => bloc);

  return const AiAssistantPage();
}

Widget allBudgetsPickerScreen() {
  final getBudgets = MockGetBudgetsWithProgress();
  when(
    () => getBudgets(),
  ).thenAnswer((_) async => Right([sampleBudgetProgress()]));
  di.getIt.registerSingleton<GetBudgetsWithProgress>(getBudgets);

  return const AllBudgetsPickerPage(selectedId: 'b1');
}

Widget categoryFormScreen() => BlocProvider<CategoryBloc>.value(
  value: _categoryBloc(),
  child: const CategoryFormPage(initialType: RecordType.expense),
);

Widget allCategoriesPickerScreen() => BlocProvider<CategoryBloc>.value(
  value: _categoryBloc(),
  child: const AllCategoriesPickerPage(
    type: RecordType.expense,
    selectedId: 'food',
  ),
);

Widget familyHomeScreen() => _withFamily(const FamilyHomePage());

Widget familyHomeNoGroupScreen() => _withFamily(
  const FamilyHomePage(),
  FamilyState(
    status: FamilyStatus.ready,
    group: Cached<MyGroup?>(null, fetchedAt: clock.now()),
  ),
);

Widget familyInviteScreen() => _withFamily(const FamilyInvitePage());

Widget familyJoinScreen() => _withFamily(const FamilyJoinPage());

Widget familyMembersScreen() => _withFamily(const FamilyMembersPage());

Widget goalFormScreen() => BlocProvider<GoalFormBloc>.value(
  value: mockBloc<MockGoalFormBloc, GoalFormState>(
    MockGoalFormBloc(),
    const GoalFormState(status: GoalFormStatus.ready),
  ),
  child: const GoalFormPage(),
);

Widget goalsScreen({GoalState? state}) => BlocProvider<GoalBloc>.value(
  value: mockBloc<MockGoalBloc, GoalState>(
    MockGoalBloc(),
    state ??
        const GoalState(
          status: GoalStatus.ready,
          goals: [
            Goal(
              id: 'g-1',
              name: 'New laptop',
              targetAmount: 2000,
              savedAmount: 500,
            ),
            Goal(id: 'g-0', name: 'Trip', targetAmount: 300, savedAmount: 300),
          ],
        ),
  ),
  child: const GoalsView(),
);

Widget contactSelectorScreen() => MultiBlocProvider(
  providers: [
    BlocProvider<ContactSelectorBloc>.value(
      value: mockBloc<MockContactSelectorBloc, ContactSelectorState>(
        MockContactSelectorBloc(),
        ContactSelectorLoaded(
          contacts: [
            DeviceContact(
              address: '16216',
              displayName: 'bKash',
              lastMessage: 'Your A/C XX1234 debited by BDT 450.00',
              lastMessageDate: DateTime(2026, 10, 11),
              sourceType: ExpenseSource.sms,
            ),
          ],
        ),
      ),
    ),
    BlocProvider<MessageSourcesBloc>.value(
      value: mockBloc<MockMessageSourcesBloc, MessageSourcesState>(
        MockMessageSourcesBloc(),
        MessageSourcesLoaded(sources: [_source]),
      ),
    ),
  ],
  child: const ContactSelectorView(),
);

Widget sampleAnalyzerScreen() => BlocProvider<SampleAnalyzerBloc>.value(
  value: mockBloc<MockSampleAnalyzerBloc, SampleAnalyzerState>(
    MockSampleAnalyzerBloc(),
    SampleAnalyzerLoaded(messages: [_sms], hasReachedMax: true),
  ),
  child: SampleAnalyzerView(source: _source),
);

Widget templateEditorScreen() => MultiBlocProvider(
  providers: [
    BlocProvider<TemplateEditorBloc>.value(
      value: mockBloc<MockTemplateEditorBloc, TemplateEditorState>(
        MockTemplateEditorBloc(),
        const TemplateEditorInitial(),
      ),
    ),
    BlocProvider<MessageSourcesBloc>.value(
      value: mockBloc<MockMessageSourcesBloc, MessageSourcesState>(
        MockMessageSourcesBloc(),
        MessageSourcesLoaded(sources: [_source]),
      ),
    ),
  ],
  child: InteractiveTemplateBuilder(source: _source, sampleMessage: _sms),
);

Widget onboardingScreen() => BlocProvider<OnboardingBloc>.value(
  value: mockBloc<MockOnboardingBloc, OnboardingState>(
    MockOnboardingBloc(),
    const OnboardingState(),
  ),
  child: const OnboardingPage(),
);

Map<String, Widget Function()> get onboardingSteps => {
  'Onboarding / income': () => _onboardingStep(const OnboardingIncomePage()),
  'Onboarding / recurring': () =>
      _onboardingStep(const OnboardingRecurringPage(), index: 1),
  'Onboarding / budget plan': () =>
      _onboardingStep(const OnboardingBudgetPlanPage(), index: 2),
  'Onboarding / goal': () =>
      _onboardingStep(const OnboardingGoalPage(), index: 3),
  'Onboarding / timeline': () =>
      _onboardingStep(const OnboardingTimelinePage(), index: 4),
};

Widget tutorialScreen() => const TutorialPage();

Widget receiptCameraScreen() {
  mockCameraPermissionDenied();
  addTearDown(clearCameraPermissionMock);

  return ReceiptScanCameraPage(
    extractReceipt: MockExtractReceipt(),
    expenseCategoryNames: const ['Food & Dining', 'Transport'],
  );
}

Widget recurringFormScreen() => MultiBlocProvider(
  providers: [
    BlocProvider<RecurringBloc>.value(
      value: mockBloc<MockRecurringFormBloc, RecurringState>(
        MockRecurringFormBloc(),
        const RecurringInitial(),
      ),
    ),
    BlocProvider<CategoryBloc>.value(value: _categoryBloc()),
  ],
  child: const RecurringFormPage(),
);

Widget autoImportScreen() => const AutoImportPage();

Widget smsScanResultsScreen() => BlocProvider<SmsScannerBloc>.value(
  value: mockBloc<MockSmsScannerBloc, SmsScannerState>(
    MockSmsScannerBloc(),
    SmsScannerScanComplete(
      results: [
        makeSmsScanResultItem(
          sourceId: 'a',
          senderKey: 'BKASH',
          senderLabel: 'bKash',
        ),
        makeSmsScanResultItem(
          sourceId: 'b',
          senderKey: 'CITY',
          senderLabel: 'City Bank',
        ),
      ],
      selectedIds: const {'a'},
      lastScanTimestamp: DateTime(2026, 10, 11),
    ),
  ),
  child: const SmsScanResultsPage(),
);

Widget profileScreen() => MultiBlocProvider(
  providers: [
    BlocProvider<AuthBloc>.value(value: _authBloc(const Authenticated(_user))),
    BlocProvider<DeleteAccountBloc>.value(
      value: mockBloc<MockDeleteAccountBloc, DeleteAccountState>(
        MockDeleteAccountBloc(),
        const DeleteAccountState(),
      ),
    ),
  ],
  child: const ProfileView(),
);

Widget deleteAccountDialogScreen() =>
    Center(child: DeleteAccountDialog(onConfirm: () {}));

Widget aboutScreen() => AboutPage(
  loadInfo: () async => PackageInfo(
    appName: 'Expenzo',
    packageName: 'com.acesiflabs.expenzo',
    version: '1.2.3',
    buildNumber: '45',
  ),
);

Widget faqScreen() => const FaqPage();

Widget helpScreen() => const HelpPage();

Widget rateAppScreen() {
  di.getIt.registerSingleton<AppReviewService>(MockAppReviewService());

  return const RateAppPage();
}
