import 'dart:developer' as developer;
import 'dart:math';
import 'dart:ui';

import 'package:amidral/components/enemy_component.dart';
import 'package:amidral/constant/constants.dart';
import 'package:amidral/manager/audio_manager.dart';
import 'package:amidral/model/player_model.dart';
import 'package:amidral/widgets/game_over_menu.dart';
import 'package:amidral/widgets/hud.dart';
import 'package:amidral/widgets/qa_dialog.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../constant/animation_state.dart';
import '../manager/asset_manager.dart';
import '../manager/game_manager.dart';

class TRexComponent extends SpriteAnimationGroupComponent<TRexAnimationState>
    with CollisionCallbacks, HasGameRef<GameManager> {
  TRexComponent(Image image, this.playerData)
      : super.fromFrameData(image, AssetManager.animation);

  double yMax = 0.0;

  double speedY = 0.0;
  final Timer _hitTimer = Timer(1);

  bool isHit = false;

  final PlayerModel playerData;

  static const double gravity = 800;
  Map<String, int> tsalin = {
    'Зөөгч': 850000,
    'Дуу хийх': 100000,
    'Ресейпшн': 1200000,
    'Барилга': 1200000,
    'Такси': 1000000,
    'Бариста': 1000000,
    'Программист': 1800000,
    'Менежер': 1800000,
    'Санхүүч': 1800000,
    'Зураач': 1800000,
    'Эмч': 1500000,
  };

  String eduToString(Education education) {
    switch (education) {
      case Education.cs:
        return 'Программист';
      case Education.business:
        return 'Менежер';
      case Education.finance:
        return 'Санхүүч';
      case Education.art:
        return 'Зураач';
      case Education.doctor:
        return 'Эмч';
      default:
        return '';
    }
  }

  @override
  void onMount() {
    _reset();
    _createHitBox();

    yMax = y;

    _hitTimer.onTick = () {
      current = TRexAnimationState.run;
      isHit = false;
    };

    super.onMount();
  }

  @override
  void update(double dt) {
    speedY = speedY + (gravity * dt);
    y = y + (speedY * dt);

    if (isOnGround) {
      y = yMax;
      speedY = 0.0;
      if ((current != TRexAnimationState.hit) &&
          (current != TRexAnimationState.run)) {
        current = TRexAnimationState.run;
      }
    }

    _hitTimer.update(dt);
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is EnemyComponent && (!isHit)) {
      hit();
    }
    super.onCollision(intersectionPoints, other);
  }

  void jump() {
    if (isOnGround) {
      speedY = -300;
      current = TRexAnimationState.idle;
      AudioManager.instance.playSfx('jump14.wav');
    }
  }

  void hit() async {
    isHit = true;
    AudioManager.instance.playSfx('hurt7.wav');
    current = TRexAnimationState.hit;
    _hitTimer.start();
    playerData.age += 1;
    playerData.balance += playerData.currentSalaryMonth * 12;

    int difference =
        playerData.currentExpenseMonth - playerData.currentSalaryMonth;
    playerData.stockbalance += (playerData.stockbalance * 0.15).toInt();
    if (difference > 0 &&
        difference * 12 > playerData.balance &&
        playerData.age <= 25) {
      playerData.familyHayalga += difference * 12 - playerData.balance;
      playerData.balance = 0;
    } else {
      playerData.balance -= playerData.currentExpenseMonth * 12;
    }
    if (playerData.balance > 0) {
      playerData.stockbalance +=
          (playerData.balance * playerData.investmentPercent).toInt();
      playerData.balance =
          ((1 - playerData.investmentPercent) * playerData.balance).toInt();
    }
    if (playerData.balance < 0) {
      if (playerData.stockbalance >= (-playerData.balance)) {
        int dif = -playerData.balance;
        playerData.stockbalance -= (-playerData.balance);
        playerData.balance += (dif);
      } else {
        playerData.balance += (playerData.stockbalance);
        playerData.stockbalance = 0;
      }
      if (playerData.balance + playerData.stockbalance < 0)
        playerData.mentalhealth--;
    }
    if (playerData.age % 5 == 0) {
      playerData.currentSalaryMonth =
          (playerData.currentSalaryMonth * 1.1).toInt();
    }

    await checkMentalHealth();
    int val = 0;
    playerData.allDebts.forEach((key, value) {
      if (key == playerData.age) {
        value.forEach((element) {
          playerData.currentExpenseMonth -= (element / 12).toInt();
        });
      }
    });
    playerData.balance -= val;

    if (playerData.mentalhealth <= 0) return;

    // Random random = new Random();
    // int randomNumber = random.nextInt(100);
    // if (randomNumber <= 2) {
    //   playerData.lives = 0;
    // }
    if (playerData.age == 18) {
      Get.dialog(
        QuestionDialog(
          question: 'Их сургуульд орох уу?',
          choices: [
            'Тийм',
            'Үгүй',
          ],
        ),
        barrierDismissible: false,
      ).then((value) {
        if (value == 'Тийм') {
          Get.dialog(
            QuestionDialog(
              question: 'Ямар чиглэлээр суралцах вэ?',
              choices: [
                'Computer Science',
                'Business',
                'Finance',
                'Art School',
                'Doctor',
              ],
            ),
          ).then((value) {
            Get.snackbar(
              'Их сургуульд элслээ.',
              "'$value чиглэлээр явах гэж буй танд амжилт хүсье",
            );
            switch (value) {
              case 'Computer Science':
                playerData.education = Education.cs;
                break;
              case 'Business':
                playerData.education = Education.business;
                break;
              case 'Finance':
                playerData.education = Education.finance;
                break;
              case 'Art School':
                playerData.education = Education.art;
                break;
              case 'Doctor':
                playerData.education = Education.doctor;
                break;
              default:
                break;
            }
          });
        } else {
          Get.dialog(
            QuestionDialog(
              question: 'Ямар чиглэлээр ажиллах вэ?',
              choices: [
                'Зөөгч',
                'Ресейпшн',
                'Барилга',
                'Такси',
                'Бариста',
              ],
            ),
            barrierDismissible: false,
          ).then((value) {
            playerData.currentSalaryMonth = tsalin[value] ?? 0;
            playerData.currentExpenseMonth +=
                (playerData.currentSalaryMonth / 10 * 5).toInt();
            print(value);
            Get.snackbar('Ажиллаж эхлэлээ.',
                "'$value' ажлыг сонгож сарын ${playerData.currentSalaryMonth}₮ цалинтай ажиллаж эхлэлээ. Танд амжилт хүсье.");
          });
        }
      });
    }
    if (playerData.age == 19) {
      Get.dialog(
        QuestionDialog(
          question: 'Найзуудтайгаа 100,000 төгрөгөөр шоудах уу?',
          choices: ['Тийм', 'Үгүй'],
        ),
        barrierDismissible: false,
      ).then((value) {
        if (value == 'Тийм') {
          playerData.mentalhealth = max(5, playerData.mentalhealth + 1);
          if (playerData.balance >= 100000) {
            playerData.balance -= 100000;
            Get.snackbar(
              'Та өөрийнхөө мөнгөнөөс 100,000₮-р шоудлаа.',
              'Сайхан шоудаарай!',
            );
          } else {
            playerData.familyHayalga += 100000;
            Get.snackbar(
              'Танд мөнгө байхгүй тул эцэг эхийн хаялга хүртэв.',
              'Сайхан шоудаарай!',
            );
          }
          playerData.lives--;
        } else {
          playerData.mentalhealth--;
        }
      });
    }
    if (playerData.age == 20 && playerData.education != Education.none) {
      Get.dialog(
        QuestionDialog(
          question: 'Цагийн ажил хийх үү?',
          choices: ['Тийм', 'Үгүй'],
        ),
        barrierDismissible: false,
      ).then((value) {
        if (value == 'Тийм') {
          playerData.currentSalaryMonth = 600000;
          playerData.mentalhealth = min(5, playerData.mentalhealth + 1);
          playerData.lives--;
        } else {
          playerData.mentalhealth -= 1;
        }
      });
    }
    if (playerData.age == 22 && playerData.education != Education.none) {
      Get.snackbar('Баяр хүргэе!',
          'Та амжилттай сургуулиа төгсөж ${eduToString(playerData.education)} мэргэжлээр ${tsalin[eduToString(playerData.education)]} цалинтай ажиллахаар боллоо.');
      playerData.currentSalaryMonth =
          tsalin[eduToString(playerData.education)]!;

      playerData.currentExpenseMonth =
          (tsalin[eduToString(playerData.education)]! / 10 * 4).toInt();
    }
    if (playerData.age == 23) {
      checkGF();
      // Get.dialog(
      //   QuestionDialog(
      //     question: 'Найз охин/залуу-тай болох уу?',
      //     choices: ['Тийм', 'Үгүй'],
      //   ),
      // ).then((value) {
      //   if (value == 'Тийм') {
      //     playerData.mentalhealth = max(5, playerData.mentalhealth + 1);
      //     playerData.currentExpenseMonth +=
      //         (playerData.currentSalaryMonth / 10 * 2).toInt();
      //     playerData.family = 'gf';
      //   } else {
      //     playerData.mentalhealth -= 1;
      //   }
      // });
    }
    if (playerData.age == 24) {
      Get.dialog(
        QuestionDialog(
          question: 'Та машин авах уу?',
          choices: [
            'Prius 20 авъя!, 10,000,000₮',
            'Lexus RX авъя! 40,000,000₮',
            'Үгүй',
          ],
        ),
        barrierDismissible: false,
      ).then((value) {
        if (value != 'Үгүй') {
          Get.dialog(
            QuestionDialog(
              question: 'Ямар аргаар авах вэ?',
              choices: ['Шууд', 'Жилийн 20%-ын 5 жилийн зээлээр'],
            ),
          ).then((value2) {
            int price =
                value == 'Prius 20 авъя!, 10,000,000₮' ? 10000000 : 40000000;
            if (value2 == 'Шууд') {
              int price =
                  value == 'Prius 20 авъя!, 10,000,000₮' ? 10000000 : 40000000;
              if (playerData.balance + playerData.stockbalance < price) {
                Get.snackbar('Үлдэгдэл хүрэлцэхгүй байна.',
                    'Одоогоор шууд авахад таны үлдэгдэл хүрэлцэхгүй байна.');
              } else {
                String type = value == 'Prius 20 авъя!, 10,000,000₮'
                    ? 'Prius 20'
                    : 'Lexus RX';
                Get.snackbar('Амжилттай!', 'Та $type машинтай боллоо.');
                int maxFromBalance = min(playerData.balance, price);
                int difference = price - maxFromBalance;
                playerData.balance -= maxFromBalance;
                playerData.stockbalance -= difference;
                playerData.assets.add('$type');
                playerData.currentExpenseMonth += 100000;
              }
            } else {
              price *= 2;
              playerData.currentExpenseMonth += (price / 5 / 12).toInt();
              playerData.allDebts.putIfAbsent(playerData.age + 5, () => []);
              playerData.allDebts[playerData.age + 5]!.add((price / 5).toInt());
              playerData.currentExpenseMonth += 100000;
            }
          });
        } else {
          playerData.mentalhealth--;
        }
      });
    }

    if (playerData.age == 25) {
      if (playerData.family == 'gf') {
        Get.dialog(
          QuestionDialog(
              question: 'Та хуримаа хийх үү? Зардал: 50,000,000₮',
              choices: ['Тийм', 'Үгүй', 'Салах']),
          barrierDismissible: false,
        ).then((value) {
          if (value == 'Тийм') {
            Get.dialog(
              QuestionDialog(
                question: 'Төлбөрөө яаж шийдэх вэ?',
                choices: ['Шууд', 'Жилийн 20%-ын 5 жилийн зээлээр'],
              ),
              barrierDismissible: false,
            ).then((value2) {
              int price = 50000000;
              if (value2 == 'Шууд') {
                int price = 50000000;
                if (playerData.balance + playerData.stockbalance < price) {
                  Get.snackbar('Үлдэгдэл хүрэлцэхгүй байна.',
                      'Одоогоор шууд авахад таны үлдэгдэл хүрэлцэхгүй байна.');
                } else {
                  Get.snackbar('Амжилттай!',
                      'Та хуримаа хийлээ! Гэр бүлд нь сайн сайхныг хүсье.');
                  int maxFromBalance = min(playerData.balance, price);
                  int difference = price - maxFromBalance;
                  playerData.balance -= maxFromBalance;
                  playerData.stockbalance -= difference;
                  playerData.family = 'ehner';
                  playerData.currentExpenseMonth -= 100000;
                }
              } else {
                price *= 2;
                playerData.currentExpenseMonth += (price / 5 / 12).toInt();
                playerData.allDebts.putIfAbsent(playerData.age + 5, () => []);
                playerData.allDebts[playerData.age + 5]!
                    .add((price / 5).toInt());
                playerData.currentExpenseMonth -= 100000;
                Get.snackbar(
                  'Амжилттай!',
                  'Та хуримаа хийлээ! Гэр бүлд нь сайн сайхныг хүсье.',
                );
              }
            });
          }
        });
      } else {
        checkGF();
      }
    }
    if (playerData.age == 28) {
      Get.dialog(
        QuestionDialog(question: 'Та байр авах уу?', choices: [
          '2 өрөө байр, 70,000,000₮',
          '5 өрөө байр, 200,000,000₮',
          'Түрээс, сарын 700,000₮'
        ]),
        barrierDismissible: false,
      ).then((value) {
        //Ursgal zardal 2 uruu - 1,200,000 / year
        //Ursgal zardal 5 uruu - 2,400,000 / year
        //Turees ursgal zardal - 1,200,000 / year
        if (value != 'Түрээс, сарын 700,000₮') {
          Get.dialog(
            QuestionDialog(
              question: 'Төлбөрөө яаж шийдэх вэ?',
              choices: ['Шууд', 'Жилийн 6%-ын 20 жилийн зээлээр'],
            ),
            barrierDismissible: false,
          ).then((value2) {
            int price =
                value == '2 өрөө байр, 70,000,000₮' ? 70000000 : 200000000;
            if (value2 == 'Шууд') {
              if (playerData.balance + playerData.stockbalance < price) {
                Get.snackbar('Үлдэгдэл хүрэлцэхгүй байна.',
                    'Одоогоор шууд авахад таны үлдэгдэл хүрэлцэхгүй байна.');
              } else {
                Get.snackbar(
                    'Амжилттай!', 'Та өөрийн гэсэн орох оронтой боллоо.');
                int maxFromBalance =
                    min(playerData.balance, playerData.stockbalance);
                int difference = price - maxFromBalance;
                playerData.balance -= maxFromBalance;
                playerData.stockbalance -= difference;
                playerData.assets.add(value2);
              }
            } else {
              price += (price * 0.06 * 20).toInt();
              playerData.currentExpenseMonth += (price / 20 / 12).toInt();
              playerData.allDebts.putIfAbsent(playerData.age + 20, () => []);
              playerData.allDebts[playerData.age + 20]!
                  .add((price / 20).toInt());
              int ursgal =
                  value2 == '2 өрөө байр, 70,000,000₮' ? 1200000 : 2400000;
              playerData.currentExpenseMonth += (ursgal / 12).toInt();
              Get.snackbar(
                'Амжилттай!',
                'Та орох оронтой боллоо.',
              );
            }
          });
        } else {
          playerData.currentExpenseMonth += 800000;
          playerData.mentalhealth--;
        }
      });
    }
    if (playerData.age == 29) {
      if (playerData.family != 'none') {
        Get.dialog(
          QuestionDialog(
            question: 'Хүүхэдтэй болох уу?',
            choices: ['Тийм', 'Үгүй'],
          ),
          barrierDismissible: false,
        ).then((value) {
          if (value == 'Тийм') {
            playerData.currentExpenseMonth =
                (playerData.currentExpenseMonth * 1.1).toInt();
            playerData.mentalhealth = min(5, playerData.mentalhealth + 1);
          } else {
            playerData.mentalhealth -= 1;
          }
        });
      }
    }
    if (playerData.age == 30) {
      Get.snackbar(
          'Баяр хүргэе!', 'Та албан тушаал ахиж таны цалин 30%-аар нэмэгдлээ');
      playerData.mentalhealth = min(5, playerData.mentalhealth + 1);
      playerData.currentSalaryMonth =
          (playerData.currentSalaryMonth * 1.3).toInt();
    }

    if (playerData.age == 32) {
      Get.dialog(
        QuestionDialog(
          question: 'Та дахиж машин авах уу?',
          choices: [
            'Prius 30 авъя!, 30,000,000₮',
            'Lexus LX 570 авъя! 200,000,000₮',
            'Үгүй',
          ],
        ),
        barrierDismissible: false,
      ).then((value) {
        if (value != 'Үгүй') {
          Get.dialog(
            QuestionDialog(
              question: 'Ямар аргаар авах вэ?',
              choices: ['Шууд', 'Жилийн 20%-ын 5 жилийн зээлээр'],
            ),
            barrierDismissible: false,
          ).then((value2) {
            int price =
                value == 'Prius 30 авъя!, 30,000,000₮' ? 30000000 : 200000000;
            if (value2 == 'Шууд') {
              if (playerData.balance + playerData.stockbalance < price) {
                Get.snackbar('Үлдэгдэл хүрэлцэхгүй байна.',
                    'Одоогоор шууд авахад таны үлдэгдэл хүрэлцэхгүй байна.');
              } else {
                String type = value == 'Prius 20 авъя!, 10,000,000₮'
                    ? 'Prius 20'
                    : 'Lexus RX';
                Get.snackbar('Амжилттай!', 'Та $type машинтай боллоо.');
                int maxFromBalance = min(playerData.balance, price);
                int difference = price - maxFromBalance;
                playerData.balance -= maxFromBalance;
                playerData.stockbalance -= difference;
                playerData.assets.add('$type');
                playerData.currentExpenseMonth += 200000;
              }
            } else {
              price *= 2;
              playerData.currentExpenseMonth += (price / 5 / 12).toInt();
              playerData.allDebts.putIfAbsent(playerData.age + 5, () => []);
              playerData.allDebts[playerData.age + 5]!.add((price / 5).toInt());
              playerData.currentExpenseMonth += 200000;
            }
          });
        } else {
          playerData.mentalhealth--;
        }
      });
    }

    if (playerData.age == 40) {
      Get.dialog(
        QuestionDialog(
          question: 'Та байр нэмж авах уу?',
          choices: [
            'Зайсанд 3 өрөө байр!, 400,000,000₮',
            'Зайсанд 5 өрөө байр! 1,000,000,000₮',
            'Үгүй',
          ],
        ),
        barrierDismissible: false,
      ).then((value) {
        if (value != 'Үгүй') {
          Get.dialog(
            QuestionDialog(
              question: 'Ямар аргаар авах вэ?',
              choices: ['Шууд', 'Жилийн 6%-ын 20 жилийн зээлээр'],
            ),
            barrierDismissible: false,
          ).then((value2) {
            int price = value == 'Зайсанд 3 өрөө байр!, 400,000,000₮'
                ? 400000000
                : 1000000000;
            if (value2 == 'Шууд') {
              if (playerData.balance + playerData.stockbalance < price) {
                Get.snackbar('Үлдэгдэл хүрэлцэхгүй байна.',
                    'Одоогоор шууд авахад таны үлдэгдэл хүрэлцэхгүй байна.');
              } else {
                String type = value == 'Зайсанд 3 өрөө байр!, 400,000,000₮'
                    ? 'Зайсан 3 өрөө'
                    : 'Зайсан 5 өрөө';
                Get.snackbar('Амжилттай!', 'Та $type машинтай боллоо.');
                int maxFromBalance = min(playerData.balance, price);
                int difference = price - maxFromBalance;
                playerData.balance -= maxFromBalance;
                playerData.stockbalance -= difference;
                playerData.assets.add('$type');
                playerData.currentExpenseMonth += 500000;
              }
            } else {
              price *= 2;
              playerData.currentExpenseMonth += (price / 20 / 12).toInt();
              playerData.allDebts.putIfAbsent(playerData.age + 20, () => []);
              playerData.allDebts[playerData.age + 20]!
                  .add((price / 20).toInt());
              playerData.currentExpenseMonth += 500000;
            }
          });
        } else {
          playerData.mentalhealth--;
        }
      });
    }
    if (playerData.age == 42) {
      Get.snackbar('Баяр хүргэе!',
          'Та ахлах ажилтан болж таны цалин дахин 30%-аар нэмэгдэв.');
      playerData.currentSalaryMonth =
          (playerData.currentSalaryMonth * 1.3).toInt();
    }
    if (playerData.age == 44) {
      Get.dialog(
        QuestionDialog(
          question: 'Эхнэр/нөхөртөө бэлэг авж өгөх үү, аялах уу?',
          choices: ['Бэлэг авч өгье. 10,000,000₮', 'Үгүй'],
        ),
        barrierDismissible: false,
      ).then((value) {
        if (value == 'Тийм') {
          if (playerData.balance + playerData.stockbalance < 10000000) {
            Get.snackbar('Амжилтгүй.', 'Таны үлдэгдэл хүрсэнгүй.');
            playerData.mentalhealth--;
          } else {
            int maxFromBalance = min(playerData.balance, 10000000);
            int difference = 10000000 - maxFromBalance;
            playerData.balance -= maxFromBalance;
            playerData.stockbalance -= difference;
            playerData.mentalhealth = min(5, playerData.mentalhealth + 1);
          }
        } else {
          playerData.mentalhealth -= 1;
        }
      });
    }
    if (playerData.age == 46) {
      Get.dialog(
        QuestionDialog(
          question: 'Гэр бүлээрээ сайхан Тайландаар аялачих уу?',
          choices: ['Ок. 30,000,000₮', 'Үгүй'],
        ),
        barrierDismissible: false,
      ).then((value) {
        if (value != 'Үгүй') {
          if (playerData.balance + playerData.stockbalance < 30000000) {
            Get.snackbar('Амжилтгүй.', 'Таны үлдэгдэл хүрсэнгүй.');
            playerData.mentalhealth--;
          } else {
            int maxFromBalance = min(playerData.balance, 10000000);
            int difference = 10000000 - maxFromBalance;
            playerData.balance -= maxFromBalance;
            playerData.stockbalance -= difference;
            playerData.mentalhealth = min(5, playerData.mentalhealth + 1);
          }
        } else {
          playerData.mentalhealth -= 1;
        }
      });
    }
    if (playerData.age == 50) {
      Get.dialog(
        QuestionDialog(
          question: 'Сайхан 50 насны баяраа хийх үү, хө? 50,000,000₮',
          choices: ['Тийм', 'Үгүй'],
        ),
        barrierDismissible: false,
      ).then((value) {
        if (value == 'Тийм') {
          if (playerData.balance + playerData.stockbalance < 50000000) {
            Get.snackbar('Амжилтгүй.', 'Таны үлдэгдэл хүрсэнгүй.');
            playerData.mentalhealth--;
          } else {
            int maxFromBalance = min(playerData.balance, 50000000);
            int difference = 50000000 - maxFromBalance;
            playerData.balance -= maxFromBalance;
            playerData.stockbalance -= difference;
            playerData.mentalhealth = min(5, playerData.mentalhealth + 1);
          }
        } else {
          playerData.mentalhealth -= 1;
        }
      });
    }
    if (playerData.age == 55) {
      Get.snackbar('Та тэтгэвэртээ гарчихлаа.',
          'Шаргуу хөдөлмөрлөсөн жилүүдэд нь баяр хүргэе!');
      playerData.currentSalaryMonth =
          (playerData.currentSalaryMonth * 0.3).toInt();
    }
    if (playerData.age == 65) {
      gameRef.overlays.add(GameOverMenu.id);
      gameRef.overlays.remove(Hud.id);
      gameRef.pauseEngine();
      Get.snackbar('Ум Мани Бад Мэ Хум.', 'Сайхан л амьдарлаа.');
    }
  }

  void hurim() async {
    Get.dialog(
      QuestionDialog(
        question: 'Хурамаа хийх үү?',
        choices: ['Тийм', 'Үгүй'],
      ),
      barrierDismissible: false,
    ).then((value) => {
          if (value == 'Тийм')
            {}
          else
            {
              //need idea
            }
        });
  }

  void checkGF() async {
    Get.dialog(
      QuestionDialog(
        question: 'Найз охин/залуу-тай болох уу?',
        choices: ['Тийм', 'Үгүй'],
      ),
      barrierDismissible: false,
    ).then((value) {
      if (value == 'Тийм') {
        playerData.mentalhealth = min(5, playerData.mentalhealth + 1);
        playerData.currentExpenseMonth +=
            (playerData.currentSalaryMonth / 10 * 2).toInt();
        playerData.family = 'gf';
      } else {
        playerData.mentalhealth -= 1;
      }
    });
  }

  Future<bool> checkMentalHealth() async {
    if (playerData.mentalhealth <= 0) {
      await Get.dialog(
        QuestionDialog(
          question:
              'Таны сэтгэл зүй их муу байна. Та сэтгэл зүйчтэй уулзах ёстой боллоо. Зардал: 5,000,000₮',
          choices: ['Тийм', 'Үгүй'],
        ),
      ).then((value) {
        if (value == 'Тийм') {
          playerData.mentalhealth = 3;
          if (playerData.balance + playerData.stockbalance < 50000005) {
            gameRef.overlays.add(GameOverMenu.id);
            gameRef.overlays.remove(Hud.id);
            gameRef.pauseEngine();
            Get.snackbar('Харамсалтай байна',
                'Сэтгэл зүйчид явахад таны мөнгө хүрэлцээгүй учир, сэтгэл гутралд орж нас барлаа.');
            return true;
          } else {
            return false;
          }
        } else {
          gameRef.overlays.add(GameOverMenu.id);
          gameRef.overlays.remove(Hud.id);
          gameRef.pauseEngine();

          Get.snackbar(
              'Харамсалтай байна', 'Та сэтгэл гутралд орж нас барлаа.');
          return false;
        }
      });
    }
    return false;
  }

  bool get isOnGround => (y >= yMax);

  void _createHitBox() {
    add(
      RectangleHitbox.relative(
        Vector2(0.5, 0.7),
        parentSize: size,
        position: Vector2(size.x * 0.5, size.y * 0.3) / 2,
      ),
    );
  }

  void _reset() {
    developer.log('reset()');
    if (isMounted) {
      removeFromParent();
    }
    anchor = Anchor.bottomLeft;
    position = Vector2(kTRexDefaultX, kTRexDefaultY);
    size = Vector2.all(74);
    current = TRexAnimationState.run;
    isHit = false;
    speedY = 0.0;
  }
}
