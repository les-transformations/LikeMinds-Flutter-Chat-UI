import 'package:flutter/material.dart';
import 'package:likeminds_chat_ui_fl/likeminds_chat_ui_fl.dart';

class LMAppBar extends StatelessWidget {
  const LMAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
    this.background,
  });

  final LMTextView title;
  final LMTextView? subtitle;

  final Widget? leading;
  final List<Widget>? actions;

  final Color? background;
  // final

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
