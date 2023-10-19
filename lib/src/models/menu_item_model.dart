import 'package:flutter/material.dart';

class LMMenuItemUI {
  const LMMenuItemUI({
    required this.leading,
    required this.title,
    required this.onTap,
  });
  final Widget leading;
  final Widget title;
  final VoidCallback onTap;
}
