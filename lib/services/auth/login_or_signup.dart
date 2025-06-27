import 'package:flutter/material.dart';
import 'package:nearmessageapp/pages/loginpage.dart';
import 'package:nearmessageapp/pages/signuppage.dart';
import 'package:nearmessageapp/services/storage/userStore.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister(
      {super.key, required this.screenSize, required this.userDatabase});
  final Size screenSize;
  final DatabaseServiceUser userDatabase;

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool showLoginPage = true;

  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage(
          onTap: togglePages,
          screenSize: widget.screenSize,
          userDatabase: widget.userDatabase);
    } else {
      return RegisterPage(
          onTap: togglePages,
          screenSize: widget.screenSize,
          userDatabase: widget.userDatabase);
    }
  }
}
