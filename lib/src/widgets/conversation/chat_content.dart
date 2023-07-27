import 'package:flutter/material.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_ui_fl/packages/expandable_text/expandable_text.dart';
import 'package:likeminds_chat_ui_fl/src/utils/theme.dart';

class LMChatContent extends StatelessWidget {
  const LMChatContent({
    super.key,
    required this.conversation,
    this.visibleLines,
    this.textStyle,
    this.linkStyle,
    this.animation,
  });

  final Conversation conversation;

  final int? visibleLines;
  final TextStyle? textStyle;
  final TextStyle? linkStyle;
  final bool? animation;

  @override
  Widget build(BuildContext context) {
    return ExpandableText(
      conversation.answer,
      expandText: "",
      animation: animation ?? true,
      maxLines: visibleLines ?? 4,
      linkStyle: linkStyle ??
          Theme.of(context).textTheme.bodyMedium!.copyWith(color: kLinkColor),
      textAlign: TextAlign.left,
      style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
      linkEllipsis: true,
    );
  }
}
