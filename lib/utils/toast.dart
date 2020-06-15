import 'dart:ui';

import 'package:fluttertoast/fluttertoast.dart';

class ToastUtils {
  static void showToast(String msg, Color backGroundColor, Color textColor) {
    Fluttertoast.showToast(
        msg: msg, backgroundColor: backGroundColor, textColor: textColor);
  }
}
