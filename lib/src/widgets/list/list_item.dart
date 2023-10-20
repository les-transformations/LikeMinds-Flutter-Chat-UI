import 'package:flutter/material.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_ui_fl/likeminds_chat_ui_fl.dart';
import 'package:likeminds_chat_ui_fl/src/utils/theme.dart';

class LMListItem extends StatelessWidget {
  const LMListItem({
    super.key,
    this.chatroom,
    this.user,
    this.trailing,
    this.title,
    this.subtitle,
    this.avatar,
    this.avatarWidget,
    this.onTap,
    this.divider,
    this.height,
    this.width,
    this.padding,
  });

  final ChatRoom? chatroom;
  final User? user;

  final LMTextView? title;
  final Widget? subtitle;

  final LMProfilePicture? avatar;
  final Widget? avatarWidget;

  final Widget? trailing;

  final VoidCallback? onTap;
  final Divider? divider;

  final double? height;
  final double? width;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: Padding(
              padding: padding ??
                  EdgeInsets.only(
                    left: 5.w,
                    right: 5.w,
                    // top: 1.h,
                  ),
              child: SizedBox(
                width: width ?? ScreenSize.width,
                height: height ?? 10.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    avatar ??
                        Container(
                          height: 32,
                          width: 32,
                          color: Colors.red,
                        ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: title ??
                                      LMTextView(
                                        text: chatroom?.header ??
                                            "Dummy Title Text",
                                        textStyle:
                                            const TextStyle(fontSize: 12),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            subtitle ??
                                const LMTextView(
                                  text: "Dummy Subtitle Text",
                                  textStyle: TextStyle(fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                          ],
                        ),
                      ),
                    ),
                    trailing ??
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const LMTextView(
                              text: "32:32",
                              textStyle: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Visibility(
                              visible: true,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: kPrimaryColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Center(
                                  child: LMTextView(
                                    text: '4',
                                    textStyle: TextStyle(
                                      color: kWhiteColor,
                                      fontSize: 10,
                                    ),
                                    backgroundColor: kPrimaryColor,
                                    borderRadius: 20,
                                    padding: EdgeInsets.all(8),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                  ],
                ),
              ),
            ),
          ),
          divider ?? const SizedBox(),
        ],
      ),
    );
  }
}
