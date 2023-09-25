import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_chat_ui_sample/bloc/auth/auth_bloc.dart';
import 'package:flutter_chat_ui_sample/likeminds_chat.dart';

const bool isDebug = bool.fromEnvironment('DEBUG');

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BlocProvider(
      create: (context) => AuthBloc(),
      child: const LMChatApp(),
    ),
  );
}
