import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_ui_fl/likeminds_chat_ui_fl.dart';
import 'package:likeminds_chat_ui_fl/src/utils/theme.dart';

class LMGroupDetailBottomSheet extends StatefulWidget {
  final ChatRoom chatRoom;
  const LMGroupDetailBottomSheet({
    super.key,
    required this.chatRoom,
  });

  @override
  State<LMGroupDetailBottomSheet> createState() =>
      _LMGroupDetailBottomSheetState();
}

class _LMGroupDetailBottomSheetState extends State<LMGroupDetailBottomSheet> {
  late ChatRoom chatRoom;

  @override
  void initState() {
    chatRoom = widget.chatRoom;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: 90.h,
        width: 100.w,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              offset: const Offset(0, -4),
              blurRadius: 8.0,
              spreadRadius: 4.0,
            )
          ],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
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
                  decoration: const BoxDecoration(
                    color: kGrey2Color,
                    borderRadius: BorderRadius.all(
                      Radius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const LMTextView(
                  text: "Group Info",
                  textStyle: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    chatRoom.chatroomImageUrl != null &&
                            chatRoom.chatroomImageUrl!.isNotEmpty
                        ? CachedNetworkImage(
                            width: 100.w,
                            height: 36.h,
                            fit: BoxFit.cover,
                            imageUrl: chatRoom.chatroomImageUrl ??
                                "https://placehold.co/600x400/000000/FFF?text=Chatroom",
                          )
                        : Container(
                            height: 36.h,
                            color: Colors.white,
                          ),
                    Container(
                      height: 36.h,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
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
                          child: LMTextView(
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
                const SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const LMTextView(
                        text: "Description",
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LMTextView(
                        text: chatRoom.title,
                        textStyle: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )),
      ),
    );
  }
}
