import 'package:amidral/manager/audio_manager.dart';
import 'package:amidral/manager/game_manager.dart';
import 'package:amidral/model/player_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

    final QuestionController controller = Get.put(QuestionController());
    return AlertDialog(
      title: Text(question),
      content: Obx(() {
        return SizedBox(
          height: 900,
          width: 1000,
          child: Scrollbar(
            child: SingleChildScrollView(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl:
                          'https://static.vecteezy.com/system/resources/previews/006/691/884/non_2x/blue-question-mark-background-with-text-space-quiz-symbol-vector.jpg',
                      fit: BoxFit.fill,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(choices.length, (index) {
                      return InkWell(
                        onTap: () {
                          controller.selectChoice(index);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              color: controller.selectedIndex == index
                                  ? Colors.green
                                  : Colors.transparent,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
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
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
      actions: [
        TextButton(
          onPressed: () {
            String selectedChoice = choices[controller.selectedIndex.value];
            Get.back(result: selectedChoice);
            GameManager().resumeEngine();
            AudioManager.instance.resumeBgm();
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}
