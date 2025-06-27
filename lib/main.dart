import 'package:flutter/material.dart';
import 'package:nearmessageapp/services/auth/auth_gate.dart';
import 'package:nearmessageapp/services/storage/msgStore.dart';
import 'package:nearmessageapp/services/storage/userStore.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});
  final DatabaseServiceUser userDatabase = DatabaseServiceUser.instance;
  final DatabaseServiceMsg msgDatabase = DatabaseServiceMsg.instance;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: AuthGate(userDatabase: userDatabase),
    );
  }
}
