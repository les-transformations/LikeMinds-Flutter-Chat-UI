import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui_sample/bloc/auth/auth_bloc.dart';
import 'package:flutter_chat_ui_sample/bloc/chatroom/chatroom_bloc.dart';
import 'package:flutter_chat_ui_sample/bloc/conversation/conversation_bloc.dart';
import 'package:flutter_chat_ui_sample/bloc/home/home_bloc.dart';
import 'package:flutter_chat_ui_sample/environment/env.dart';
import 'package:flutter_chat_ui_sample/example_callback.dart';
import 'package:flutter_chat_ui_sample/navigation/router.dart';
import 'package:flutter_chat_ui_sample/utils/constants/constants.dart';
import 'package:flutter_chat_ui_sample/utils/imports.dart';
import 'package:likeminds_chat_ui_fl/likeminds_chat_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

const bool isDebug = bool.fromEnvironment('DEBUG');

class LMChatApp extends StatefulWidget {
  const LMChatApp({super.key});

  @override
  State<LMChatApp> createState() => _LMChatAppState();
}

class _LMChatAppState extends State<LMChatApp> {
  late AuthBloc _authBloc;

  @override
  void initState() {
    super.initState();
    _authBloc = BlocProvider.of<AuthBloc>(context);
    _authBloc.add(InitAuthEvent(
      apiKey: isDebug ? EnvDev.apiKey : EnvProd.apiKey,
      callback: ExampleCallback(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    ScreenSize.init(context);
    return Center(
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthInitiated) {
            _authBloc.add(LoginEvent(
              userId: isDebug ? EnvDev.botId : EnvProd.botId,
              username: isDebug ? "test-debug-user" : "test-prod-user",
            ));
          }
        },
        builder: (context, state) {
          if (state is AuthSuccess) {
            return OverlaySupport.global(
              child: MultiBlocProvider(
                providers: [
                  BlocProvider<HomeBloc>(
                    create: (context) => HomeBloc(),
                  ),
                  BlocProvider<ConversationBloc>(
                    create: (context) => ConversationBloc(),
                  ),
                  BlocProvider<ChatroomBloc>(
                    create: (context) => ChatroomBloc(),
                  )
                ],
                child: MaterialApp.router(
                  routerConfig: router,
                  debugShowCheckedModeBanner: !isDebug,
                  theme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: primary,
                      primary: primary,
                      secondary: secondary,
                    ),
                    useMaterial3: true,
                    fontFamily: 'Montserrat',
                    textTheme: const TextTheme(
                      displayLarge: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: kBlackColor,
                      ),
                      displayMedium: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: kBlackColor,
                      ),
                      displaySmall: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: kBlackColor,
                      ),
                      bodyLarge: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: kBlackColor,
                      ),
                      bodyMedium: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: kBlackColor,
                      ),
                      bodySmall: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w400,
                        color: kBlackColor,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return const SizedBox(
            width: 50,
            height: 50,
            child: CircularProgressIndicator(
              color: kPrimaryColor,
            ),
          );
        },
      ),
    );
  }
}

// class LMChat extends StatelessWidget {
//   final String _userId;
//   final String _userName;
//   // ignore: unused_field
//   final String? _domain;
//   final int? _defaultChatroom;

//   LMChat._internal(
//     this._userId,
//     this._userName,
//     this._domain,
//     this._defaultChatroom,
//   ) {
//     debugPrint('LMChat initialized');
//   }

//   static LMChat? _instance;
//   static LMChat instance({required LMChatBuilder builder}) {
//     if (builder.getUserId == null && builder.getUserName == null) {
//       throw Exception(
//         'LMChat builder needs to be initialized with User ID, or User Name',
//       );
//     } else {
//       return _instance ??= LMChat._internal(
//         builder.getUserId!,
//         builder.getUserName!,
//         builder.getDomain,
//         builder.getDefaultChatroom,
//       );
//     }
//   }

//   static Future<InitiateUser> initiateUser({
//     String? userId,
//     String? userName,
//   }) async {
//     final response = await locator<LikeMindsService>()
//         .initiateUser((InitiateUserRequestBuilder()
//               ..userId((userId ?? _instance?._userId)!)
//               ..userName((userName ?? _instance?._userName)!))
//             .build());
//     final initiateUser = response.data!.initiateUser!;

