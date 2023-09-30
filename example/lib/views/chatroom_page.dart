import 'package:custom_pop_up_menu/custom_pop_up_menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui_sample/bloc/chatroom/chatroom_bloc.dart';
import 'package:flutter_chat_ui_sample/bloc/chatroom_action/chatroom_action_bloc.dart';
import 'package:flutter_chat_ui_sample/bloc/conversation/conversation_bloc.dart';
import 'package:flutter_chat_ui_sample/bloc/conversation_action/conversation_action_bloc.dart';
import 'package:flutter_chat_ui_sample/bloc/home/home_bloc.dart';
import 'package:flutter_chat_ui_sample/navigation/router.dart';
import 'package:flutter_chat_ui_sample/service/likeminds_service.dart';
import 'package:flutter_chat_ui_sample/service/media_service.dart';
import 'package:flutter_chat_ui_sample/service/preference_service.dart';
import 'package:flutter_chat_ui_sample/service/service_locator.dart';
import 'package:flutter_chat_ui_sample/utils/analytics/analytics.dart';
import 'package:flutter_chat_ui_sample/utils/chatroom/conversation_utils.dart';
import 'package:flutter_chat_ui_sample/utils/constants/asset_constants.dart';
import 'package:flutter_chat_ui_sample/utils/constants/ui_constants.dart';
import 'package:flutter_chat_ui_sample/utils/media/media_helper.dart';
import 'package:flutter_chat_ui_sample/utils/media/media_utils.dart';
import 'package:flutter_chat_ui_sample/utils/simple_bloc_observer.dart';
import 'package:flutter_chat_ui_sample/utils/tagging/helpers/tagging_helper.dart';
import 'package:flutter_chat_ui_sample/utils/ui_utils.dart';
import 'package:flutter_chat_ui_sample/widgets/chat_bar.dart';
import 'package:flutter_chat_ui_sample/widgets/chatroom_menu.dart';
import 'package:flutter_chat_ui_sample/widgets/chatroom_skeleton.dart';
import 'package:flutter_chat_ui_sample/widgets/media/document/document_preview_factory.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';
import 'package:likeminds_chat_ui_fl/likeminds_chat_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({
    super.key,
    required this.chatroomId,
  });

  final int chatroomId;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  late ConversationBloc _conversationBloc;
  late ConversationActionBloc _convActionBloc;
  late ChatroomBloc _chatroomBloc;
  late ChatroomActionBloc _chatroomActionBloc;

  ChatRoom? chatroom;
  User? user;

  int currentTime = DateTime.now().millisecondsSinceEpoch;
  Map<String, List<Media>> conversationAttachmentsMeta =
      <String, List<Media>>{};
  Map<String, List<Media>> mediaFiles = <String, List<Media>>{};
  Map<int, User?> userMeta = <int, User?>{};

  bool showScrollButton = false;
  int lastConversationId = 0;
  List<Conversation> selectedConversations = <Conversation>[];
  final CustomPopupMenuController _customMenuController =
      CustomPopupMenuController();

  ValueNotifier rebuildConversationList = ValueNotifier(false);
  ValueNotifier rebuildChatBar = ValueNotifier(false);
  ValueNotifier showConversationActions = ValueNotifier(false);

  ScrollController scrollController = ScrollController();
  PagingController<int, Conversation> pagedListController =
      PagingController<int, Conversation>(firstPageKey: 1);

  int _page = 1;

  @override
  void initState() {
    super.initState();
    Bloc.observer = SimpleBlocObserver();
    _addPaginationListener();
    scrollController.addListener(() {
      _showScrollToBottomButton();
    });
    // chatActionBloc = BlocProvider.of<ChatActionBloc>(context);
    // conversationBloc = ConversationBloc();
    user = locator<LMPreferenceService>().getUser();
    _conversationBloc = BlocProvider.of<ConversationBloc>(context);
    _chatroomBloc = BlocProvider.of<ChatroomBloc>(context);
    _convActionBloc = BlocProvider.of<ConversationActionBloc>(context);
    _chatroomActionBloc = BlocProvider.of<ChatroomActionBloc>(context);
  }

  _addPaginationListener() {
    pagedListController.addPageRequestListener(
      (pageKey) {
        _conversationBloc.add(
          LoadConversations(
            getConversationRequest: (GetConversationRequestBuilder()
                  ..chatroomId(widget.chatroomId)
                  ..page(pageKey)
                  ..pageSize(500)
                  ..minTimestamp(0)
                  ..maxTimestamp(currentTime))
                .build(),
          ),
        );
      },
    );
  }

  void _scrollToBottom() {
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void _showScrollToBottomButton() {
    if (scrollController.position.pixels >
        scrollController.position.viewportDimension) {
      _showButton();
    }
    if (scrollController.position.pixels <
        scrollController.position.viewportDimension) {
      _hideButton();
    }
  }

  void _showButton() {
    setState(() {
      showScrollButton = true;
    });
  }

  void _hideButton() {
    setState(() {
      showScrollButton = false;
    });
  }

  void updatePagingControllers(ConversationState state) {
    if (state is ConversationLoaded) {
      _page++;

      if (state.getConversationResponse.conversationAttachmentsMeta != null &&
          state.getConversationResponse.conversationAttachmentsMeta!
              .isNotEmpty) {
        Map<String, List<Media>> getConversationAttachmentData = state
            .getConversationResponse.conversationAttachmentsMeta!
            .map((key, value) {
          return MapEntry(
            key,
            (value as List<dynamic>?)?.map((e) => Media.fromJson(e)).toList() ??
                [],
          );
        });
        conversationAttachmentsMeta.addAll(getConversationAttachmentData);
      }

      if (state.getConversationResponse.userMeta != null) {
        userMeta.addAll(state.getConversationResponse.userMeta!);
      }
      List<Conversation>? conversationData =
          state.getConversationResponse.conversationData;
      filterOutStateMessage(conversationData!);
      conversationData = addTimeStampInConversationList(
          conversationData, chatroom!.communityId!);
      if (state.getConversationResponse.conversationData == null ||
          state.getConversationResponse.conversationData!.isEmpty ||
          state.getConversationResponse.conversationData!.length < 500) {
        pagedListController.appendLastPage(conversationData ?? []);
      } else {
        pagedListController.appendPage(conversationData!, _page);
      }
    }
    if (state is ConversationPosted) {
      addConversationToPagedList(
        state.postConversationResponse.conversation!,
      );
    } else if (state is MultiMediaConversationLoading) {
      if (!userMeta.containsKey(user!.id)) {
        userMeta[user!.id] = user;
      }
      mediaFiles[state.postConversation.temporaryId!] = state.mediaFiles;

      List<Conversation> conversationList =
          pagedListController.itemList ?? <Conversation>[];

      conversationList.insert(0, state.postConversation);

      rebuildConversationList.value = !rebuildConversationList.value;
    } else if (state is MultiMediaConversationPosted) {
      addMultiMediaConversation(
        state,
      );
    } else if (state is ConversationError) {
      toast(state.message);
    }
    // if (state is UpdateConversations) {
    //                             if (state.response.id != lastConversationId) {
    //                               addConversationToPagedList(
    //                                 state.response,
    //                               );
    //                               lastConversationId = state.response.id;
    //                             }
    //                           }
  }

  bool checkDeletePermissions(Conversation conversation) {
    final MemberStateResponse isCm =
        locator<LMPreferenceService>().getMemberRights()!;

    if (isCm.member?.state == 1 && conversation.deletedByUserId == null) {
      return true;
    } else if (user!.id == conversation.userId &&
        conversation.deletedByUserId == null) {
      return true;
    } else {
      return false;
    }
  }

  bool checkEditPermissions(Conversation conversation) {
    if (conversation.answer.isEmpty) {
      return false;
    } else if (user!.id == conversation.userId &&
        conversation.deletedByUserId == null) {
      return true;
    }
    return false;
  }

  void addLocalConversationToPagedList(Conversation conversation) {
    List<Conversation> conversationList =
        pagedListController.itemList ?? <Conversation>[];

    conversationList.insert(0, conversation);
    if (conversationList.length >= 500) {
      conversationList.removeLast();
    }
    if (!userMeta.containsKey(user!.id)) {
      userMeta[user!.id] = user;
    }

    pagedListController.itemList = conversationList;
    rebuildConversationList.value = !rebuildConversationList.value;
  }

  void updateEditedConversation(Conversation editedConversation) {
    List<Conversation> conversationList =
        pagedListController.itemList ?? <Conversation>[];
    int index = conversationList
        .indexWhere((element) => element.id == editedConversation.id);
    if (index != -1) {
      conversationList[index] = editedConversation;
    }
    pagedListController.itemList = conversationList;
    rebuildConversationList.value = !rebuildConversationList.value;
  }

  void addConversationToPagedList(Conversation conversation) {
    List<Conversation> conversationList =
        pagedListController.itemList ?? <Conversation>[];

    int index = conversationList.indexWhere(
        (element) => element.temporaryId == conversation.temporaryId);
    if (index != -1) {
      conversationList[index] = conversation;
    } else {
      if (conversationList.first.date != conversation.date) {
        conversationList.insert(
          0,
          Conversation(
            isTimeStamp: true,
            id: 1,
            hasFiles: false,
            attachmentCount: 0,
            attachmentsUploaded: false,
            createdEpoch: conversation.createdEpoch,
            chatroomId: chatroom!.id,
            date: conversation.date,
            memberId: conversation.memberId,
            userId: conversation.userId,
            temporaryId: conversation.temporaryId,
            answer: conversation.date ?? '',
            communityId: chatroom!.communityId!,
            createdAt: conversation.createdAt,
            header: conversation.header,
          ),
        );
      }
      conversationList.insert(0, conversation);
      if (conversationList.length >= 500) {
        conversationList.removeLast();
      }
      if (!userMeta.containsKey(user!.id)) {
        userMeta[user!.id] = user;
      }
    }
    pagedListController.itemList = conversationList;
    rebuildConversationList.value = !rebuildConversationList.value;
  }

  void addMultiMediaConversation(MultiMediaConversationPosted state) {
    if (!userMeta.containsKey(user!.id)) {
      userMeta[user!.id] = user;
    }
    if (!conversationAttachmentsMeta
        .containsKey(state.postConversationResponse.conversation!.id)) {
      List<Media> putMediaAttachment = state.putMediaResponse;
      conversationAttachmentsMeta[
              '${state.postConversationResponse.conversation!.id}'] =
          putMediaAttachment;
    }
    List<Conversation> conversationList =
        pagedListController.itemList ?? <Conversation>[];

    conversationList.removeWhere((element) =>
        element.temporaryId ==
        state.postConversationResponse.conversation!.temporaryId);

    mediaFiles.remove(state.postConversationResponse.conversation!.temporaryId);

    conversationList.insert(
      0,
      Conversation(
        id: state.postConversationResponse.conversation!.id,
        hasFiles: true,
        attachmentCount: state.putMediaResponse.length,
        attachmentsUploaded: true,
        chatroomId: chatroom!.id,
        state: state.postConversationResponse.conversation!.state,
        date: state.postConversationResponse.conversation!.date,
        memberId: state.postConversationResponse.conversation!.memberId,
        userId: state.postConversationResponse.conversation!.userId,
        temporaryId: state.postConversationResponse.conversation!.temporaryId,
        answer: state.postConversationResponse.conversation!.answer,
        communityId: chatroom!.communityId!,
        createdAt: state.postConversationResponse.conversation!.createdAt,
        header: state.postConversationResponse.conversation!.header,
      ),
    );

    if (conversationList.length >= 500) {
      conversationList.removeLast();
    }
    rebuildConversationList.value = !rebuildConversationList.value;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: () async {
          // debugPrint(router.location);
          _chatroomActionBloc.add(
            MarkReadChatroomEvent(chatroomId: widget.chatroomId),
          );
          BlocProvider.of<HomeBloc>(context).add(UpdateHomeEvent());
          router.pop();
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: showScrollButton
              ? Padding(
                  padding: EdgeInsets.only(bottom: 18.h),
                  child: Container(
                    height: 42,
                    width: 42,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                      color: primary.shade200,
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 2),
                          blurRadius: 8,
                          color: kBlackColor.withOpacity(0.2),
                        )
                      ],
                    ),
                    child: Center(
                      child: LMIconButton(
                        containerSize: 42,
                        onTap: (active) {
                          _scrollToBottom();
                        },
                        icon: const LMIcon(
                          type: LMIconType.icon,
                          icon: Icons.keyboard_arrow_down,
                          color: Colors.white,
                          size: 24,
                          boxPadding: 6,
                          boxSize: 36,
                        ),
                      ),
                    ),
                  ),
                )
              : null,
          body: SafeArea(
            bottom: false,
            left: false,
            right: false,
            child: BlocConsumer<ChatroomBloc, ChatroomState>(
              listener: (context, state) {
                if (state is ChatroomLoaded) {
                  chatroom = state.getChatroomResponse.chatroom!;
                  lastConversationId =
                      state.getChatroomResponse.lastConversationId ?? 0;
                  LMAnalytics.get().track(AnalyticsKeys.chatroomOpened, {
                    'chatroom_id': chatroom!.id,
                    'community_id': chatroom!.communityId,
                    'chatroom_type': chatroom!.type,
                    'source': 'home_feed',
                  });
                }
              },
              builder: (context, state) {
                // return const SkeletonChatList();
                if (state is ChatroomLoading) {
                  return const SkeletonChatPage();
                }

                if (state is ChatroomLoaded) {
                  var pagedListView = ValueListenableBuilder(
                    valueListenable: rebuildConversationList,
                    builder: (context, _, __) {
                      return BlocConsumer<ConversationBloc, ConversationState>(
                          bloc: _conversationBloc,
                          listener: (context, state) =>
                              updatePagingControllers(state),
                          builder: (context, state) {
                            return PagedListView(
                              pagingController: pagedListController,
                              scrollController: scrollController,
                              physics: const ClampingScrollPhysics(),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              reverse: true,
                              scrollDirection: Axis.vertical,
                              builderDelegate:
                                  PagedChildBuilderDelegate<Conversation>(
                                noItemsFoundIndicatorBuilder: (context) =>
                                    const SizedBox(
                                  height: 10,
                                ),
                                firstPageProgressIndicatorBuilder: (context) =>
                                    const SkeletonChatList(),
                                newPageProgressIndicatorBuilder: (context) =>
                                    Padding(
                                  padding: EdgeInsets.symmetric(vertical: 1.h),
                                  child: const Column(
                                    children: [
                                      SkeletonChatBubble(isSent: true),
                                      SkeletonChatBubble(isSent: false),
                                      SkeletonChatBubble(isSent: true),
                                    ],
                                  ),
                                ),
                                animateTransitions: true,
                                transitionDuration:
                                    const Duration(milliseconds: 500),
                                itemBuilder: (context, item, index) {
                                  if (item.isTimeStamp != null &&
                                          item.isTimeStamp! ||
                                      item.state != 0 && item.state != null) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          // width: item.isTimeStamp == null ||
                                          //         !item.isTimeStamp!
                                          //     ? 70.w
                                          //     : 35.w,
                                          margin: const EdgeInsets.symmetric(
                                              vertical: 5),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                              color:
                                                  kWhiteColor.withOpacity(0.5),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                  color: kGrey3Color)),
                                          alignment: Alignment.center,
                                          child: LMTextView(
                                              text: TaggingHelper
                                                  .extractStateMessage(
                                                      item.answer),
                                              textAlign: TextAlign.center,
                                              textStyle: const TextStyle(
                                                fontSize: 10,
                                              )),
                                        )
                                      ],
                                    );
                                  }
                                  // item.

                                  // return SSChatBubble();
                                  final replyAttachments = item.replyId != null
                                      ? conversationAttachmentsMeta.containsKey(
                                              item.replyId.toString())
                                          ? conversationAttachmentsMeta[
                                              item.replyId.toString()]
                                          : null
                                      : null;
                                  CustomPopupMenuController
                                      chatBubbleIndividualController =
                                      CustomPopupMenuController();
                                  return item.userId == user!.id
                                      ? LMChatBubble(
                                          currentUser: user!,
                                          key: Key(item.id.toString()),
                                          isSent: item.userId == user!.id,
                                          backgroundColor: primary.shade500,
                                          menuController:
                                              chatBubbleIndividualController,
                                          menu: ClipRRect(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              width: 36.w,
                                              // color: Colors.white,
                                              child: IntrinsicWidth(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    ListTile(
                                                      onTap: () {
                                                        int userId =
                                                            item.userId ??
                                                                item.memberId!;
                                                        if (userId ==
                                                            user!.id) {
                                                          item.member = user!;
                                                        }
                                                        if (item.deletedByUserId !=
                                                            null) {
                                                          return;
                                                        }
                                                        _convActionBloc.add(
                                                          ReplyConversation(
                                                            chatroomId:
                                                                chatroom!.id,
                                                            conversationId:
                                                                item.id,
                                                            replyConversation:
                                                                item,
                                                          ),
                                                        );
                                                        chatBubbleIndividualController
                                                            .hideMenu();
                                                      },
                                                      leading: const LMIcon(
                                                        type: LMIconType.svg,
                                                        assetPath: ssReplyIcon,
                                                        size: 24,
                                                      ),
                                                      title: const LMTextView(
                                                        text: "Reply",
                                                        textStyle: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      onTap: () {
                                                        Clipboard.setData(
                                                          ClipboardData(
                                                            text: TaggingHelper
                                                                    .convertRouteToTag(
                                                                        item.answer) ??
                                                                '',
                                                          ),
                                                        ).then((value) {
                                                          toast(
                                                              "Copied to clipboard");
                                                          chatBubbleIndividualController
                                                              .hideMenu();
                                                        });
                                                      },
                                                      leading: const LMIcon(
                                                        type: LMIconType.svg,
                                                        assetPath: ssCopyIcon,
                                                        size: 24,
                                                      ),
                                                      title: const LMTextView(
                                                        text: "Copy",
                                                        textStyle: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    checkEditPermissions(item)
                                                        ? ListTile(
                                                            onTap: () async {
                                                              _convActionBloc
                                                                  .add(
                                                                EditingConversation(
                                                                  chatroomId:
                                                                      chatroom!
                                                                          .id,
                                                                  conversationId:
                                                                      item.id,
                                                                  editConversation:
                                                                      item,
                                                                ),
                                                              );
                                                              chatBubbleIndividualController
                                                                  .hideMenu();
                                                            },
                                                            leading:
                                                                const LMIcon(
                                                              type: LMIconType
                                                                  .svg,
                                                              assetPath:
                                                                  ssEditIcon,
                                                              size: 24,
                                                            ),
                                                            title:
                                                                const LMTextView(
                                                              text: "Edit",
                                                              textStyle:
                                                                  TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox
                                                            .shrink(),
                                                    Visibility(
                                                      visible:
                                                          checkDeletePermissions(
                                                              item),
                                                      child: ListTile(
                                                        onTap: () async {
                                                          final response = await locator<
                                                                  LikeMindsService>()
                                                              .deleteConversation(
                                                                  (DeleteConversationRequestBuilder()
                                                                        ..conversationIds([
                                                                          item.id
                                                                        ])
                                                                        ..reason(
                                                                            "Delete"))
                                                                      .build());
                                                          if (response
                                                              .success) {
                                                            item.deletedByUserId =
                                                                user!.id;
                                                            chatBubbleIndividualController
                                                                .hideMenu();
                                                            rebuildConversationList
                                                                    .value =
                                                                !rebuildConversationList
                                                                    .value;
                                                            toast(
                                                                "Message deleted");
                                                          }
                                                        },
                                                        leading: const LMIcon(
                                                          type: LMIconType.svg,
                                                          assetPath:
                                                              ssDeleteIcon,
                                                          color: Colors.red,
                                                          size: 24,
                                                        ),
                                                        title: const LMTextView(
                                                          text: "Delete",
                                                          textStyle: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          onReply: (replyingTo) {
                                            int userId =
                                                item.userId ?? item.memberId!;
                                            if (userId == user!.id) {
                                              item.member = user!;
                                            }
                                            if (item.deletedByUserId != null) {
                                              return;
                                            }
                                            _convActionBloc.add(
                                              ReplyConversation(
                                                chatroomId: chatroom!.id,
                                                conversationId: item.id,
                                                replyConversation: replyingTo,
                                              ),
                                            );
                                          },
                                          outsideFooter: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Visibility(
                                                visible:
                                                    item.isEdited != null &&
                                                        item.isEdited!,
                                                child: const LMTextView(
                                                  text: "Edited • ",
                                                  textStyle: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.black54,
                                                  ),
                                                ),
                                              ),
                                              LMTextView(
                                                text: item.createdAt,
                                                textStyle: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.black54,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: LMChatContent(
                                            conversation: item,
                                            textStyle: TextStyle(
                                              fontSize: 14,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onPrimary,
                                            ),
                                            linkStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: primary.shade800,
                                            ),
                                            visibleLines: 2,
                                            animation: true,
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                            bottomRight: Radius.zero,
                                            bottomLeft: Radius.circular(16),
                                          ),
                                          conversation: item,
                                          replyingTo:
                                              item.replyConversationObject,
                                          replyItem: LMReplyItem(
                                            replyToConversation:
                                                item.replyConversationObject,
                                            borderRadius: 10,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                                .withOpacity(0.7),
                                            subtitle:
                                                item.replyConversationObject !=
                                                        null
                                                    ? getChatItemAttachmentTile(
                                                        replyAttachments ?? [],
                                                        item.replyConversationObject!,
                                                      )
                                                    : null,
                                          ),
                                          sender: userMeta[item.userId ??
                                                  item.memberId] ??
                                              item.member!,
                                          onLongPress: (conversation) {
                                            // _startSelection(conversation);
                                          },
                                          mediaWidget:
                                              item.deletedByUserId == null
                                                  ? getContent(item)
                                                  : const SizedBox.shrink(),
                                        )
                                      : LMChatBubble(
                                          currentUser: user!,
                                          key: Key(item.id.toString()),
                                          isSent: item.userId == user!.id,
                                          backgroundColor: secondary.shade100,
                                          menuController:
                                              chatBubbleIndividualController,
                                          menu: ClipRRect(
                                            child: Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              width: 36.w,
                                              // color: Colors.white,
                                              child: IntrinsicWidth(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .stretch,
                                                  children: [
                                                    ListTile(
                                                      onTap: () {
                                                        int userId =
                                                            item.userId ??
                                                                item.memberId!;
                                                        if (userId ==
                                                            user!.id) {
                                                          item.member = user!;
                                                        }
                                                        if (item.deletedByUserId !=
                                                            null) {
                                                          return;
                                                        }
                                                        _convActionBloc.add(
                                                          ReplyConversation(
                                                            chatroomId:
                                                                chatroom!.id,
                                                            conversationId:
                                                                item.id,
                                                            replyConversation:
                                                                item,
                                                          ),
                                                        );
                                                        chatBubbleIndividualController
                                                            .hideMenu();
                                                      },
                                                      leading: const LMIcon(
                                                        type: LMIconType.svg,
                                                        assetPath: ssReplyIcon,
                                                        size: 24,
                                                      ),
                                                      title: const LMTextView(
                                                        text: "Reply",
                                                        textStyle: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    ListTile(
                                                      onTap: () {
                                                        Clipboard.setData(
                                                          ClipboardData(
                                                            text: TaggingHelper
                                                                    .convertRouteToTag(
                                                                        item.answer) ??
                                                                '',
                                                          ),
                                                        ).then((value) {
                                                          toast(
                                                              "Copied to clipboard");
                                                          chatBubbleIndividualController
                                                              .hideMenu();
                                                        });
                                                      },
                                                      leading: const LMIcon(
                                                        type: LMIconType.svg,
                                                        assetPath: ssCopyIcon,
                                                        size: 24,
                                                      ),
                                                      title: const LMTextView(
                                                        text: "Copy",
                                                        textStyle: TextStyle(
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    checkEditPermissions(item)
                                                        ? ListTile(
                                                            onTap: () async {
                                                              _convActionBloc
                                                                  .add(
                                                                EditingConversation(
                                                                  chatroomId:
                                                                      chatroom!
                                                                          .id,
                                                                  conversationId:
                                                                      item.id,
                                                                  editConversation:
                                                                      item,
                                                                ),
                                                              );
                                                              chatBubbleIndividualController
                                                                  .hideMenu();
                                                            },
                                                            leading:
                                                                const LMIcon(
                                                              type: LMIconType
                                                                  .svg,
                                                              assetPath:
                                                                  ssEditIcon,
                                                              size: 24,
                                                            ),
                                                            title:
                                                                const LMTextView(
                                                              text: "Edit",
                                                              textStyle:
                                                                  TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                            ),
                                                          )
                                                        : const SizedBox
                                                            .shrink(),
                                                    Visibility(
                                                      visible:
                                                          checkDeletePermissions(
                                                              item),
                                                      child: ListTile(
                                                        onTap: () async {
                                                          final response = await locator<
                                                                  LikeMindsService>()
                                                              .deleteConversation(
                                                                  (DeleteConversationRequestBuilder()
                                                                        ..conversationIds([
                                                                          item.id
                                                                        ])
                                                                        ..reason(
                                                                            "Delete"))
                                                                      .build());
                                                          if (response
                                                              .success) {
                                                            chatBubbleIndividualController
                                                                .hideMenu();
                                                            rebuildConversationList
                                                                    .value =
                                                                !rebuildConversationList
                                                                    .value;
                                                            toast(
                                                                "Message deleted");
                                                          }
                                                        },
                                                        leading: const LMIcon(
                                                          type: LMIconType.svg,
                                                          assetPath:
                                                              ssDeleteIcon,
                                                          color: Colors.red,
                                                          size: 24,
                                                        ),
                                                        title: const LMTextView(
                                                          text: "Delete",
                                                          textStyle: TextStyle(
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          onReply: (replyingTo) {
                                            int userId =
                                                item.userId ?? item.memberId!;
                                            if (userId == user!.id) {
                                              item.member = user!;
                                            }
                                            if (item.deletedByUserId != null) {
                                              return;
                                            }
                                            _convActionBloc.add(
                                              ReplyConversation(
                                                chatroomId: chatroom!.id,
                                                conversationId: item.id,
                                                replyConversation: replyingTo,
                                              ),
                                            );
                                          },
                                          avatar: LMProfilePicture(
                                            fallbackText: item.member!.name,
                                            imageUrl: item.member!.imageUrl,
                                            size: 32,
                                          ),
                                          outsideTitle: LMTextView(
                                            text: item.member!.name,
                                            textStyle: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          outsideFooter: LMTextView(
                                            text: item.createdAt,
                                            textStyle: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black54,
                                            ),
                                          ),
                                          content: LMChatContent(
                                            conversation: item,
                                            visibleLines: 2,
                                            animation: true,
                                            textStyle: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                            linkStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: primary.shade600,
                                            ),
                                          ),
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16),
                                            topRight: Radius.circular(16),
                                            bottomLeft: Radius.zero,
                                            bottomRight: Radius.circular(16),
                                          ),
                                          conversation: item,
                                          replyingTo:
                                              item.replyConversationObject,
                                          replyItem: LMReplyItem(
                                            replyToConversation:
                                                item.replyConversationObject,
                                            borderRadius: 10,
                                            highlightColor: secondary,
                                            title:
                                                item.replyConversationObject !=
                                                        null
                                                    ? LMTextView(
                                                        text: item
                                                            .replyConversationObject!
                                                            .member!
                                                            .name,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                        textStyle:
                                                            const TextStyle(
                                                          color: kPrimaryColor,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      )
                                                    : null,
                                            subtitle:
                                                item.replyConversationObject !=
                                                        null
                                                    ? getChatItemAttachmentTile(
                                                        replyAttachments ?? [],
                                                        item.replyConversationObject!,
                                                      )
                                                    : null,
                                            backgroundColor: Theme.of(context)
                                                .colorScheme
                                                .onPrimary
                                                .withOpacity(0.7),
                                          ),
                                          sender: userMeta[item.userId ??
                                                  item.memberId] ??
                                              item.member!,
                                          onLongPress: (conversation) {
                                            // _startSelection(conversation);
                                          },
                                        );
                                },
                              ),
                            );
                          });
                    },
                  );

                  return Column(
                    children: [
                      Container(
                        decoration:
                            BoxDecoration(color: kWhiteColor, boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 10),
                          )
                        ]),
                        child: Column(
                          children: <Widget>[
                            kVerticalPaddingMedium,
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 2.h,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  BackButton(
                                    onPressed: () {
                                      BlocProvider.of<HomeBloc>(context)
                                          .add(UpdateHomeEvent());
                                      router.pop();
                                    },
                                    style: ButtonStyle(
                                      padding: MaterialStateProperty.all(
                                        EdgeInsets.zero,
                                      ),
                                      fixedSize: MaterialStateProperty.all(
                                        const Size(36, 36),
                                      ),
                                    ),
                                  ),
                                  LMProfilePicture(
                                    fallbackText: chatroom!.header,
                                    imageUrl: chatroom?.chatroomImageUrl,
                                    size: 42,
                                  ),
                                  SizedBox(width: 4.w),
                                  Expanded(
                                    child: GestureDetector(
                                      behavior: HitTestBehavior.opaque,
                                      onTap: () {
                                        chatroom != null
                                            ? showBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return LMGroupDetailBottomSheet(
                                                    chatRoom: chatroom!,
                                                  );
                                                },
                                              )
                                            : {};
                                      },
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            chatroom!.header,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          ),
                                          kVerticalPaddingSmall,
                                          Text(
                                            '${chatroom!.participantCount} participants',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  ChatroomMenu(
                                    chatroom: chatroom!,
                                    chatroomActions: state
                                        .getChatroomResponse.chatroomActions!,
                                  ),
                                  kHorizontalPaddingMedium,
                                ],
                              ),
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(
                          color: kWhiteColor,
                          child: pagedListView,
                        ),
                      ),
                      BlocConsumer(
                          bloc: _convActionBloc,
                          listener: (context, state) {
                            if (state is LocalConversation) {
                              addLocalConversationToPagedList(
                                  state.conversation);
                            }
                            if (state is ConversationEdited) {
                              updateEditedConversation(
                                  state.editConversationResponse.conversation!);
                            }
                            if (state is ReplyConversationState) {
                              rebuildChatBar.value = !rebuildChatBar.value;
                            }
                            if (state is EditConversationState) {
                              rebuildChatBar.value = !rebuildChatBar.value;
                            }
                          },
                          builder: (context, state) {
                            return ValueListenableBuilder(
                                valueListenable: rebuildChatBar,
                                builder: (context, _, __) {
                                  if (state is EditConversationState) {
                                    return ChatBar(
                                      chatroom: chatroom!,
                                      editConversation: state.editConversation,
                                      scrollToBottom: _scrollToBottom,
                                      userMeta: userMeta,
                                    );
                                  }
                                  if (state is ReplyConversationState) {
                                    return ChatBar(
                                      chatroom: chatroom!,
                                      replyToConversation: state.conversation,
                                      replyConversationAttachments:
                                          conversationAttachmentsMeta
                                                  .containsKey(state
                                                      .conversation.id
                                                      .toString())
                                              ? conversationAttachmentsMeta[
                                                  '${state.conversation.id}']
                                              : null,
                                      scrollToBottom: _scrollToBottom,
                                      userMeta: userMeta,
                                    );
                                  }
                                  return ChatBar(
                                    chatroom: chatroom!,
                                    scrollToBottom: _scrollToBottom,
                                    userMeta: userMeta,
                                  );
                                });
                          }),
                    ],
                  );
                }
                return Container(
                  color: kGreyColor.withOpacity(0.2),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget getContent(Conversation conversation) {
    if (conversation.attachmentsUploaded == null ||
        !conversation.attachmentsUploaded!) {
      // If conversation has media but not uploaded yet
      // show local files
      if (mediaFiles[conversation.temporaryId] == null ||
          mediaFiles[conversation.temporaryId]!.isEmpty) {
        // return expandableText;
        return const SizedBox.shrink();
      }
      Widget mediaWidget;
      if (mediaFiles[conversation.temporaryId]!.first.mediaType ==
              MediaType.photo ||
          mediaFiles[conversation.temporaryId]!.first.mediaType ==
              MediaType.video) {
        mediaWidget =
            getImageFileMessage(context, mediaFiles[conversation.temporaryId]!);
      } else if (mediaFiles[conversation.temporaryId]!.first.mediaType ==
          MediaType.document) {
        mediaWidget =
            documentPreviewFactory(mediaFiles[conversation.temporaryId]!);
      } else {
        mediaWidget = const SizedBox();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              mediaWidget,
              const Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: LMLoader(
                  primary: kWhiteColor,
                ),
              )
            ],
          ),
          conversation.answer.isEmpty
              ? const SizedBox.shrink()
              : kVerticalPaddingXSmall,
        ],
      );
    } else if (conversation.attachmentsUploaded != null ||
        conversation.attachmentsUploaded!) {
      // If conversation has media and uploaded
      // show uploaded files
      final conversationAttachments =
          conversationAttachmentsMeta.containsKey(conversation.id.toString())
              ? conversationAttachmentsMeta['${conversation.id}']
              : null;
      if (conversationAttachments == null) {
        return const SizedBox.shrink();
      }

      Widget mediaWidget;
      if (conversationAttachments.first.mediaType == MediaType.photo ||
          conversationAttachments.first.mediaType == MediaType.video) {
        mediaWidget = getImageMessage(
          context,
          conversationAttachments,
          chatroom!,
          conversation,
          userMeta,
        );
      } else if (conversationAttachments.first.mediaType ==
          MediaType.document) {
        mediaWidget = documentPreviewFactory(conversationAttachments);
      } else {
        mediaWidget = const SizedBox();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          mediaWidget,
          conversation.answer.isEmpty
              ? const SizedBox.shrink()
              : kVerticalPaddingXSmall,
        ],
      );
    }
    return const SizedBox();
  }
}
