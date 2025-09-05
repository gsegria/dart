import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../components/ufo.dart';
import 'dart:math';

class TapGame extends FlameGame with HasTappables {
  late Timer countdownTimer;
  int timeLeft = 30;
  int score = 0;
  Random random = Random();

  @override
  Future<void> onLoad() async {
    spawnUFO();
    startTimer();
  }

  void spawnUFO() {
    final ufo = UFO(
      position: Vector2(
        random.nextDouble() * (size.x - 64),
        random.nextDouble() * (size.y - 64),
      ),
      onTap: () {
        score++;
        remove(ufo);
        spawnUFO();
      },
    );
    add(ufo);
  }

  void startTimer() {
    countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      timeLeft--;
      if (timeLeft <= 0) {
        timer.cancel();
        gameOver();
      }
    });
  }

  void gameOver() {
    overlays.add('GameOver');
    children.whereType<UFO>().forEach(remove);
  }

  void reset() {
    timeLeft = 30;
    score = 0;
    spawnUFO();
    startTimer();
  }
}
