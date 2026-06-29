// ignore_for_file: prefer-match-file-name

import 'package:flutter/material.dart';

class SlidePageRoute<T> extends PageRouteBuilder<T> {
  final WidgetBuilder builder;

  static final Animatable<Offset> _slideTween = Tween<Offset>(
    begin: const Offset(1.0, 0.0),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutQuart));

  SlidePageRoute({required this.builder})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) =>
            builder(context),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(_slideTween),
            child: FadeTransition(
              opacity: animation,
              child: RepaintBoundary(child: child),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        maintainState: true,
        opaque: true,
      );
}
