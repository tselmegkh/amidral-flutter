import 'package:amidral/model/enemy_model.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import '../manager/game_manager.dart';

class EnemyComponent extends SpriteComponent
    with CollisionCallbacks, HasGameRef<GameManager> {
  final EnemyModel enemy;

  EnemyComponent(this.enemy) {
    init();
  }

  void init() {
    sprite = Sprite(enemy.image);
  }

  @override
  void onMount() {
    add(
      RectangleHitbox.relative(
        Vector2.all(0.8),
        parentSize: size,
        position: Vector2(size.x * 0.5, size.y * 0.3) / 2,
      ),
    );

    super.onMount();
  }

  @override
  void update(double dt) {
    position.x = position.x - enemy.speedX * dt;

    if (position.x < -enemy.textureSize.x) {
      removeFromParent();
      gameRef.player.currentScore += 1;
    }

    super.update(dt);
  }
}
