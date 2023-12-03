import 'package:amidral/manager/game_manager.dart';
import 'package:amidral/model/player_model.dart';
import 'package:amidral/model/setting_model.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import 'widgets/game_over_menu.dart';
import 'widgets/hud.dart';
import 'widgets/main_menu.dart';
import 'widgets/pause_menu.dart';
import 'widgets/settings_menu.dart';

GameManager _game = GameManager();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Flame.device.fullScreen();
  await Flame.device.setLandscape();

  await initHive();

  runApp(const App());
}

Future<void> initHive() async {
  // final dir = await getApplicationDocumentsDirectory();
  // Hive.init();

  // Hive.registerAdapter<PlayerModel>(PlayerModelAdapter());
  // Hive.registerAdapter<SettingModel>(SettingModelAdapter());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'T-rex',
      theme: ThemeData(
        fontFamily: 'RobotoMono',
        primaryColor: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: GameWidget(
          loadingBuilder: (_) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          },
          overlayBuilderMap: {
            MainMenu.id: (_, GameManager gameRef) => MainMenu(gameRef),
            Hud.id: (_, GameManager gameRef) => Hud(gameRef),
            SettingsMenu.id: (_, GameManager gameRef) => SettingsMenu(gameRef),
            GameOverMenu.id: (_, GameManager gameRef) => GameOverMenu(gameRef),
            PauseMenu.id: (_, GameManager gameRef) => PauseMenu(gameRef),
          },
          initialActiveOverlays: const [MainMenu.id],
          game: _game,
        ),
      ),
    );
  }
}
