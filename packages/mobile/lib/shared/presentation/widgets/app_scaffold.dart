import 'package:flutter/material.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'app_page_header.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;

  /// Forwarded to [AppPageHeader], e.g. an `AppBackButton` on nested screens.
  final Widget? leading;
  final RefreshCallback? onRefresh;
  final Widget? _body;
  final bool _isSlivers;

  // A page may have no title.
  // ignore: unnecessary-nullable
  const AppScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    required Widget child,
    this.onRefresh,
  }) : _body = child,
       _isSlivers = false;

  AppScaffold.slivers({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    required List<Widget> slivers,
    this.onRefresh,
  }) : _body = _SliverBody(
         title: title,
         subtitle: subtitle,
         actions: actions,
         leading: leading,
         slivers: slivers,
       ),
       _isSlivers = true;

  Widget _buildContent() {
    return _isSlivers
        ? (_body ?? const SizedBox.shrink())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppPageHeader(
                title: title ?? '',
                subtitle: subtitle,
                actions: actions,
                leading: leading,
              ),
              Expanded(child: _body ?? const SizedBox.shrink()),
            ],
          );
  }

  @override
  Widget build(BuildContext context) {
    final localOnRefresh = onRefresh;
    final content = _buildContent();

    if (localOnRefresh != null) {
      return Material(
        type: MaterialType.transparency,
        child: RefreshIndicator(onRefresh: localOnRefresh, child: content),
      );
    }

    return Material(type: MaterialType.transparency, child: content);
  }
}

class _SliverBody extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? leading;
  final List<Widget> slivers;

  const _SliverBody({
    required this.title,
    this.subtitle,
    this.actions,
    this.leading,
    required this.slivers,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: AppPageHeader(
            title: title ?? '',
            subtitle: subtitle,
            actions: actions,
            leading: leading,
          ),
        ),
        ...slivers,
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
      ],
    );
  }
}
