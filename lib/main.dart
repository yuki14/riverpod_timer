import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'timer.dart';

void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    print('building MyHomePage');
    return Scaffold(
      appBar: AppBar(title: Text('My Timer App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Column(
              children: [
                Text('準備中', style: Theme.of(context).textTheme.headline2),
                TimerTextWidget()
              ],
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text('Up', style: Theme.of(context).textTheme.headline2),
                    CountUpTimerTextWidget()
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    Text('Down', style: Theme.of(context).textTheme.headline2),
                    CountDownTimerTextWidget()
                  ],
                )
              ],
            ),
            ButtonsContainer(),
          ],
        ),
      ),
    );
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerModel>(
  (ref) => TimerNotifier(10),
);

final countUpTimerProvider = StateNotifierProvider<TimerNotifier, TimerModel>(
  (ref) => TimerNotifier(0),
);

final countDownTimerProvider = StateNotifierProvider<TimerNotifier, TimerModel>(
  (ref) => TimerNotifier(200),
);

final _timeLeftProvider = Provider<String>((ref) {
  return ref.watch(timerProvider).timeLeft;
});

final timeLeftProvider = Provider<String>((ref) {
  return ref.watch(_timeLeftProvider);
});

final _timeUpProvider = Provider<String>((ref) {
  return ref.watch(countUpTimerProvider).timeLeft;
});

final timeUpProvider = Provider<String>((ref) {
  return ref.watch(_timeUpProvider);
});

final _timeDownProvider = Provider<String>((ref) {
  return ref.watch(countDownTimerProvider).timeLeft;
});

final timeDownProvider = Provider<String>((ref) {
  return ref.watch(_timeDownProvider);
});

class TimerTextWidget extends HookConsumerWidget {
  const TimerTextWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeLeft = ref.watch(timeLeftProvider);
    print('building TimerTextWidget $timeLeft');
    return Text(
      timeLeft,
      style: Theme.of(context).textTheme.headline2,
    );
  }
}

class CountUpTimerTextWidget extends HookConsumerWidget {
  const CountUpTimerTextWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeLeft = ref.watch(timeUpProvider);
    print('building CountUpTimerTextWidget $timeLeft');
    return Text(
      timeLeft,
      style: Theme.of(context).textTheme.headline2,
    );
  }
}

class CountDownTimerTextWidget extends HookConsumerWidget {
  const CountDownTimerTextWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timeLeft = ref.watch(timeDownProvider);
    print('building CountDownTimerTextWidget $timeLeft');
    return Text(
      timeLeft,
      style: Theme.of(context).textTheme.headline2,
    );
  }
}

final _buttonState = Provider<ButtonState>((ref) {
  return ref.watch(timerProvider).buttonState;
});

final buttonProvider = Provider<ButtonState>((ref) {
  return ref.watch(_buttonState);
});

class ButtonsContainer extends HookConsumerWidget {
  const ButtonsContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('building ButtonsContainer');
    final state = ref.watch(buttonProvider);
    if (state == ButtonState.finished) {
      ref.read(countUpTimerProvider.notifier).countUpTimer();
      ref.read(countDownTimerProvider.notifier).countDownTimer();
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (state == ButtonState.initial) ...[
          StartButton(),
        ],
        if (state == ButtonState.started) ...[
          PauseButton(),
          SizedBox(width: 20),
          ResetButton(),
        ],
        if (state == ButtonState.paused) ...[
          StartButton(),
          SizedBox(width: 20),
          ResetButton(),
        ],
        if (state == ButtonState.finished) ...[
          ResetButton(),
        ],
      ],
    );
  }
}

class StartButton extends ConsumerWidget {
  const StartButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () {
        ref.read(timerProvider.notifier).start();
      },
      child: Icon(Icons.play_arrow),
    );
  }
}

class PauseButton extends ConsumerWidget {
  const PauseButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () {
        ref.read(timerProvider.notifier).pause();
      },
      child: Icon(Icons.pause),
    );
  }
}

class ResetButton extends ConsumerWidget {
  const ResetButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () {
        ref.read(timerProvider.notifier).reset();
        ref.read(countUpTimerProvider.notifier).reset();
        ref.read(countDownTimerProvider.notifier).reset();
      },
      child: Icon(Icons.replay),
    );
  }
}
