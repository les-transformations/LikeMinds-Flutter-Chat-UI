import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_ui_fl/likeminds_chat_ui_fl.dart';
import 'package:likeminds_chat_ui_fl/src/utils/theme.dart';
import 'package:likeminds_chat_ui_fl/src/widgets/conversation/menu_item.dart';
import 'package:swipe_to_action/swipe_to_action.dart';

class LMChatBubble extends StatefulWidget {
  const LMChatBubble({
    super.key,
    required this.conversation,
    required this.sender,
    required this.currentUser,
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
    this.menu,
    this.menuController,
    this.menuItems,
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
    this.deletedText,
  });

  final Conversation conversation;
  final Conversation? replyingTo;
  final User sender;
  final User currentUser;

  final LMTextView? title;
  final LMChatContent? content;
  // final LMChatMeta? meta;
  final List<LMTextView>? footer;
  final LMProfilePicture? avatar;
  final LMIcon? replyIcon;
  final LMIconButton? reactionButton;
  final LMReplyItem? replyItem;
  final LMTextView? outsideTitle;
  final Widget? outsideFooter;
  final Widget? mediaWidget;
  // final LMReactionBar? reactionBar;

  final CustomPopupMenuController? menuController;
  final Widget? menu;
  final List<LMMenuItem>? menuItems;
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

  final LMTextView? deletedText;

  @override
  State<LMChatBubble> createState() => _LMChatBubbleState();
}

class _LMChatBubbleState extends State<LMChatBubble> {
  Conversation? conversation;
  Conversation? replyingTo;
  User? sender;
  User? currentUser;
  late CustomPopupMenuController _menuController;

  bool isSent = false;
  bool isDeleted = false;
  bool isEdited = false;

  @override
  void initState() {
    super.initState();
    isSent = widget.isSent ?? false;
    conversation = widget.conversation;
    sender = widget.sender;
    currentUser = widget.currentUser;
    replyingTo = widget.replyingTo;
    isEdited = widget.conversation.isEdited ?? false;
    isDeleted = widget.conversation.deletedByUserId != null;
    _menuController = CustomPopupMenuController();
  }

  @override
  void didUpdateWidget(LMChatBubble oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
      conversation = widget.conversation;
      sender = widget.sender;
      replyingTo = widget.replyingTo;
      currentUser = widget.currentUser;
      isEdited = widget.conversation.isEdited ?? false;
      isDeleted = widget.conversation.deletedByUserId != null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // return GestureDetector(
    //   behavior: HitTestBehavior.opaque,
    //   onLongPress: () {
    //     debugPrint("Long Pressed");
    //     if (isDeleted) return;
    //     // widget.menuController.showMenu();
    //     // widget.onLongPress !=null ? widget.onLongPress!(conversation) : {};
    //   },
    //   onTap: () {
    //     debugPrint("Tapped");
    //     if (isDeleted) return;
    //     // _controller.hideMenu();
    //   },
    //   child:
    return Swipeable(
      dismissThresholds: const {SwipeDirection.startToEnd: 0.2},
      movementDuration: const Duration(milliseconds: 50),
      key: ValueKey(conversation!.id),
      onSwipe: (direction) {
        if (widget.onReply != null) {
          widget.onReply!(conversation!);
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
                  left: widget.avatar != null ? 48.0 : 28.0,
                ),
                child: widget.outsideTitle ?? const SizedBox(),
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
                child: Row(
                  mainAxisAlignment:
                      isSent ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    !isSent
                        ? widget.avatar ?? const SizedBox()
                        : const SizedBox(),
                    const SizedBox(width: 4),
                    AbsorbPointer(
                      absorbing: isDeleted,
                      child: CustomPopupMenu(
                        controller: _menuController,
                        pressType: PressType.longPress,
                        showArrow: false,
                        verticalMargin: 2.h,
                        horizontalMargin: isSent ? 2.w : 18.w,
                        menuBuilder: () => !isDeleted
                            ? GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  debugPrint("Menu object tapped");
                                },
                                child: widget.menu ??
                                    ClipRRect(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        constraints: BoxConstraints(
                                          minWidth: 42.w,
                                          maxWidth: 60.w,
                                        ),
                                        child: IntrinsicWidth(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.stretch,
                                            children: [
                                              for (LMMenuItem menuItem
                                                  in widget.menuItems!)
                                                ListTile(
                                                  onTap: () {
                                                    menuItem.onTap();
                                                    _menuController.hideMenu();
                                                  },
                                                  leading: menuItem.leading,
                                                  title: menuItem.title,
                                                  splashColor: Colors.grey
                                                      .withOpacity(0.5),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                              )
                            : const SizedBox(),
                        child: Container(
                          constraints: BoxConstraints(
                            minHeight: 4.h,
                            minWidth: 10.w,
                            maxWidth: 60.w,
                          ),
                          padding: EdgeInsets.all(
                            widget.mediaWidget != null ? 8.0 : 12.0,
                          ),
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
                                      : const SizedBox.shrink()
                                  : isDeleted
                                      ? const SizedBox.shrink()
                                      : widget.replyItem!,
                              replyingTo != null
                                  ? const SizedBox(height: 8)
                                  : const SizedBox.shrink(),
                              isSent
                                  ? const SizedBox()
                                  : widget.title ?? const SizedBox.shrink(),
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
                                  ? const SizedBox.shrink()
                                  : ((widget.mediaWidget != null &&
                                              widget.content != null) ||
                                          widget.conversation.hasFiles!)
                                      ? Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 0, horizontal: 0),
                                          child: widget.mediaWidget,
                                        )
                                      : const SizedBox(),
                              isDeleted
                                  ? widget.deletedText != null
                                      ? widget.deletedText!
                                      : conversation!.deletedByUserId ==
                                              conversation!.userId
                                          ? LMTextView(
                                              text: currentUser!.id ==
                                                      conversation!
                                                          .deletedByUserId
                                                  ? "You deleted this message"
                                                  : "This message was deleted",
                                              textStyle: widget
                                                  .content!.textStyle!
                                                  .copyWith(
                                                fontStyle: FontStyle.italic,
                                              ),
                                            )
                                          : LMTextView(
                                              text:
                                                  "This message was deleted by a community managers",
                                              textStyle: widget
                                                  .content!.textStyle!
                                                  .copyWith(
                                                fontStyle: FontStyle.italic,
                                              ),
                                            )
                                  : replyingTo != null
                                      ? Align(
                                          alignment: Alignment.topLeft,
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              top: widget.mediaWidget != null
                                                  ? 4.0
                                                  : 0,
                                            ),
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
                                          ),
                                        )
                                      : Padding(
                                          padding: EdgeInsets.only(
                                              top: widget.mediaWidget != null
                                                  ? 4.0
                                                  : 0),
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
                                                visibleLines: 4,
                                                animation: true,
                                              ),
                                        ),
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
                                      boxSize: 18,
                                      boxPadding: 6,
                                    ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    isSent
                        ? widget.avatar ?? const SizedBox()
                        : const SizedBox(),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(
                  right: widget.avatar != null ? 48.0 : 24.0,
                  left: widget.avatar != null ? 48.0 : 28.0,
                ),
                child: widget.outsideFooter ?? const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
    // );
  }
}
