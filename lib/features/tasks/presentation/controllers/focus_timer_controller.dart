import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

class FocusTimerState {
  final int totalSeconds;
  final int remainingSeconds;
  final bool isRunning;
  final bool showCard;

  const FocusTimerState({
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isRunning,
    required this.showCard,
  });

  FocusTimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
    bool? showCard,
  }) {
    return FocusTimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isRunning: isRunning ?? this.isRunning,
      showCard: showCard ?? this.showCard,
    );
  }
}

class FocusTimerController extends ChangeNotifier {
  Timer? _timer;
  int _totalSeconds = 1500;
  int _remainingSeconds = 1500;
  bool _isRunning = false;
  bool _showCard = false;

  int get totalSeconds => _totalSeconds;
  int get remainingSeconds => _remainingSeconds;
  bool get isRunning => _isRunning;
  bool get showCard => _showCard;

  String get formattedTime {
    final mins = _remainingSeconds ~/ 60;
    final secs = _remainingSeconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  void startTimer(VoidCallback onCompleted) {
    if (_isRunning) return;
    _isRunning = true;
    _showCard = true;
    notifyListeners();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        stopTimer();
        onCompleted();
      }
    });
  }

  void pauseTimer() {
    _timer?.cancel();
    _isRunning = false;
    notifyListeners();
  }

  void resetTimer([int? newSeconds]) {
    _timer?.cancel();
    _isRunning = false;
    if (newSeconds != null) {
      _totalSeconds = newSeconds;
    }
    _remainingSeconds = _totalSeconds;
    notifyListeners();
  }

  void stopTimer() {
    _timer?.cancel();
    _isRunning = false;
    _remainingSeconds = _totalSeconds;
    notifyListeners();
  }

  void toggleCardVisibility() {
    _showCard = !_showCard;
    notifyListeners();
  }

  void hideCard() {
    _showCard = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final focusTimerProvider = ChangeNotifierProvider.autoDispose<FocusTimerController>((ref) {
  return FocusTimerController();
});
