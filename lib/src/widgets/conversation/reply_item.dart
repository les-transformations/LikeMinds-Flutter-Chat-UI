import 'package:flutter/material.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_ui_fl/src/utils/helpers.dart';
import 'package:likeminds_chat_ui_fl/src/utils/theme.dart';
import 'package:likeminds_chat_ui_fl/src/utils/utils.dart';
import 'package:likeminds_chat_ui_fl/src/widgets/common/text/text_view.dart';

class LMReplyItem extends StatelessWidget {
  const LMReplyItem({
    super.key,
    required this.replyToConversation,
    this.backgroundColor,
    this.highlightColor,
    this.title,
    this.subtitle,
    this.borderRadius,
  });

  /// The conversation to which the reply is made
  /// This is a required field
  final Conversation? replyToConversation;

  /// Color of the reply item background
  final Color? backgroundColor;

  /// Color of the reply item highlight bar (on the left)
  final Color? highlightColor;

  /// Title widget of the reply item, if not provided, the name of the member
  /// Preferrably use a [LMTextView] widget, when providing a custom title
  final Widget? title;

  /// Subtitle widget of the reply item, if not provided, the text of reply
  /// Preferrably use a [LMTextView] widget, when providing a custom subtitle
  final Widget? subtitle;

  /// Border radius of the reply item
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    return replyToConversation != null
        ? Container(
            decoration: BoxDecoration(
              color: backgroundColor ?? kGreyColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(borderRadius ?? 8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 10),
                Container(
                  height: 3.6.h,
                  width: 1.w,
                  decoration: BoxDecoration(
                    color: highlightColor ?? kPrimaryColor,
                  ),
                ),
                kHorizontalPaddingMedium,
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      title ??
                          LMTextView(
                            text: replyToConversation!.member!.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textStyle: const TextStyle(
                              color: kPrimaryColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      kVerticalPaddingXSmall,
                      subtitle ??
                          LMTextView(
                            text: replyToConversation!.answer.isEmpty
                                ? "Media files"
                                : replyToConversation!.answer,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textStyle: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                            ),
                          ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
                kHorizontalPaddingMedium,
              ],
            ),
          )
        : const SizedBox();
  }
}
