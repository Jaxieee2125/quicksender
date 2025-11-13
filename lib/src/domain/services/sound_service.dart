// trong file: lib/src/domain/services/sound_service.dart
import 'package:audioplayers/audioplayers.dart';

class SoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();

  Future<void> playTransferComplete() async {
    try {
      // 'notification.mp3' là tên file bạn đã đặt trong assets/sounds
      await _audioPlayer.play(AssetSource('sounds/complete.mp3'));
    } catch (e) {
      print("Error playing sound: $e");
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}