import 'package:amidral/model/setting_model.dart';

class AudioManager {
  //
  late SettingModel settings;

  AudioManager._internal();

  static final AudioManager _instance = AudioManager._internal();

  static AudioManager get instance => _instance;

  Future<void> init(List<String> files, SettingModel settings) async {
    this.settings = settings;

    // FlameAudio.bgm.initialize();

    // await FlameAudio.audioCache.loadAll(files);
  }

  void startBgm([String filename = '8BitPlatformerLoop.wav']) {
    if (settings.bgm) {
      // FlameAudio.bgm.play(filename, volume: 0.5);
    }
  }

  void pauseBgm() {
    if (settings.bgm) {
      // FlameAudio.bgm.pause();
    }
  }

  void resumeBgm() {
    if (settings.bgm) {
      // FlameAudio.bgm.resume();
    }
  }

  void stopBgm() {
    // FlameAudio.bgm.stop();
  }

  void playSfx(String fileName) {
    if (settings.sfx) {
      // FlameAudio.play(fileName);
    }
  }
}
