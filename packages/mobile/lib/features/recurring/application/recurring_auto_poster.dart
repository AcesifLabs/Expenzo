import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import '../domain/usecases/post_due_recurring.dart';

Future<void> _noAfterPost() => Future.value();

class RecurringAutoPoster {
  final GetSettings getSettings;
  final PostDueRecurring postDueRecurring;
  final Future<bool> Function() isSignedIn;

  final Future<void> Function() afterPost;

  bool _pulled = false;

  RecurringAutoPoster({
    required this.getSettings,
    required this.postDueRecurring,
    required this.isSignedIn,
    this.afterPost = _noAfterPost,
  });

  Future<bool> isReadyToPost() async {
    if (_pulled) return true;
    try {
      return !await isSignedIn();
    } catch (e, s) {
      appLogger.error('Recurring auto-post: sign-in check failed', e, s);

      return false;
    }
  }

  Future<void> runWhenReady() async {
    if (await isReadyToPost()) await runIfEnabled();
  }

  void resetSession() => _pulled = false;

  Future<void> runAfterSync({required bool pulled}) async {
    if (_pulled || !pulled) return;
    _pulled = true;
    await runIfEnabled();
  }

  Future<void> runIfEnabled() async {
    try {
      final settingsResult = await getSettings(NoParams());
      final settings = settingsResult.fold((failure) {
        appLogger.error('Recurring auto-post: settings: ${failure.message}');

        return null;
      }, (settings) => settings);
      if (settings == null || !settings.recurringAutoCreate) return;

      final result = await postDueRecurring(automatic: true);
      final created = result.fold((failure) {
        appLogger.error('Recurring auto-post failed: ${failure.message}');

        return 0;
      }, (created) => created);

      if (created > 0) await afterPost();
    } catch (e, s) {
      appLogger.error('Recurring auto-post failed', e, s);
    }
  }
}
