import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:expense_tracker/core/database/app_database.dart';
import 'package:expense_tracker/core/di/parsing_module.dart';
import 'package:expense_tracker/features/parsing_rules/presentation/bloc/parsing_rules_bloc.dart';

void main() {
  test('Settings → Matching rules can build its bloc from DI', () async {
    final getIt = GetIt.asNewInstance();
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    getIt.registerSingleton<AppDatabase>(db);
    initParsingModule(getIt);

    final bloc = getIt<ParsingRulesBloc>();
    expect(bloc, isA<ParsingRulesBloc>());

    await bloc.close();
    await db.close();
    await getIt.reset();
  });
}
