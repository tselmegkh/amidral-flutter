import 'dart:developer' as developer;
import 'dart:math';

import 'package:amidral/components/enemy_component.dart';
import 'package:amidral/constant/constants.dart';
import 'package:amidral/manager/game_manager.dart';
import 'package:amidral/model/enemy_model.dart';
import 'package:flame/components.dart';

class EnemyManager extends Component with HasGameRef<GameManager> {
  final List<EnemyModel> _data = [];

  final Random _random = Random();

  final Timer _timer = Timer(3, repeat: true);
  EnemyManager() {
    _timer.onTick = spawnRandomEnemy;
  }

  void spawnRandomEnemy() {
    int randomIndex = _random.nextInt(_data.length);
    final enemyData = _data.elementAt(randomIndex);
    final enemy = EnemyComponent(enemyData);

    developer.log("SPAWN ENEMY ${enemy.toString()}");

    enemy.anchor = Anchor.bottomLeft;
    enemy.position = Vector2(gameRef.size.x + 32, kTRexDefaultY);

    if (enemyData.canFly) {
      final newHeight = _random.nextDouble() * 2 * enemyData.textureSize.y;
      enemy.position.y -= newHeight;
    }

    enemy.size = enemyData.textureSize;

    gameRef.add(enemy);
  }

  @override
  void onMount() {
    if (isMounted) {
      removeFromParent();
    }

    if (_data.isEmpty) {
      _data.addAll(
        [
          EnemyModel(
            image: gameRef.images.fromCache('Rino/questio.png'),
            numOfFrames: 6,
            stepTime: 0.09,
            textureSize: Vector2(52, 34),
            speedX: 300,
            canFly: false,
          ),
        ],
      );
    }

    _timer.start();

    super.onMount();
  }

  @override
  void update(double dt) {
    _timer.update(dt);

    super.update(dt);
  }

  void removeAllEnemies() {
    final enemies = gameRef.children.whereType<EnemyComponent>();
    for (var enemy in enemies) {
      enemy.removeFromParent();
    }
  }
}
