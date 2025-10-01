import 'package:intl/intl.dart';

String formatMoney(double amount) {
  final formatter = NumberFormat('#,##0', 'en_US');
  return '${formatter.format(amount)} FBu';
}
