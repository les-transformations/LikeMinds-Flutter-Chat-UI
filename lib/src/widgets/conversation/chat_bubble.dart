import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_ui_fl/likeminds_chat_ui_fl.dart';
import 'package:likeminds_chat_ui_fl/src/utils/helpers.dart';
import 'package:likeminds_chat_ui_fl/src/utils/theme.dart';
import 'package:swipe_to_action/swipe_to_action.dart';

class LMChatBubble extends StatefulWidget {
  const LMChatBubble({
    super.key,
    required this.conversation,
    required this.sender,
    this.title,
    this.content,
    // this.meta,
    this.footer,
    this.avatar,
    this.replyingTo,
    this.replyIcon,
    this.reactionButton,
    this.outsideTitle,
    this.outsideFooter,
    // this.replyItem,
    // this.reactionBar,
    required this.menu,
    required this.menuController,
    this.onReply,
    this.onEdit,
    this.onLongPress,
    this.width,
    this.height,
    this.borderWidth,
    this.borderRadius,
    this.borderRadiusNum,
    this.borderColor,
    this.backgroundColor,
    this.sentColor,
    this.isSent,
    this.showActions,
    this.replyItem,
    this.mediaWidget,
  });

  final Conversation conversation;
  final Conversation? replyingTo;
  final User sender;

  final LMTextView? title;
  final LMChatContent? content;
  // final LMChatMeta? meta;
  final List<LMTextView>? footer;
  final LMProfilePicture? avatar;
  final LMIcon? replyIcon;
  final LMIconButton? reactionButton;
  final LMReplyItem? replyItem;
  final LMTextView? outsideTitle;
  final LMTextView? outsideFooter;
  final Widget? mediaWidget;
  // final LMReactionBar? reactionBar;

  final CustomPopupMenuController menuController;
  final Widget menu;

  final Function(Conversation replyingTo)? onReply;
  final Function(Conversation editConversation)? onEdit;
  final Function(Conversation conversation)? onLongPress;

  final double? width;
  final double? height;
  final double? borderWidth;
  final double? borderRadiusNum;

  final BorderRadius? borderRadius;

  final Color? borderColor;
  final Color? backgroundColor;
  final Color? sentColor;

  final bool? isSent;
  final bool? showActions;

  @override
  State<LMChatBubble> createState() => _LMChatBubbleState();
}

class _LMChatBubbleState extends State<LMChatBubble> {
  late Conversation conversation;
  late Conversation? replyingTo;
  late User sender;
  late CustomPopupMenuController _controller;
  // late User loggedInUser;

  bool isSent = false;
  bool isDeleted = false;
  bool isEdited = false;

  @override
  void initState() {
    super.initState();
    isSent = widget.isSent ?? false;
    conversation = widget.conversation;
    sender = widget.sender;
    replyingTo = widget.replyingTo;
    isEdited = widget.conversation.isEdited ?? false;
    isDeleted = widget.conversation.deletedByUserId != null;
    _controller = widget.menuController;
  }

