import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

class TimerNotifier extends StateNotifier<TimerModel> {
  TimerNotifier(int initialTime)
      : super(TimerModel(
          _durationString(initialTime),
          ButtonState.initial,
        )) {
    _initialDuration = initialTime;
    _initialState = TimerModel(
      _durationString(initialTime),
      ButtonState.initial,
    );
  }

  late int _initialDuration;
  late TimerModel _initialState;

  final Ticker _ticker = Ticker();
  StreamSubscription<int>? _tickerSubscription;

  static String _durationString(int duration) {
    final minutes = ((duration / 60) % 60).floor().toString().padLeft(2, '0');
    final seconds = (duration % 60).floor().toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void start() {
    if (state.buttonState == ButtonState.paused) {
      _restartTimer();
    } else {
      _startTimer();
    }
  }

  void _restartTimer() {
    _tickerSubscription?.resume();
    state = TimerModel(state.timeLeft, ButtonState.started);
  }

  void _startTimer() {
    _tickerSubscription?.cancel();

    _tickerSubscription =
        _ticker.tick(ticks: _initialDuration).listen((duration) {
      state = TimerModel(_durationString(duration), ButtonState.started);
    });

    _tickerSubscription?.onDone(() {
      state = TimerModel(state.timeLeft, ButtonState.finished);
    });

    state = TimerModel(_durationString(_initialDuration), ButtonState.started);
  }

  void pause() {
    _tickerSubscription?.pause();
    state = TimerModel(state.timeLeft, ButtonState.paused);
  }

  void reset() {
    _tickerSubscription?.cancel();
    state = _initialState;
  }

  void countUpTimer() {
    _tickerSubscription = _ticker.tickUp().listen((duration) {
      state = TimerModel(_durationString(duration), ButtonState.started);
    });
  }

  void countDownTimer() {
    _tickerSubscription =
        _ticker.tick(ticks: _initialDuration).listen((duration) {
      state = TimerModel(_durationString(duration), ButtonState.started);
    });
  }

  @override
  void dispose() {
    _tickerSubscription?.cancel();
    super.dispose();
  }
}

class Ticker {
  Stream<int> tick({required int ticks}) {
    return Stream.periodic(
      Duration(seconds: 1),
      (x) => ticks - x - 1,
    ).take(ticks);
  }

  Stream<int> tickUp() {
    return Stream.periodic(
      Duration(seconds: 1),
      (x) => x + 1,
    );
  }
}

class TimerModel {
  const TimerModel(this.timeLeft, this.buttonState);
  final String timeLeft;
  final ButtonState buttonState;
}

enum ButtonState {
  initial,
  started,
  paused,
  finished,
}
