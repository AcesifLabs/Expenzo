import 'package:flutter/material.dart';

/// A drop-in replacement for [IndexedStack] that lazily builds its children.
///
/// Unlike [IndexedStack], which builds ALL children on first frame,
/// this widget only builds a child when the user navigates to it.
/// Once built, the child is cached and kept in memory (like IndexedStack).
///
/// This dramatically reduces startup time on low-end devices by preventing
/// all 4 bottom-navigation pages from being constructed simultaneously.
class LazyIndexedStack extends StatefulWidget {
  final int index;
  final List<Widget> children;
  final AlignmentGeometry alignment;

  const LazyIndexedStack({
    super.key,
    required this.index,
    required this.children,
    this.alignment = AlignmentDirectional.topStart,
  });

  @override
  State<LazyIndexedStack> createState() => _LazyIndexedStackState();
}

class _LazyIndexedStackState extends State<LazyIndexedStack> {
  /// Tracks which indices have been activated (built) at least once.
  late final List<bool> _activated;

  @override
  void initState() {
    super.initState();
    _activated = List.filled(widget.children.length, false);
    _activated[widget.index] = true;
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      _activated[widget.index] = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: widget.alignment,
      children: List.generate(widget.children.length, (i) {
        // Only render activated children; invisible children are Offstage
        return Offstage(
          offstage: i != widget.index,
          child: _activated[i] ? widget.children[i] : const SizedBox.shrink(),
        );
      }),
    );
  }
}
