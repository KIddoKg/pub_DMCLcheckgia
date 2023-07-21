import 'package:flutter/material.dart';
import 'package:pub_dmclcheckgia/helper/formatter.dart';

class GlobalStyles {
  static const textHeader = TextStyle(
      color: Colors.black54, fontSize: 18, fontWeight: FontWeight.bold);
  static const textHeaderB = TextStyle(color: Colors.black54);

  static Color primaryColor = '#025ca6'.toColor();
  static Color backgroundColorAppBar = '#025ca6'.toColor();
  static Color backgroundColor = '#e5e5e5'.toColor();
  static Color backgroundColorButton = HexColor.fromHex("025ca6");
  static Color borderColor = '#cfcfcf'.toColor();
  static Color borderActiveColor = Colors.blue;

  static Color activeColor = Colors.blue;

  static Color backgroundActiveColor = '#025ca6'.toColor();
  static Color backgroundDisableColor = Colors.grey;

  static Color borderCardColor = '#E0E0E0'.toColor();
  static Color backgroundCardColor = '#FCFCFD'.toColor();
  static Color textHintColor = '#828282'.toColor();

  static Color textWhite54 = Colors.white54;
  static Color textColor45 = Colors.black45;
  static Color textColor54 = Colors.black54;
  static Color textColor87 = Colors.black87;
  static Color textAppBarColor = Colors.black;

  static Color cardBorderSelectedColor = '#2D9CDB'.toColor();
  static Color cardSelectedColor = '#E9F5FE'.toColor();

  static BoxDecoration border =
      BoxDecoration(borderRadius: BorderRadius.circular(15));

  static Color getFontColorForBackground(Color background) {
    return (background.computeLuminance() > 0.579)
        ? Colors.black
        : Colors.white;
  }

  static double paddingLR = 16;
  static double paddingTB = 15;

  static double fontSizeNormal = 16;

  static double font14 = 14;
  static double font24 = 24;
}