//     final isCm = await locator<LikeMindsService>().getMemberState();
//     UserLocalPreference.instance.storeMemberRights(isCm.data);
//     UserLocalPreference.instance.storeUserData(initiateUser.user);
//     UserLocalPreference.instance.storeCommunityData(initiateUser.community);
//     await _instance?.firebase();
//     return initiateUser;
//   }

//   firebase() async {
//     try {
//       final clientFirebase = Firebase.app();
//       final ourFirebase = await Firebase.initializeApp(
//         name: 'likeminds_chat',
//         options: !isDebug
//             ?
//             //Prod Firebase options
//             Platform.isIOS
//                 ? FirebaseOptions(
//                     apiKey: FbCredsProd.fbApiKey,
//                     appId: FbCredsProd.fbAppIdIOS,
//                     messagingSenderId: FbCredsProd.fbMessagingSenderId,
//                     projectId: FbCredsProd.fbProjectId,
//                     databaseURL: FbCredsProd.fbDatabaseUrl,
//                   )
//                 : FirebaseOptions(
//                     apiKey: FbCredsProd.fbApiKey,
//                     appId: FbCredsProd.fbAppIdAN,
//                     messagingSenderId: FbCredsProd.fbMessagingSenderId,
//                     projectId: FbCredsProd.fbProjectId,
//                     databaseURL: FbCredsProd.fbDatabaseUrl,
//                   )
//             //Beta Firebase options
//             : Platform.isIOS
//                 ? FirebaseOptions(
//                     apiKey: FbCredsDev.fbApiKey,
//                     appId: FbCredsDev.fbAppIdIOS,
//                     messagingSenderId: FbCredsDev.fbMessagingSenderId,
//                     projectId: FbCredsDev.fbProjectId,
//                     databaseURL: FbCredsDev.fbDatabaseUrl,
//                   )
//                 : FirebaseOptions(
//                     apiKey: FbCredsDev.fbApiKey,
//                     appId: FbCredsDev.fbAppIdIOS,
//                     messagingSenderId: FbCredsDev.fbMessagingSenderId,
//                     projectId: FbCredsDev.fbProjectId,
//                     databaseURL: FbCredsDev.fbDatabaseUrl,
//                   ),
//       );
//       debugPrint("Client Firebase - ${clientFirebase.options.appId}");
//       debugPrint("Our Firebase - ${ourFirebase.options.appId}");
//     } on FirebaseException catch (e) {
//       debugPrint("Make sure you have initialized firebase, ${e.toString()}");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocProvider(
//       providers: [
//         // BlocProvider<ChatActionBloc>(
//         //   create: (context) => ChatActionBloc(),
//         // ),
//         BlocProvider<HomeBloc>(
//           create: (context) => HomeBloc(),
//         ),
//       ],
//       child: FutureBuilder(
//         future: initiateUser(),
//         builder: (context, snapshot) {
//           if (snapshot.hasData) {
//             // final user = snapshot.data!.user;
//             // LMNotificationHandler.instance.registerDevice(user.id);
//             if (_defaultChatroom != null) {
//               LMRealtime.instance.chatroomId = _defaultChatroom!;
//               // router.
//               // return MaterialApp.router(
//               //   routerConfig: router
//               //     ..go('/chatroom/$_defaultChatroom?isRoot=true'),
//               //   debugShowCheckedModeBanner: false,
//               // );
//             }
//             // return MaterialApp.router(
//             //   routerConfig: router,
//             //   debugShowCheckedModeBanner: false,
//             // );
//           }
//           return Container(
//             color: kWhiteColor,
//             child: const CircularProgressIndicator(
//               color: kPrimaryColor,
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

// class LMChatBuilder {
//   String? _userId;
//   String? _userName;
//   String? _domain;
//   int? _defaultChatroom;

//   LMChatBuilder();

//   void userId(String userId) => _userId = userId;
//   void userName(String userName) => _userName = userName;
//   void domain(String domain) => _domain = domain;
//   void defaultChatroom(int? defaultChatroomId) =>
//       _defaultChatroom = defaultChatroomId;

//   String? get getUserId => _userId;
//   String? get getUserName => _userName;
//   String? get getDomain => _domain;
//   int? get getDefaultChatroom => _defaultChatroom;
// }
