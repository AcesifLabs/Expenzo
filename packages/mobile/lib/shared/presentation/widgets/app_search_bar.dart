import 'package:flutter/material.dart';
import 'package:picons/picons.dart';
import 'package:expense_tracker/core/theme/app_typography.dart';
import 'package:expense_tracker/core/theme/app_spacing.dart';
import 'package:expense_tracker/i18n/strings.g.dart';

class AppSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  final String? hintText;
  final FocusNode? focusNode;

  const AppSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText,
    this.focusNode,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _hasText = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onControllerChanged);
  }

  void _onClearPressed() {
    widget.controller.clear();
    widget.onChanged('');
  }

  void _onControllerChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  @override
  void didUpdateWidget(AppSearchBar old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final mutedColor = colors.onSurface.withAlpha(80);

    return Padding(
      padding: EdgeInsets.zero,
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        onChanged: widget.onChanged,
        decoration: InputDecoration(
          hintText: widget.hintText ?? t.common.search,
          hintStyle: TextStyle(color: mutedColor),
          prefixIcon: Icon(
            PiconsRegular.magnifyingGlass,
            color: mutedColor,
            size: 20,
          ),
          suffixIcon: _hasText
              ? IconButton(
                  icon: const Icon(PiconsRegular.x, size: 18),
                  tooltip: t.common.clearSearch,
                  onPressed: _onClearPressed,
                )
              : null,
          filled: true,
          fillColor: colors.onSurface.withAlpha(10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusControl),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.smd,
          ),
        ),
        style: AppTypography.bodyLarge.copyWith(color: colors.onSurface),
      ),
    );
  }
}
