import 'package:flutter/material.dart';
import 'app_page_header.dart';

class AppScaffold extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final List<Widget>? actions;
  final RefreshCallback? onRefresh;
  final Widget? _body;
  final bool _isSlivers;

  const AppScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.actions,
    required Widget child,
    this.onRefresh,
  }) : _body = child,
       _isSlivers = false;

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
