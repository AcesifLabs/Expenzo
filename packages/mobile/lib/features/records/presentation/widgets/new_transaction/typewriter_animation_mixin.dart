import 'dart:async';
import 'package:flutter/material.dart';

mixin TypewriterAnimationMixin<T extends StatefulWidget>
    on State<T>, TickerProviderStateMixin<T> {
  Timer? _typewriterTimer;
  int _twPhraseIndex = 0;
  int _twCharIndex = 0;
  String _twDisplayText = '';
  bool _twIsErasing = false;
  bool _twIsPaused = false;
  List<String> _twPhrases = [];

  void initTypewriter(List<String> phrases) {
    _twPhrases = phrases;
  }

  void startTypewriter() {
    stopTypewriter();
    _twPhraseIndex = 0;
    _twCharIndex = 0;
    _twDisplayText = '';
    _twIsErasing = false;
    _tickTypewriter();
  }

  void stopTypewriter() {
    _typewriterTimer?.cancel();
    _typewriterTimer = null;
  }

  void pauseTypewriter() {
    if (!_twIsPaused) {
      _twIsPaused = true;
      stopTypewriter();
      setState(() => _twDisplayText = '');
    }
  }

  void resumeTypewriter() {
    if (_twIsPaused) {
      _twIsPaused = false;
      startTypewriter();
    }
  }

  String get typewriterDisplayText => _twDisplayText;

  bool get isTypewriterPaused => _twIsPaused;

  void _tickTypewriter() {
    if (_twIsPaused || !mounted) return;

    if (_twPhrases.isEmpty) return;

    final currentPhrase = _twPhrases[_twPhraseIndex % _twPhrases.length];

    if (!_twIsErasing) {
      if (_twCharIndex < currentPhrase.length) {
        _twCharIndex++;
        _twDisplayText = currentPhrase.substring(0, _twCharIndex);
        setState(() {});
        _typewriterTimer = Timer(
          const Duration(milliseconds: 80),
          _tickTypewriter,
        );
      } else {
        _typewriterTimer = Timer(const Duration(seconds: 2), () {
          if (!_twIsPaused && mounted) {
            _twIsErasing = true;
            _tickTypewriter();
          }
        });
      }
    } else {
      if (_twCharIndex > 0) {
        _twCharIndex--;
        _twDisplayText = currentPhrase.substring(0, _twCharIndex);
        setState(() {});
        _typewriterTimer = Timer(
          const Duration(milliseconds: 40),
          _tickTypewriter,
        );
      } else {
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
