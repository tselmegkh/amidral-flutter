import 'dart:math';

import 'package:amidral/widgets/qa_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../manager/audio_manager.dart';
import '../manager/game_manager.dart';
import '../model/player_model.dart';
import 'pause_menu.dart';

class Hud extends StatelessWidget {
  static const id = 'Hud';

  final GameManager gameRef;

  const Hud(this.gameRef, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gameRef.player,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  TextButton(
                    onPressed: () {
                      gameRef.overlays.remove(Hud.id);
                      gameRef.overlays.add(PauseMenu.id);
                      gameRef.pauseEngine();
                      AudioManager.instance.pauseBgm();
                    },
                    child: const Icon(Icons.pause, color: Colors.white),
                  ),
                  Selector<PlayerModel, int>(
                    selector: (_, playerData) => playerData.currentSalaryMonth,
                    builder: (_, currentSalaryMonth, __) {
                      return Text(
                        'Сарын цалин: ${formatMoney(currentSalaryMonth)}₮',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      );
                    },
                  ),
                  Selector<PlayerModel, int>(
                    selector: (_, playerData) => playerData.currentExpenseMonth,
                    builder: (_, currentExpenseMonth, __) {
                      return Text(
                        'Сарын зарлага: ${formatMoney(currentExpenseMonth)}₮',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      );
                    },
                  ),
                  Selector<PlayerModel, int>(
                    selector: (_, playerData) => playerData.currentDebtsMonth,
                    builder: (_, currentDebtsMonth, __) {
                      return Text(
                        'Сард төлөх зээл: ${formatMoney(currentDebtsMonth)}₮',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      );
                    },
                  ),
                  Selector<PlayerModel, int>(
                    selector: (_, playerData) => playerData.familyHayalga,
                    builder: (_, familyHayalga, __) {
                      return Text(
                        'Эцэг эхийн хаялга: ${formatMoney(familyHayalga)}₮',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      );
                    },
                  ),
                ],
              ),
              const Spacer(),
              Column(
                children: [
                  Selector<PlayerModel, int>(
                    selector: (_, playerData) => playerData.lives,
                    builder: (_, lives, __) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Row(
                          children: List.generate(
                            5,
                            (index) {
                              if (index < lives) {
                                return const Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                );
                              } else {
                                return const Icon(
                                  Icons.favorite_border,
                                  color: Colors.red,
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  Selector<PlayerModel, int>(
                    selector: (_, playerData) => playerData.age,
                    builder: (_, age, __) {
                      return Text(
                        'Нас: $age',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      );
                    },
                  ),
                  Selector<PlayerModel, int>(
                    selector: (_, playerData) => playerData.mentalhealth,
                    builder: (_, mentalhealth, __) {
                      return Text(
                        'Сэтгэл зүйн байдал: ${mentalhealth >= 4 ? 'Сайн' : mentalhealth == 3 ? 'Дунд' : 'Муу'}',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      );
                    },
                  ),
                  Selector<PlayerModel, int>(
                    selector: (_, playerData) => playerData.balance,
                    builder: (_, balance, __) {
                      return Text(
                        'Дансны үлдэгдэл: ${formatMoney(balance)}₮',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      );
                    },
                  ),
                  Selector<PlayerModel, int>(
                    selector: (_, playerData) => playerData.stockbalance,
                    builder: (_, stockbalance, __) {
                      return Text(
                        'Хувьцааны хөрөнгө: ${formatMoney(stockbalance)}₮',
                        style:
                            const TextStyle(fontSize: 20, color: Colors.white),
                      );
                    },
                  ),
                  TextButton(
                    onPressed: () {
                      Get.dialog(
                        QuestionDialog(
                          question:
                              'Зарлага хасаад үлдсэн мөнгөнөөсөө хэдэн хувиа хөрөнгө оруулах уу?',
                          choices: ['0%', '25%', '50%', '75%', '100%'],
                        ),
                      ).then((value) {
                        if (value == '0%') {
                          gameRef.player.investmenPercent = 0;
                        } else if (value == '25%') {
                          gameRef.player.investmenPercent = 0.25;
                        } else if (value == '50%') {
                          gameRef.player.investmenPercent = 0.5;
                        } else if (value == '75%') {
                          gameRef.player.investmenPercent = 0.75;
                        } else if (value == '100%') {
                          gameRef.player.investmenPercent = 1;
                        }
                      });
                    },
                    child: Container(
                      child: Text(
                        'Хувьцаанд хөрөнгө оруулах хувиа шинэчлэх',
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  String formatMoney(int amount) {
    NumberFormat formatter = NumberFormat('#,###');

    return formatter.format(amount);
  }
}
