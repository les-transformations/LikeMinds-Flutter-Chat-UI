import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_ui_fl/likeminds_chat_ui_fl.dart';
import 'package:likeminds_chat_ui_fl/src/utils/constants.dart';
import 'package:likeminds_chat_ui_fl/src/utils/theme.dart';

class LMChatRoomTopic extends StatelessWidget {
  const LMChatRoomTopic(
      {super.key,
      this.conversation,
      required this.onTap,
      this.leading,
      this.trailing,
      this.title,
      this.subTitle,
      this.date,
      this.backGroundColor});

  final Conversation? conversation;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;
  final LMTextView? title;
  final LMTextView? subTitle;
  final LMTextView? date;
  final Color? backGroundColor;

  Widget generateIcon(Conversation conversation) {
    Widget? icon;
    if (conversation.attachments == null) {
      if (conversation.ogTags != null) icon = const Icon(Icons.link);
    } else {
      switch (conversation.attachments!.first.type) {
        case kAttachmentTypeImage:
          icon = const Icon(Icons.image);
          break;
        case kAttachmentTypeVideo:
          icon = const Icon(Icons.videocam);
          break;
        case kAttachmentTypePDF:
          icon = const Icon(Icons.insert_drive_file_outlined);
          break;
      }
    }
    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          kHorizontalPaddingXSmall,
          icon,
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  String generateSubtext(Conversation conversation) {
    if (conversation.answer.isNotEmpty) {
      return conversation.answer;
    }

    String subText = "";
    if (conversation.attachments != null) {
      log(conversation.attachments!.first.type.toString());
      switch (conversation.attachments!.first.type) {
        case kAttachmentTypeImage:
          subText = "Photo";
          break;
        case kAttachmentTypeVideo:
          subText = "Video";
          break;
        case kAttachmentTypePDF:
          subText = conversation.attachments!.first.name ?? "Document";
          break;
      }
    }
    return subText;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 65,
      decoration: BoxDecoration(
        color: backGroundColor ?? kWhiteColor,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(children: [
            leading != null
                ? leading!
                : conversation != null
                    ? LMProfilePicture(
                        fallbackText: conversation!.member!.name,
                        imageUrl: conversation!.member?.imageUrl,
                        size: 36,
                      )
                    : const SizedBox.shrink(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        title != null
                            ? title!
                            : conversation != null
                                ? LMTextView(
                                    text: conversation!.member!.name,
                                    overflow: TextOverflow.ellipsis,
                                    textStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : const SizedBox.shrink(),
                        kHorizontalPaddingXSmall,
                        conversation != null
                            ? LMTextView(
                                text: "\u25CF ${conversation!.date}",
                                textStyle: const TextStyle(
                                  color: kGrey2Color,
                                  // fontSize: 16
                                ),
                              )
                            : date ?? const SizedBox.shrink(),
                      ],
                    ),
                    conversation != null
                        ? Text.rich(
                            TextSpan(
                              style: const TextStyle(
                                fontSize: 13,
                              ),
                              children: [
                                // WidgetSpan(
                                //   child: generateIcon(conversation!),
                                // ),
                                TextSpan(
                                  text: generateSubtext(conversation!),
                                )
                              ],
                            ),
                            maxLines: 1,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis),
                          )
                        : subTitle!,
                  ],
                ),
              ),
            ),
            trailing != null
                ? trailing!
                : (((conversation != null && conversation!.ogTags != null) ||
                            ((conversation!.attachments != null &&
                                    conversation!.attachments!.isNotEmpty)) &&
                                (conversation!.attachments!.first.type !=
                                    kAttachmentTypePDF)) &&
                        (conversation!.ogTags != null &&
                            conversation!.ogTags?['image'] != null))
                    ? Align(
                        alignment: Alignment.centerRight,
                        child: LMImage(
                          imageFile:
                              conversation!.attachments?.first.attachmentFile,
                          imageUrl:
                              conversation!.attachments?.first.thumbnailUrl ??
                                  conversation!.attachments?.first.url ??
                                  conversation!.ogTags?['image'],
                          width: 65,
                          height: 65,
                        ),
                      )
                    : const SizedBox.shrink()
          ]),
        ),
      ),
    );
  }
}

Attachment? attachment;