  @override
  void didUpdateWidget(LMChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.conversation != widget.conversation) {
      setState(() {
        conversation = widget.conversation;
        isEdited = widget.conversation.isEdited ?? false;
        isDeleted = widget.conversation.deletedByUserId != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () {
        debugPrint("Long Pressed");
        if (isDeleted) return;
        // _controller.showMenu();
      },
      onTap: () {
        debugPrint("Tapped");
        if (isDeleted) return;
        // _controller.hideMenu();
      },
      child: Swipeable(
        dismissThresholds: const {SwipeDirection.startToEnd: 0.2},
        movementDuration: const Duration(milliseconds: 50),
        key: ValueKey(conversation.id),
        onSwipe: (direction) {
          if (widget.onReply != null) {
            widget.onReply!(conversation);
          }
        },
        background: Padding(
          padding: EdgeInsets.only(
            left: 2.w,
            right: 2.w,
            top: 0.2.h,
            bottom: 0.2.h,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              widget.replyIcon ??
                  const LMIcon(
                    type: LMIconType.icon,
                    icon: Icons.reply_outlined,
                    color: kLinkColor,
                    size: 28,
                    boxSize: 28,
                    boxPadding: 0,
                  ),
            ],
          ),
        ),
        direction: SwipeDirection.startToEnd,
        child: CustomPopupMenu(
          controller: _controller,
          pressType: PressType.longPress,
          showArrow: false,
          verticalMargin: 1.h,
          menuBuilder: () => widget.menu,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                crossAxisAlignment:
                    isSent ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  SizedBox(height: widget.outsideTitle != null ? 10 : 0),
                  Padding(
                    padding: EdgeInsets.only(
                      left: widget.avatar != null ? 56.0 : 32.0,
                    ),
                    child: widget.outsideTitle ?? const SizedBox(),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 0.5.h,
                    ),
                    child: Row(
                      mainAxisAlignment: isSent
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        !isSent
                            ? widget.avatar ?? const SizedBox()
                            // LMProfilePicture(
                            //     fallbackText: widget.sender.name,
                            //     imageUrl: widget.sender.imageUrl,
                            //     size: 32,
                            //   )
                            : const SizedBox(),
                        const SizedBox(width: 8),
                        Container(
                          constraints: BoxConstraints(
                            minHeight: 4.h,
                            minWidth: 10.w,
                            maxWidth: 60.w,
                          ),
                          padding: const EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            color: widget.backgroundColor ?? Colors.white,
                            borderRadius: widget.borderRadius ??
                                BorderRadius.circular(
                                  widget.borderRadiusNum ?? 6,
                                ),
                          ),
                          child: Column(
                            crossAxisAlignment: isSent
                                ? CrossAxisAlignment.end
                                : CrossAxisAlignment.start,
                            children: [
                              Visibility(
                                visible: replyingTo != null && !isDeleted,
                                maintainState: true,
                                maintainSize: false,
                                child: const SizedBox(),
                              ),
                              widget.replyItem == null
                                  ? replyingTo != null
                                      ? isDeleted
                                          ? const SizedBox.shrink()
                                          : LMReplyItem(
                                              replyToConversation: replyingTo!,
                                              backgroundColor: Colors.white,
                                              highlightColor: Theme.of(context)
                                                  .primaryColor,
                                              title: LMTextView(
                                                text: replyingTo!.member!.name,
                                                textStyle: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              subtitle: LMTextView(
                                                text: replyingTo!.answer,
                                                textStyle: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            )
                                      : const SizedBox()
                                  : isDeleted
                                      ? const SizedBox.shrink()
                                      : widget.replyItem!,
                              replyingTo != null
                                  ? const SizedBox(height: 8)
                                  : const SizedBox(),
                              isSent
                                  ? const SizedBox()
                                  : widget.title ?? const SizedBox(),
                              // LMTextView(
                              //   text: widget.sender.name,
                              //   textStyle: TextStyle(
                              //     fontSize: 12,
                              //     color: isSent
                              //         ? Colors.black.withOpacity(0.6)
                              //         : widget.sentColor ??
                              //             Theme.of(context).primaryColor,
                              //   ),
                              // ),
                              isDeleted
                                  ? conversation.deletedByUserId ==
                                          conversation.userId
                                      ? LMTextView(
                                          text: conversation.userId == 1
                                              ? 'You deleted this message'
                                              : "This message was deleted",
                                          textStyle: widget.content!.textStyle!
                                              .copyWith(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        )
                                      : LMTextView(
                                          text:
                                              "This message was deleted by the Community Manager",
                                          textStyle: widget.content!.textStyle!
                                              .copyWith(
                                            fontStyle: FontStyle.italic,
                                          ),
                                        )
                                  : replyingTo != null
                                      ? Align(
                                          alignment: Alignment.topLeft,
                                          child: widget.content ??
                                              LMChatContent(
                                                conversation:
                                                    widget.conversation,
                                                linkStyle: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                textStyle: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                        )
                                      : widget.content ??
                                          LMChatContent(
                                            conversation: widget.conversation,
                                            linkStyle: TextStyle(
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            textStyle: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400,
                                            ),
                                            visibleLines: 2,
                                            animation: true,
                                          ),
                              if (widget.mediaWidget != null && !isDeleted)
                                const SizedBox(height: 8),
                              isDeleted
                                  ? const SizedBox.shrink()
                                  : widget.mediaWidget ?? const SizedBox(),
                              if (widget.mediaWidget != null && !isDeleted)
                                const SizedBox(height: 8),
                              if (widget.footer != null &&
                                  widget.footer!.isNotEmpty &&
                                  !isDeleted)
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: widget.footer!,
                                ),
                              ((widget.conversation.hasFiles == null ||
                                          !widget.conversation.hasFiles!) ||
                                      (widget.conversation
                                                  .attachmentsUploaded !=
                                              null &&
                                          widget.conversation
                                              .attachmentsUploaded!) ||
                                      isDeleted)
                                  ? const SizedBox()
                                  : const LMIcon(
                                      type: LMIconType.icon,
                                      icon: Icons.timer_outlined,
                                      size: 12,
                                    ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        isSent
                            ? widget.avatar ?? const SizedBox()
                            // LMProfilePicture(
                            //     fallbackText: widget.sender.name,
                            //     imageUrl: widget.sender.imageUrl,
                            //     size: 32,
                            //   )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      right: widget.avatar != null ? 56.0 : 32.0,
                      left: widget.avatar != null ? 56.0 : 32.0,
                    ),
                    child: widget.outsideFooter ?? const SizedBox(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
