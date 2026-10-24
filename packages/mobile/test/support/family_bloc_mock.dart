import 'package:expense_tracker/features/family/presentation/bloc/family_bloc.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_event.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_state.dart';
import 'package:mocktail/mocktail.dart';

import 'core_screens.dart';

class MockFamilyBloc extends Mock implements FamilyBloc {}

/// Call once from `setUpAll` in tests that verify `add`. FamilyEvent is
/// sealed, so a real event stands in for `any()`.
void registerFamilyEventFallback() =>
    registerFallbackValue(const FamilyFailureCleared());

/// A [FamilyBloc] stuck in [state] that records `add` calls.
MockFamilyBloc familyBlocWith(FamilyState state) {
  final bloc = mockBloc<MockFamilyBloc, FamilyState>(MockFamilyBloc(), state);
  when(() => bloc.add(any())).thenReturn(null);

  return bloc;
}
