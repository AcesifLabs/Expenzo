import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/constants/app_font_size.dart';
import 'package:expense_tracker/core/di/injection_container.dart' as di;
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';

import '../../domain/entities/user_settings.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../widgets/font_size_preview_card.dart';
import '../widgets/settings_choice_tile.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_state_view.dart';
import 'number_format_page.dart';

class FontSizePage extends StatelessWidget {
  const FontSizePage({super.key});

  @override
  Widget build(BuildContext context) {
    // SettingsBloc is an app-wide singleton; `create` would close it on pop.
    return BlocProvider.value(
      value: di.getIt<SettingsBloc>(),
      child: const Scaffold(body: FontSizeView()),
    );
  }
}

/// The four text sizes, with a sample transaction at the current size.
/// The design's Font family section was cut (docs/adr/0011).
class FontSizeView extends StatelessWidget {
  const FontSizeView({super.key});

  Widget _buildBody(BuildContext context, UserSettings settings) {
    final sectionsT = t.settings.fontSize.sections;

    return ListView(
      padding: AppSpacing.pagePadding,
      children: [
        SettingsSection(
          title: sectionsT.preview,
          children: const [
            FontSizePreviewCard(amount: NumberFormatView.previewAmount),
          ],
        ),
        SettingsSection(
          title: sectionsT.fontSize,
          children: [
            for (final size in AppFontSize.values)
              SettingsChoiceTile(
                title: size.displayName,
                subtitle: size.description,
                selected: settings.fontSize == size,
                onTap: () => _onSizeTap(context, size),
              ),
          ],
        ),
      ],
    );
  }

  void _onSizeTap(BuildContext context, AppFontSize size) {
    context.read<SettingsBloc>().add(UpdateFontSize(size));
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: t.settings.fontSize.title,
      leading: const AppBackButton(),
      child: SettingsStateView(builder: _buildBody),
    );
  }
}
