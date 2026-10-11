import 'package:expense_tracker/core/error/usecase.dart';
import 'package:expense_tracker/core/logger/app_logger.dart';
import 'package:expense_tracker/features/settings/domain/usecases/get_settings.dart';
import '../domain/usecases/post_due_recurring.dart';

/// Posts due recurring items when the user turned on Auto-create.
///
/// A signed-in device waits for its first successful pull of the session:
/// before it, the device may hold dates another phone already moved forward,
/// and would post those occurrences a second time. Never throws and never
/// shows UI.
class RecurringAutoPoster {
  final GetSettings getSettings;
  final PostDueRecurring postDueRecurring;
  final Future<bool> Function() isSignedIn;

  /// Runs after at least one Record was posted, e.g. budget alerts.
  final Future<void> Function()? afterPost;

  /// Set by the session's first successful pull; cleared on sign-out.
  bool _pulled = false;

  RecurringAutoPoster({
    required this.getSettings,
    required this.postDueRecurring,
    required this.isSignedIn,
    this.afterPost,
  });

  /// True when posting cannot repeat another device's work: signed out, or
  /// signed in and pulled this session.
  Future<bool> isReadyToPost() async {
    if (_pulled) return true;
    try {
      return !await isSignedIn();
    } catch (e, s) {
      appLogger.error('Recurring auto-post: sign-in check failed', e, s);

      return false;
    }
  }

  /// App open or resume. Signed in before the first pull, the after-sync hook
  /// posts instead.
  Future<void> runWhenReady() async {
    if (await isReadyToPost()) await runIfEnabled();
  }

  /// The sync engine stopped (sign-out): the next account must pull again
  /// before anything posts.
  void resetSession() => _pulled = false;

  /// After a sync cycle; posts once, after the session's first successful
  /// pull. A failed pull leaves the local dates unchecked, so it waits.
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

      final onPosted = afterPost;
      if (created > 0 && onPosted != null) await onPosted();
    } catch (e, s) {
      appLogger.error('Recurring auto-post failed', e, s);
    }
  }
}
