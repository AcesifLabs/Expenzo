import 'package:expense_tracker/core/constants/record_type.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_event.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_state.dart';
import 'package:expense_tracker/features/categories/presentation/pages/category_form_page.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';

class _MockCategoryBloc extends Mock implements CategoryBloc {}

class _FakeCategoryEvent extends Fake implements CategoryEvent {}

void main() {
  late _MockCategoryBloc bloc;
  final food = Category(
    id: 'default_out_food',
    name: 'Food & Dining',
    emoji: 'forkKnife',
    color: '#FFCDD2',
    isDefault: true,
    type: RecordType.expense,
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );

  setUpAll(() => registerFallbackValue(_FakeCategoryEvent()));

  setUp(() {
    bloc = _MockCategoryBloc();
    when(() => bloc.state).thenReturn(const CategoryInitial());
    when(
      () => bloc.stream,
    ).thenAnswer((_) => const Stream<CategoryState>.empty());
    when(() => bloc.close()).thenAnswer((_) async {});
  });

  tearDown(() => LocaleSettings.setLocaleSync(AppLocale.en));

  Future<Category> saveUnchanged(WidgetTester tester, AppLocale locale) async {
    LocaleSettings.setLocaleSync(locale);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const SizedBox.shrink(),
          routes: [
            GoRoute(
              path: 'edit',
              builder: (_, _) => CategoryFormPage(category: food),
            ),
          ],
        ),
      ],
    );
    await tester.pumpWidget(
      BlocProvider<CategoryBloc>.value(
        value: bloc,
        child: TranslationProvider(
          child: MaterialApp.router(
            locale: locale.flutterLocale,
            supportedLocales: AppLocaleUtils.supportedLocales,
            localizationsDelegates: GlobalMaterialLocalizations.delegates,
            routerConfig: router,
          ),
        ),
      ),
    );
    router.push('/edit');
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.common.save));
    await tester.pumpAndSettle();

    final event =
        verify(() => bloc.add(captureAny())).captured.single
            as UpdateCategoryEvent;

    return event.category;
  }

  testWidgets('editing a default category keeps it a default', (tester) async {
    final saved = await saveUnchanged(tester, AppLocale.en);

    expect(saved.isDefault, isTrue);
  });

  testWidgets('saving a translated default unchanged keeps the seed name', (
    tester,
  ) async {
    final saved = await saveUnchanged(tester, AppLocale.bn);

    expect(saved.name, 'Food & Dining');
  });
}
