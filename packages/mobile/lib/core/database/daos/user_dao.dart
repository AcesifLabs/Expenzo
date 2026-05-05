import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/users_table.dart';

part 'user_dao.g.dart';

@DriftAccessor(tables: [Users])
class UserDao extends DatabaseAccessor<AppDatabase> with _$UserDaoMixin {
  UserDao(super.db);

  Future<void> upsertUser(UsersCompanion user) async {
    await delete(users).go();
    await into(users).insert(user);
  }

  Future<User?> getActiveUser() {
    return select(users).getSingleOrNull();
  }

  Future<void> clearUser() async {
    await delete(users).go();
  }
}
