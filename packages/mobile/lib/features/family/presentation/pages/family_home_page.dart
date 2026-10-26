import 'package:expense_tracker/core/router/family_route.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/core/error/failure_message.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_error_state.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';
import 'package:expense_tracker/shared/presentation/widgets/offline_gate.dart';
import 'package:expense_tracker/shared/presentation/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:picons/picons.dart';

import '../bloc/family_bloc.dart';
import '../bloc/family_event.dart';
import '../bloc/family_state.dart';
import '../helpers/family_failure_listener.dart';
import '../widgets/family_create_group_view.dart';
import '../widgets/family_dashboard_view.dart';

class FamilyHomePage extends StatelessWidget {
  const FamilyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<FamilyBloc, FamilyState>(
      listenWhen: familyStateNeedsListener,
      listener: handleFamilyState,
      builder: (context, state) {
        final group = state.myGroup;
        final loading =
            state.group == null &&
            (state.status == FamilyStatus.initial ||
                state.status == FamilyStatus.loading);

        return Scaffold(
          body: AppScaffold(
            title: group?.group.name ?? t.family.create.title,
            leading: const AppBackButton(),
            actions: [
              if (group != null)
                IconButton(
                  icon: const Icon(PiconsRegular.gear),
                  tooltip: t.family.dashboard.manageMembers,
                  onPressed: () => context.push(FamilyRoute.members.location),
                ),
            ],
            onRefresh: group == null ? null : () => _refresh(context),
            child: _buildBody(context, state, loading: loading),
          ),
        );
      },
    );
  }
}

Future<void> _refresh(BuildContext context) async {
  final bloc = context.read<FamilyBloc>()..add(const FamilyRefreshRequested());
  await bloc.stream.firstWhere((state) => !state.busy);
}

Widget _buildBody(
  BuildContext context,
  FamilyState state, {
  required bool loading,
}) {
  final group = state.myGroup;
  if (loading) return const _FamilyLoading();
  if (group != null) return FamilyDashboardView(state: state, group: group);
  if (state.status == FamilyStatus.failure) {
    final failure = state.failure;

    return AppErrorState(
      message: failure != null
          ? failureText(failure)
          : t.family.dashboard.loadFailed,
      onRetry: () =>
          context.read<FamilyBloc>().add(const FamilyRefreshRequested()),
    );
  }

  return const OfflineGate(child: FamilyCreateGroupView());
}

class _FamilyLoading extends StatelessWidget {
  const _FamilyLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        for (final height in const [140.0, 72.0, 72.0])
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: ShimmerBox(
              child: ShimmerBox.rectangle(
                width: double.infinity,
                height: height,
                borderRadius: AppSpacing.radiusCard,
              ),
            ),
          ),
      ],
    );
  }
}
