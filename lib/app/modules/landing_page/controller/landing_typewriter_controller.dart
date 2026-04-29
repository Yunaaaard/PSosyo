import 'dart:async';
import 'package:get/get.dart';

class LandingTypewriterController extends GetxController {
  final RxString displayed = ''.obs;
  final RxBool done = false.obs;
  final String text;
  final Duration duration;
  Timer? _timer;
  int _index = 0;

  LandingTypewriterController({
    required this.text,
    this.duration = const Duration(milliseconds: 120),
  });

  @override
  void onInit() {
    super.onInit();
    _startTyping();
  }

  void _startTyping() {
    _timer = Timer.periodic(duration, (timer) {
      if (_index < text.length) {
        displayed.value += text[_index];
        _index++;
      } else {
        timer.cancel();
        done.value = true;
      }
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
