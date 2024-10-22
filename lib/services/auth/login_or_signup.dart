import 'package:flutter/material.dart';
import 'package:nearmessageapp/pages/loginpage.dart';
import 'package:nearmessageapp/pages/signuppage.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key, required this.screenSize});
  final Size screenSize;

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
      return LoginPage(onTap: togglePages, screenSize: widget.screenSize);
    } else {
      return RegisterPage(onTap: togglePages, screenSize: widget.screenSize);
    }
  }
}
