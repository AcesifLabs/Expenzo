import 'dart:async';
import 'package:flutter/material.dart';

/// Mixin that provides typewriter animation functionality for text placeholders.
/// Used in NewTransactionSheet to animate placeholder text.
mixin TypewriterAnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  Timer? _typewriterTimer;
  int _twPhraseIndex = 0;
  int _twCharIndex = 0;
  String _twDisplayText = '';
  bool _twIsErasing = false;
  bool _twIsPaused = false;
  List<String> _twPhrases = [];

  /// Initialize the typewriter with phrases to animate.
  void initTypewriter(List<String> phrases) {
    _twPhrases = phrases;
  }

  /// Start the typewriter animation from the beginning.
  void startTypewriter() {
    stopTypewriter();
    _twPhraseIndex = 0;
    _twCharIndex = 0;
    _twDisplayText = '';
    _twIsErasing = false;
    _tickTypewriter();
  }

  /// Stop the typewriter animation.
  void stopTypewriter() {
    _typewriterTimer?.cancel();
    _typewriterTimer = null;
  }

  /// Pause the typewriter (e.g., when user starts typing).
  void pauseTypewriter() {
    if (!_twIsPaused) {
      _twIsPaused = true;
      stopTypewriter();
      setState(() => _twDisplayText = '');
    }
  }

  /// Resume the typewriter (e.g., when user clears the text field).
  void resumeTypewriter() {
    if (_twIsPaused) {
      _twIsPaused = false;
      startTypewriter();
    }
  }

  /// Get the current display text for the hint/placeholder.
  String get typewriterDisplayText => _twDisplayText;

  /// Whether the typewriter is currently paused.
  bool get isTypewriterPaused => _twIsPaused;

  void _tickTypewriter() {
    if (_twIsPaused || !mounted) return;

    if (_twPhrases.isEmpty) return;

    final currentPhrase = _twPhrases[_twPhraseIndex % _twPhrases.length];

    if (!_twIsErasing) {
      // Typing phase
      if (_twCharIndex < currentPhrase.length) {
        _twCharIndex++;
        _twDisplayText = currentPhrase.substring(0, _twCharIndex);
        setState(() {});
        _typewriterTimer = Timer(
          const Duration(milliseconds: 80),
          _tickTypewriter,
        );
      } else {
        // Phrase complete — pause 2 seconds, then erase
        _typewriterTimer = Timer(const Duration(seconds: 2), () {
          if (!_twIsPaused && mounted) {
            _twIsErasing = true;
            _tickTypewriter();
          }
        });
      }
    } else {
      // Erasing phase
      if (_twCharIndex > 0) {
        _twCharIndex--;
        _twDisplayText = currentPhrase.substring(0, _twCharIndex);
        setState(() {});
        _typewriterTimer = Timer(
          const Duration(milliseconds: 40),
          _tickTypewriter,
        );
      } else {
        // Fully erased — next phrase after brief gap
        _twIsErasing = false;
        _twPhraseIndex = (_twPhraseIndex + 1) % _twPhrases.length;
        _twCharIndex = 0;
        _twDisplayText = '';
        setState(() {});
        _typewriterTimer = Timer(const Duration(milliseconds: 300), () {
          if (!_twIsPaused && mounted) {
            _tickTypewriter();
          }
        });
      }
    }
  }

  @override
  void dispose() {
    stopTypewriter();
    super.dispose();
  }
}
