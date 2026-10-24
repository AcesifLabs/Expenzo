import 'package:expense_tracker/core/api/api_client.dart';
import 'package:expense_tracker/core/database/daos/budget_dao.dart';
import 'package:expense_tracker/core/database/daos/sync_queue_dao.dart';
import 'package:expense_tracker/features/family/data/datasources/family_local_datasource.dart';
import 'package:expense_tracker/features/family/data/datasources/family_remote_datasource.dart';
import 'package:expense_tracker/features/family/data/repositories/family_repository_impl.dart';
import 'package:expense_tracker/features/family/data/services/group_refresh_policy.dart';
import 'package:expense_tracker/features/family/data/services/shared_budget_cleanup.dart';
import 'package:expense_tracker/features/family/domain/repositories/family_repository.dart';
import 'package:expense_tracker/features/family/domain/services/budget_access.dart';
import 'package:expense_tracker/features/family/domain/usecases/create_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/create_invite.dart';
import 'package:expense_tracker/features/family/domain/usecases/delete_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/get_group_summary.dart';
import 'package:expense_tracker/features/family/domain/usecases/get_my_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/join_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/leave_group.dart';
import 'package:expense_tracker/features/family/domain/usecases/remove_member.dart';
import 'package:expense_tracker/features/family/domain/usecases/update_member_role.dart';
import 'package:expense_tracker/features/family/presentation/bloc/family_bloc.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import 'package:expense_tracker/features/sync/domain/usecases/sync_now.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Family Group (SAAP-75). Everything is lazy, so nothing touches the
/// network or SharedPreferences at startup.
void initFamilyModule(GetIt getIt) {
  getIt.registerLazySingleton<FamilyRemoteDatasource>(
    () => FamilyRemoteDatasourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton(
    () => FamilyLocalDatasource(
      prefs: getIt<SharedPreferences>(),
      currentUserId: () => getIt<FirebaseAuth>().currentUser?.uid,
    ),
  );
  getIt.registerLazySingleton(
    () => SharedBudgetCleanup(
      budgetDao: getIt<BudgetDao>(),
      syncQueueDao: getIt<SyncQueueDao>(),
    ),
  );
  getIt.registerLazySingleton<FamilyRepository>(
    () => FamilyRepositoryImpl(
      remote: getIt<FamilyRemoteDatasource>(),
      local: getIt<FamilyLocalDatasource>(),
      onGroupFetched: getIt<SharedBudgetCleanup>().apply,
    ),
  );
  getIt.registerLazySingleton(
    () =>
        BudgetAccess(currentGroup: () => getIt<FamilyRepository>().cachedGroup),
  );
  getIt.registerLazySingleton(() => GetMyGroup(getIt<FamilyRepository>()));
  getIt.registerLazySingleton(() => GetGroupSummary(getIt<FamilyRepository>()));
  getIt.registerLazySingleton(() => CreateGroup(getIt<FamilyRepository>()));
  getIt.registerLazySingleton(() => JoinGroup(getIt<FamilyRepository>()));
  getIt.registerLazySingleton(() => CreateInvite(getIt<FamilyRepository>()));
  getIt.registerLazySingleton(
    () => UpdateMemberRole(getIt<FamilyRepository>()),
  );
  getIt.registerLazySingleton(() => RemoveMember(getIt<FamilyRepository>()));
  getIt.registerLazySingleton(() => LeaveGroup(getIt<FamilyRepository>()));
  getIt.registerLazySingleton(() => DeleteGroup(getIt<FamilyRepository>()));
  // A factory: each Family route creates its own bloc.
  getIt.registerFactory(
    () => FamilyBloc(
      getMyGroup: getIt<GetMyGroup>(),
      getGroupSummary: getIt<GetGroupSummary>(),
      createGroup: getIt<CreateGroup>(),
      joinGroup: getIt<JoinGroup>(),
      createInvite: getIt<CreateInvite>(),
      updateMemberRole: getIt<UpdateMemberRole>(),
      removeMember: getIt<RemoveMember>(),
      leaveGroup: getIt<LeaveGroup>(),
      deleteGroup: getIt<DeleteGroup>(),
      getSettings: getIt<GetSettings>(),
      syncNow: getIt<SyncNow>(),
    ),
  );
  // Run by SyncEngine after each sync cycle (see injection_container).
  getIt.registerLazySingleton(
    () => GroupRefreshPolicy(
      cachedGroup: () => getIt<FamilyRepository>().cachedGroup,
      budgetDao: getIt<BudgetDao>(),
      getMyGroup: getIt<GetMyGroup>(),
    ),
  );
}
