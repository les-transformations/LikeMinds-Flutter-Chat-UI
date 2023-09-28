import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_ui_fl/likeminds_chat_ui_fl.dart';
import 'package:likeminds_chat_ui_fl/src/utils/theme.dart';

class LMGroupDetailBottomSheet extends StatelessWidget {
  // Required model variable
  final ChatRoom chatRoom;

  //Customisability variables
  final LMTextView? title;
  final LMTextView? description;
  final LMTextView? descriptionHeading;

  final double? maxHeight;
  final double? borderRadius;

  final Color? backgroundColor;
  final Color? shadowColor;
  final Color? swipeChipColor;
  final LinearGradient? overlayGradient;

  const LMGroupDetailBottomSheet({
    super.key,
    required this.chatRoom,
    this.title,
    this.description,
    this.descriptionHeading,
    this.maxHeight,
    this.borderRadius,
    this.backgroundColor,
    this.shadowColor,
    this.swipeChipColor,
    this.overlayGradient,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: maxHeight ?? 90.h,
        width: 100.w,
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white,
          boxShadow: [
            BoxShadow(
              color: shadowColor ?? Colors.black.withOpacity(0.2),
              offset: const Offset(0, -4),
              blurRadius: 8.0,
              spreadRadius: 4.0,
            )
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(borderRadius ?? 8),
            topRight: Radius.circular(borderRadius ?? 8),
          ),
        ),
        child: Padding(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 10),
                Container(
                  height: 0.6.h,
                  width: 10.w,
                  decoration: BoxDecoration(
                    color: swipeChipColor ?? kGrey2Color,
                    borderRadius: const BorderRadius.all(
                      Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const LMTextView(
                  text: "Group Info",
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    LMProfilePicture(
                      fallbackText: chatRoom.header,
                      imageUrl: chatRoom.chatroomImageUrl,
                      borderRadius: 0,
                      size: 48.h,
                    ),
                    Container(
                      height: 48.h,
                      decoration: BoxDecoration(
                        gradient: overlayGradient ??
                            const LinearGradient(
                              colors: [
                                Colors.black,
                                Colors.transparent,
                                Colors.transparent,
                                Colors.black
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              stops: [0, 0, 0.6, 1],
                            ),
                      ),
                    ),
                    Positioned(
                        bottom: 18,
                        left: 18,
                        right: 18,
                        child: Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: title ??
                              LMTextView(
                                text: chatRoom.header,
                                overflow: TextOverflow.ellipsis,
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                        ))
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        descriptionHeading ??
                            const LMTextView(
                              text: "Description",
                              textStyle: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        const SizedBox(height: 8),
                        description ??
                            LMTextView(
                              text: chatRoom.title,
                              textStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                      ],
                    ),
                  ),
                )
              ],
            )),
      ),
    );
  }
}
