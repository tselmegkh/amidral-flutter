import 'dart:ui';

import 'package:amidral/manager/audio_manager.dart';
import 'package:amidral/widgets/hud.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../manager/game_manager.dart';
import 'main_menu.dart';

class PauseMenu extends StatelessWidget {
  static const id = 'PauseMenu';

  final GameManager gameRef;

  const PauseMenu(this.gameRef, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gameRef.player,
      child: Center(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            color: Colors.black.withAlpha(100),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 100),
                child: Wrap(
                  direction: Axis.vertical,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 10,
                  children: [
                    // Padding(
                    //   padding: const EdgeInsets.all(10),
                    //   child: Selector<PlayerModel, int>(
                    //     selector: (_, playerData) => playerData.currentScore,
                    //     builder: (_, score, __) {
                    //       return Text(
                    //         'Score: $score',
                    //         style: const TextStyle(
                    //             fontSize: 40, color: Colors.white),
                    //       );
                    //     },
                    //   ),
                    // ),
                    ElevatedButton(
                      onPressed: () {
                        gameRef.overlays.remove(PauseMenu.id);
                        gameRef.overlays.add(Hud.id);
                        gameRef.resumeEngine();
                        AudioManager.instance.resumeBgm();
                      },
                      child: const Text(
                        'Үргэлжлүүлэх',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        gameRef.overlays.remove(PauseMenu.id);
                        gameRef.overlays.add(Hud.id);
                        gameRef.resumeEngine();
                        gameRef.reset();
                        gameRef.startGamePlay();
                        AudioManager.instance.resumeBgm();
                      },
                      child: const Text(
                        'Дахин эхлэх',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        gameRef.overlays.remove(PauseMenu.id);
                        gameRef.overlays.add(MainMenu.id);
                        gameRef.resumeEngine();
                        gameRef.reset();
                        AudioManager.instance.resumeBgm();
                      },
                      child: const Text(
                        'Гарах',
                        style: TextStyle(
                          fontSize: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
