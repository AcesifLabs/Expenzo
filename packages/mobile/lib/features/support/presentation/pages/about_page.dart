import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_palette.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_back_button.dart';
import 'package:expense_tracker/shared/presentation/widgets/app_scaffold.dart';

import '../../domain/app_version.dart';

class AboutPage extends StatefulWidget {
  final PackageInfoLoader? loadInfo;

  const AboutPage({super.key, this.loadInfo});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  Future<AppVersion>? _version;

  @override
  void initState() {
    super.initState();
    final load = widget.loadInfo;
    _version = load == null ? loadAppVersion() : loadAppVersion(load: load);
  }

  Widget _versionLine(BuildContext context, AsyncSnapshot<AppVersion> snap) {
    final version = snap.data;
    if (version == null || version.isUnknown) return const SizedBox.shrink();

    return Text(
      t.support.about.version(version: version.version, build: version.build),
      textAlign: TextAlign.center,
      style: Theme.of(
        context,
      ).textTheme.bodyMedium?.copyWith(color: context.palette.textSecondary),
    );
  }

  @override
  Widget build(BuildContext context) {
    final aboutT = t.support.about;
    final textTheme = Theme.of(context).textTheme;
    final secondary = context.palette.textSecondary;

    return Scaffold(
      body: AppScaffold(
        title: aboutT.title,
        leading: const AppBackButton(),
        child: ListView(
          padding: AppSpacing.pagePadding,
          children: [
            const SizedBox(height: AppSpacing.xl),
            Center(
              child: Image.asset(
                'assets/images/logo.png',
                width: 72,
                excludeFromSemantics: true,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              t.common.appName,
              textAlign: TextAlign.center,
              style: textTheme.headlineMedium,
            ),
            const SizedBox(height: AppSpacing.xs),
            FutureBuilder<AppVersion>(future: _version, builder: _versionLine),
            const SizedBox(height: AppSpacing.lg),
            Text(
              aboutT.description,
              textAlign: TextAlign.center,
              style: textTheme.bodyLarge,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              aboutT.madeBy,
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(color: secondary),
            ),
            const SizedBox(height: AppSpacing.lg),
          ],
        ),
      ),
    );
  }
}
