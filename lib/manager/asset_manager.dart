import 'package:amidral/constant/animation_state.dart';
import 'package:flame/components.dart';

class AssetManager {
  static const images = [
    'DinoSprites - tard.png',
    'Rino/questio.png',
    'parallax/plx-1.png',
    'parallax/plx-2.png',
    'parallax/plx-3.png',
    'parallax/plx-4.png',
    'parallax/plx-5.png',
    'parallax/plx-6.png',
  ];

  static const audios = [
    '8BitPlatformerLoop.wav',
    'hurt7.wav',
    'jump14.wav',
  ];

  static const background = [
    'parallax/background3.jpeg',
  ];

  static final animation = {
    TRexAnimationState.idle: SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
    ),
    TRexAnimationState.run: SpriteAnimationData.sequenced(
      amount: 6,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4) * 24, 0),
    ),
    TRexAnimationState.kick: SpriteAnimationData.sequenced(
      amount: 4,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4 + 6) * 24, 0),
    ),
    TRexAnimationState.hit: SpriteAnimationData.sequenced(
      amount: 3,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4 + 6 + 4) * 24, 0),
    ),
    TRexAnimationState.sprint: SpriteAnimationData.sequenced(
      amount: 7,
      stepTime: 0.1,
      textureSize: Vector2.all(24),
      texturePosition: Vector2((4 + 6 + 4 + 3) * 24, 0),
    ),
  };
}
