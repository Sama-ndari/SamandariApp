import 'package:flutter/material.dart';

class DateRange {
  final DateTime start;
  final DateTime end;

  DateRange(this.start, this.end);

  bool contains(DateTime date) {
    return !date.isBefore(start) && date.isBefore(end);
  }
}

class DateRangeUtils {
  static DateRange thisWeek(DateTime now) {
    final start = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final end = start.add(const Duration(days: 7));
    return DateRange(start, end);
  }

  static DateRange lastWeek(DateTime now) {
    final thisWeekStart = DateTime(now.year, now.month, now.day - (now.weekday - 1));
    final start = thisWeekStart.subtract(const Duration(days: 7));
    final end = thisWeekStart;
    return DateRange(start, end);
  }

  static DateRange thisMonth(DateTime now) {
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1);
    return DateRange(start, end);
  }

  static DateRange lastMonth(DateTime now) {
    final end = DateTime(now.year, now.month, 1);
    final start = DateTime(now.year, now.month - 1, 1);
    return DateRange(start, end);
  }

  static DateRange thisQuarter(DateTime now) {
    final quarter = (now.month - 1) ~/ 3 + 1;
    final startMonth = (quarter - 1) * 3 + 1;
    final start = DateTime(now.year, startMonth, 1);
    final end = DateTime(now.year, startMonth + 3, 1);
    return DateRange(start, end);
  }

  static DateRange lastQuarter(DateTime now) {
    final currentQuarter = (now.month - 1) ~/ 3;
    final lastQuarterYear = currentQuarter == 0 ? now.year - 1 : now.year;
    final lastQuarterStartMonth = (currentQuarter == 0 ? 3 : currentQuarter - 1) * 3 + 1;

    final start = DateTime(lastQuarterYear, lastQuarterStartMonth, 1);
    final end = DateTime(lastQuarterYear, lastQuarterStartMonth + 3, 1);
    return DateRange(start, end);
  }
}
