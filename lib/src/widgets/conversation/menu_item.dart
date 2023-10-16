import 'package:flutter/material.dart';

class LMMenuItem {
  const LMMenuItem({
    required this.leading,
    required this.title,
    required this.onTap,
  });
  final Widget leading;
  final Widget title;
  final VoidCallback onTap;
}
