import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

class UFO extends SpriteComponent with Tappable {
  final VoidCallback onTap;

  UFO({required Vector2 position, required this.onTap})
      : super(
          size: Vector2(64, 64),
          position: position,
        );

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load('ufo.png'); // 確保有 ufo.png 圖片
  }

  @override
  bool onTapDown(TapDownInfo event) {
    onTap();
    return true;
  }
}
