import 'package:amidral/components/t_rex_component.dart';
import 'package:amidral/manager/asset_manager.dart';
import 'package:amidral/manager/audio_manager.dart';
import 'package:amidral/model/player_model.dart';
import 'package:amidral/model/setting_model.dart';
import 'package:flame/camera.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../constant/constants.dart';
import '../widgets/game_over_menu.dart';
import '../widgets/hud.dart';
import '../widgets/pause_menu.dart';
import 'enemy_manager.dart';

class GameManager extends FlameGame with TapDetector, HasCollisionDetection {
  late TRexComponent _trex;
  late EnemyManager _enemyManager;

  PlayerModel player = PlayerModel();
  SettingModel setting = SettingModel();
  static final GameManager _instance = GameManager._internal();

  GameManager._internal();

  factory GameManager() => _instance;
  @override
  Future<void>? onLoad() async {
    // player = await _readPlayerData();
    // setting = await _readSettings();

    await AudioManager.instance.init(AssetManager.audios, setting);
    AudioManager.instance.startBgm();
    await images.loadAll(AssetManager.images);

    camera.viewport = FixedResolutionViewport(resolution: Vector2(926, 428));

    final parallaxBackground = await loadParallaxComponent(
      AssetManager.background.map((e) => ParallaxImageData(e)).toList(),
      baseVelocity: Vector2(20, 100),
      velocityMultiplierDelta: Vector2(2, 0),
    );

    add(parallaxBackground);

    return super.onLoad();
  }

  void startGamePlay() {
    _trex = TRexComponent(images.fromCache('DinoSprites - tard.png'), player);
    _enemyManager = EnemyManager();

    add(_trex);
    add(_enemyManager);
  }

  @override
  void update(double dt) {
    if (player.lives <= 0) {
      overlays.add(GameOverMenu.id);
      overlays.remove(Hud.id);
      pauseEngine();
    }

    super.update(dt);
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (overlays.isActive(Hud.id)) {
      _trex.jump();
    }

    super.onTapDown(info);
  }

  void reset() {
    _trex.removeFromParent();
    _enemyManager.removeAllEnemies();
    _enemyManager.removeFromParent();

    player.currentScore = 0;
    player.lives = 5;
    player.balance = 0;
    player.stockbalance = 0;
    player.familyHayalga = 0;
    player.age = 17;
    player.currentExpenseMonth = 150000;
    player.isUniversity = false;
    player.currentSalaryMonth = 0;
  }

  // Future<PlayerModel> _readPlayerData() async {
  //   final playerDataBox = await Hive.openBox<PlayerModel>(kHivePlayerBox);
  //   final playerData = playerDataBox.get(kHivePlayerData);

  //   if (playerData == null) {
  //     await playerDataBox.put(kHivePlayerData, PlayerModel());
  //   }
  //   return playerDataBox.get(kHivePlayerData)!;
  // }

  // Future<SettingModel> _readSettings() async {
  //   final settingBox = await Hive.openBox<SettingModel>(kHiveSettingsBox);
  //   final settings = settingBox.get(kHiveSettingsData);

  //   if (settings == null) {
  //     await settingBox.put(kHiveSettingsData, SettingModel());
  //   }

  //   return settingBox.get(kHiveSettingsData)!;
  // }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!(overlays.isActive(PauseMenu.id)) &&
            !(overlays.isActive(GameOverMenu.id))) {
          resumeEngine();
        }
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        if (overlays.isActive(Hud.id)) {
          overlays.remove(Hud.id);
          overlays.add(PauseMenu.id);
        }
        pauseEngine();
        break;
      default:
        break;
    }
    super.lifecycleStateChange(state);
  }
}
