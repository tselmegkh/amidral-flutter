import 'package:amidral/manager/audio_manager.dart';
import 'package:amidral/manager/game_manager.dart';
import 'package:amidral/model/player_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:provider/provider.dart';

class QuestionController extends GetxController {
  RxInt selectedIndex = 0.obs; // Initially, no choice is selected

  void selectChoice(int index) {
    selectedIndex.value = index;
  }

  void resetSelection() {
    selectedIndex.value = 0;
  }
}

class QuestionDialog extends StatelessWidget {
  final String question;
  final List<String> choices;

  QuestionDialog({required this.question, required this.choices});

  @override
  Widget build(BuildContext context) {
    GameManager().pauseEngine();
    AudioManager.instance.pauseBgm();
    return GetBuilder<QuestionController>(
      init: QuestionController(),
      builder: (controller) => AlertDialog(
        title: Text(question),
        content: Obx(() {
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(choices.length, (index) {
                return InkWell(
                  onTap: () {
                    controller.selectChoice(index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      color: controller.selectedIndex == index
                          ? Colors.blue
                          : Colors.transparent,
                      child: Text(
                        '${String.fromCharCode(index + 65)}. ${choices[index]}',
                        style: TextStyle(
                          color: controller.selectedIndex == index
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
        actions: [
          TextButton(
            onPressed: () {
              String selectedChoice = choices[controller.selectedIndex.value];
              GameManager().resumeEngine();
              AudioManager.instance.resumeBgm();
              Get.back(result: selectedChoice);
            },
            child: Text('Submit'),
          ),
        ],
      ),
    );
  }
}
