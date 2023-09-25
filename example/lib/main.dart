import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui_sample/bloc/auth/auth_bloc.dart';
import 'package:flutter_chat_ui_sample/likeminds_chat.dart';
import 'package:flutter_chat_ui_sample/utils/imports.dart';
import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';

const bool isDebug = bool.fromEnvironment('DEBUG');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AnujApp());
}
//  BlocProvider(
//       create: (context) => AuthBloc(),
//       child: const LMChatApp(),
//     ),
//TODO: Remove this before git push:

class AnujApp extends StatelessWidget {
  const AnujApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        appBar: AppBar(
          title: const Text("This is a sample App"),
        ),
        body: Stack(
          children: [
            ListView.builder(
                itemCount: 50,
                itemBuilder: (context, index) => ListTile(
                      title: Text("${index}this is a sample app"),
                    )),
            LMChatRoomTopic(
              onTap: (){},
              conversation: Conversation(
                  answer:
                      "this is test message which is so",
                  createdAt: "9-10-2023",
                  date: "April 2020",
                  header: null,
                  id: 123,
                  member: User(
                    id: 123,
                    name: "Anuj",
                    imageUrl: "https://img.freepik.com/free-photo/wide-angle-shot-single-tree-growing-clouded-sky-during-sunset-surrounded-by-grass_181624-22807.jpg?w=2000",
                    isGuest:false,
                    userUniqueId: ""
                  )),
            ),
            Divider(
              height: 1,
            ),
          ],
        ),
      ),
    );
  }
}
