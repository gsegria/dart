import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/tap_game.dart';

void main() {
  runApp(
    GameWidget(
      game: TapGame(),
      overlayBuilderMap: {
        'GameOver': (context, game) {
          final tapGame = game as TapGame;
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("遊戲結束！", style: TextStyle(fontSize: 32)),
                Text("得分: ${tapGame.score}", style: TextStyle(fontSize: 24)),
                ElevatedButton(
                  child: Text("再玩一次"),
                  onPressed: () {
                    tapGame.reset();
                    game.overlays.remove('GameOver');
                  },
                )
              ],
            ),
          );
        }
      },
    ),
  );
}
