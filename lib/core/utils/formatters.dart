import 'package:intl/intl.dart';

class AppFormatters {
  static String currency(double amount) => NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(amount);
  static String compactNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}k';
    return '${(number / 1000000).toStringAsFixed(1)}M';
  }
}
