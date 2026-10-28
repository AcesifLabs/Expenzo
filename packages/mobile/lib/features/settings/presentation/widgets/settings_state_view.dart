import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:picons/picons.dart';

import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_empty_state.dart';

import '../../domain/entities/user_settings.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsStateView extends StatefulWidget {
  static void showSaveFailed(BuildContext context, SettingsState state) {
    if (state is! SettingsError) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(state.message)));
  }

  final Widget Function(BuildContext context, UserSettings settings) builder;

  const SettingsStateView({super.key, required this.builder});

  @override
  State<SettingsStateView> createState() => _SettingsStateViewState();
}

class _SettingsStateViewState extends State<SettingsStateView> {
  UserSettings? _lastLoaded;

  @override
  void initState() {
    super.initState();
    final state = context.read<SettingsBloc>().state;
    if (state is SettingsLoaded) _lastLoaded = state.settings;
  }

  void _onStateChanged(BuildContext context, SettingsState state) {
    if (state is SettingsLoaded) {
      _lastLoaded = state.settings;
    } else if (_lastLoaded != null) {
      SettingsStateView.showSaveFailed(context, state);
    }
  }

  void _retry() => context.read<SettingsBloc>().add(const LoadSettings());

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listenWhen: (_, s) => s is SettingsLoaded || s is SettingsError,
      listener: _onStateChanged,

      buildWhen: (_, s) => s is! SettingsLoading || _lastLoaded == null,
      builder: (context, state) {
        final settings = state is SettingsLoaded ? state.settings : _lastLoaded;
        if (settings != null) return widget.builder(context, settings);

        if (state is! SettingsInitial && state is! SettingsLoading) {
          return AppEmptyState(
            icon: PiconsRegular.warningCircle,
            message: t.settings.loadFailed,
            actionLabel: t.common.tryAgain,
            onAction: _retry,
          );
        }

        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
