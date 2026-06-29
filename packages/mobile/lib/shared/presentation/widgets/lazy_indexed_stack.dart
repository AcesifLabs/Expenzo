import 'package:flutter/material.dart';

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
  List<bool> _activated = [];

  @override
  void initState() {
    super.initState();
    _activated = List.filled(widget.children.length, false);
    if (widget.index >= 0 && widget.index < _activated.length) {
      _activated[widget.index] = true;
    }
  }

  Widget _buildOffstage(int i) {
    return Offstage(
      offstage: i != widget.index,
      child: _activated[i] ? widget.children[i] : const SizedBox.shrink(),
    );
  }

  @override
  void didUpdateWidget(LazyIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.index != oldWidget.index) {
      if (widget.index >= 0 && widget.index < _activated.length) {
        _activated[widget.index] = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: widget.alignment,
      children: List.generate(widget.children.length, _buildOffstage),
    );
  }
}
