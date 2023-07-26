import 'package:flutter/material.dart';
import 'package:likeminds_chat_ui_fl/src/utils/theme.dart';
import 'package:timeago/timeago.dart';

extension StringColor on String {
  Color? toColor() {
    // if (primaryColor != null) {
    if (int.tryParse(this) != null) {
      return Color(int.tryParse(this)!);
    } else {
      return kPrimaryColor;
    }
  }
}

// Convert DateTime to Time Ago String
extension DateTimeAgo on DateTime {
  String timeAgo() {
    return format(this);
  }
}

// Convert integer or double to screen height percentage (h)
extension ScreenHeight on num {
  double get h => (this / 100) * ScreenSize.height;
}

// Convert integer or double to screen width percentage (w)
extension ScreenWidth on num {
  double get w => (this / 100) * ScreenSize.width;
}

// Class to initialize the screen size
class ScreenSize {
  static late double width;
  static late double height;
  static late double blockSizeHorizontal;
  static late double blockSizeVertical;
  static late double _safeAreaHorizontal;
  static late double _safeAreaVertical;
  static late double safeBlockHorizontal;
  static late double safeBlockVertical;

  static init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    width = mediaQuery.size.width;
    height = mediaQuery.size.height;
    blockSizeHorizontal = width / 100;
    blockSizeVertical = height / 100;
    _safeAreaHorizontal = mediaQuery.padding.left + mediaQuery.padding.right;
    _safeAreaVertical = mediaQuery.padding.top + mediaQuery.padding.bottom;
    safeBlockHorizontal = (width - _safeAreaHorizontal) / 100;
    safeBlockVertical = (height - _safeAreaVertical) / 100;
  }
}
