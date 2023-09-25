import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_ui_fl/likeminds_chat_ui_fl.dart';
import 'package:likeminds_chat_ui_fl/src/utils/constants.dart';
import 'package:likeminds_chat_ui_fl/src/utils/theme.dart';

class LMChatRoomTopic extends StatelessWidget {
  const LMChatRoomTopic({
    super.key,
    this.conversation,
    required this.onTap,
    this.leading,
    this.trailing,
    this.title,
    this.subTitle,
    this.date,
  });

  final Conversation? conversation;
  final VoidCallback onTap;
  final Widget? leading;
  final Widget? trailing;
  final LMTextView? title;
  final LMTextView? subTitle;
  final LMTextView? date;

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
      height: 90,
      decoration: const BoxDecoration(
        color: kWhiteColor,
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(children: [
            conversation != null
                ? LMProfilePicture(
                    fallbackText: conversation!.member!.name,
                    imageUrl: conversation!.member?.imageUrl,
                    size: 36,
                  )
                : leading ?? const SizedBox.shrink(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 150),
                          child: conversation != null
                              ? LMTextView(
                                  text: conversation!.member!.name,
                                  overflow: TextOverflow.ellipsis,
                                  textStyle: const TextStyle(
                                    color: kPrimaryColor,
                                    fontSize: 14,
                                  ),
                                )
                              : title,
                        ),
                        kHorizontalPaddingXSmall,
                        conversation != null
                            ? LMTextView(
                                text: "\u25CF ${conversation!.date}",
                                textStyle: const TextStyle(
                                  color: kGrey3Color,
                                  // fontSize: 16
                                ),
                              )
                            : date ?? const SizedBox.shrink(),
                      ],
                    ),
                    conversation != null
                        ? Text.rich(
                            TextSpan(
                              children: [
                                WidgetSpan(
                                  child: generateIcon(conversation!),
                                ),
                                TextSpan(
                                  text: generateSubtext(conversation!),
                                )
                              ],
                            ),
                            maxLines: 2,
                            style: const TextStyle(
                                overflow: TextOverflow.ellipsis),
                          )
                        : subTitle!,
                  ],
                ),
              ),
            ),
            if (((conversation != null && conversation!.ogTags != null) ||
                    ((conversation!.attachments != null &&
                            conversation!.attachments!.isNotEmpty)) &&
                        (conversation!.attachments!.first.type !=
                            kAttachmentTypePDF)) &&
                (conversation!.ogTags != null &&
                    conversation!.ogTags?['image'] != null))
              Align(
                alignment: Alignment.centerRight,
                child: conversation != null
                    ? LMImage(
                        imageFile:
                            conversation!.attachments?.first.attachmentFile,
                        imageUrl:
                            conversation!.attachments?.first.thumbnailUrl ??
                                conversation!.attachments?.first.url ??
                                conversation!.ogTags?['image'],
                        width: 65,
                        height: 65,
                      )
                    : trailing,
              )
          ]),
        ),
      ),
    );
  }
}

Attachment? attachment;
