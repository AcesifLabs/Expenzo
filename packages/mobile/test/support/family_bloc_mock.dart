import 'package:expense_tracker/features/family/presentation/bloc/family_bloc.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_event.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_state.dart';
import 'package:mocktail/mocktail.dart';

import 'core_screens.dart';

class MockFamilyBloc extends Mock implements FamilyBloc {}

void registerFamilyEventFallback() =>
    registerFallbackValue(const FamilyFailureCleared());

MockFamilyBloc familyBlocWith(FamilyState state) {
  final bloc = mockBloc<MockFamilyBloc, FamilyState>(MockFamilyBloc(), state);
  when(() => bloc.add(any())).thenReturn(null);

  return bloc;
}
