import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension DoubleNumberExtension on double {
  String spaceSeparateNumbers() {
    var f = NumberFormat('#,##0');
    return f.format(this);
  }
}

extension IntegerNumberExtension on int {
  String toCurrency({subfix = 'đ'}) {
    var f = NumberFormat('###,###');
    return f.format(this) + subfix;
  }

  String toDateString({format = 'HH:mm dd/MM/yyyy'}) {
    var x = DateFormat(format)
        .format(DateTime.fromMillisecondsSinceEpoch(this, isUtc: false));
    return x;
  }
}

extension DatetimeExtesion on DateTime {
  DateTime lastDateOfMouth() {
    var now = DateTime.now();

// Find the last day of the month.
    var lastDayDateTime = (now.month < 12)
        ? DateTime(now.year, now.month + 1, 0)
        : DateTime(now.year + 1, 1, 0);

    print(lastDayDateTime.day); // 28 for February

    return lastDayDateTime;
  }

  String toWeekdayString({
    List<String>? formatWeeks,
  }) {
    var defaultWeek =
        formatWeeks ??= ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return defaultWeek[weekday - 1];
  }

  static String weekdayStringFrom(
      {required DateTime date, List<String>? formatWeeks}) {
    var defaultWeek =
        formatWeeks ??= ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return defaultWeek[date.weekday - 1];
  }
}

extension CapExtension on String {
  String toUpFirstCase() =>
      isNotEmpty ? '${this[0].toLowerCase()}${substring(1)}' : '';

  String get capitalizeFirstofEach => replaceAll(RegExp(' +'), ' ')
      .split(" ")
      .map((str) => str.toUpFirstCase)
      .join(" ");

  String get getProductCodeFromUrl {
    var code = this;
    var isURL = Uri.tryParse(code)?.hasAbsolutePath ?? false;
    if (isURL) {
      List lst = code.split('/');
      var productCode = lst.last.split('-').last;
      return productCode;
    } else {
      return '';
    }
  }
}

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';

  Color hex(String hexString) {
    var c = hexString.replaceAll('#', '0xff');
    return Color(int.parse(c));
  }

  MaterialColor toMaterialColor() {
    MaterialColor colorSwatch = MaterialColor(
      value,
      <int, Color>{
        50: withAlpha((255 * 0.1).toInt()),
        100: withAlpha((255 * 0.2).toInt()),
        200: withAlpha((255 * 0.3).toInt()),
        300: withAlpha((255 * 0.4).toInt()),
        400: withAlpha((255 * 0.5).toInt()),
        500: withAlpha((255 * 0.6).toInt()),
        600: withAlpha((255 * 0.7).toInt()),
        700: withAlpha((255 * 0.8).toInt()),
        800: withAlpha((255 * 0.9).toInt()),
        900: withAlpha((255 * 1).toInt()),
      },
    );
    return colorSwatch;
  }
}

extension StringColor on String {
  /// required string color has '#...'
  ///
  /// Return color
  Color toColor() {
    if (isEmpty) return Colors.white;

    var c = replaceAll('#', '0xff');
    return Color(int.parse(c));
  }
}
