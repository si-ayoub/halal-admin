import 'dart:math';

class PromoCodeGenerator {
  static const _letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _numbers = '0123456789';
  static final _random = Random();
  
  static String generate() {
    final letters = List.generate(3, (_) => _letters[_random.nextInt(_letters.length)]).join();
    final numbers = List.generate(3, (_) => _numbers[_random.nextInt(_numbers.length)]).join();
    return '$letters$numbers';
  }
}
