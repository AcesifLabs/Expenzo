import 'package:flutter/material.dart';
import 'app_page_header.dart';

/// Consistent page wrapper with header and scroll behavior.
///
/// Two usage patterns:
///
/// **Sliver layout** (Dashboard, Budgets):
/// ```dart
/// AppScaffold.slivers(
///   title: 'Home',
///   slivers: [SliverToBoxAdapter(child: ...)],
///   onRefresh: () async { ... },
/// )
/// ```
///
/// **Custom child layout** (Activity with search bar + list):
/// ```dart
/// AppScaffold(
///   title: 'Activity',
///   actions: [...],
///   child: Column(children: [...]),
///   onRefresh: () async { ... },
/// )
/// ```
class AppScaffold extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final Widget? _body;
  final bool _isSlivers;
  final RefreshCallback? onRefresh;

  /// Custom child mode: header is added automatically.
  const AppScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    required Widget child,
    this.onRefresh,
  }) : _body = child,
       _isSlivers = false;

  /// Sliver mode: user provides slivers, header is first sliver automatically.
  AppScaffold.slivers({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    required List<Widget> slivers,
    this.onRefresh,
  }) : _body = _SliverBody(
         title: title,
         subtitle: subtitle,
         actions: actions,
         slivers: slivers,
       ),
       _isSlivers = true;

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_isSlivers) {
      // _SliverBody already includes AppPageHeader
      content = _body!;
    } else {
      // Regular mode: header + child
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPageHeader(
            title: title ?? '',
            subtitle: subtitle,
            actions: actions,
          ),
          Expanded(child: _body ?? const SizedBox.shrink()),
        ],
      );
    }

    if (onRefresh != null) {
      content = RefreshIndicator(onRefresh: onRefresh!, child: content);
    }

    return Material(type: MaterialType.transparency, child: content);
  }
}

class _SliverBody extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final List<Widget> slivers;

  const _SliverBody({
    required this.title,
    this.subtitle,
    this.actions,
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
          ),
        ),
        ...slivers,
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}
