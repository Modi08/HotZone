import 'package:flutter/material.dart';
import 'package:nearmessageapp/services/auth/login_or_signup.dart';
import 'package:nearmessageapp/services/storage/msgStore.dart';
import 'package:nearmessageapp/services/storage/userStore.dart';
import 'package:nearmessageapp/services/general/pagerender.dart';

class AuthGate extends StatefulWidget {
  final DatabaseServiceUser userDatabase;
  const AuthGate(
      {super.key, required this.userDatabase});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  late String userId;
  late User userData;
  final DatabaseServiceMsg msgDatabase = DatabaseServiceMsg.instance;
  bool isLoggedin = false;

  void setisLoggedin(bool value, [String? userID = "", User? userInfo = null]) {
    setState(() {
      isLoggedin = value;
    });
    if (value) {
      setState(() {
        userData = userInfo!;
        userId = userID!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    widget.userDatabase.queryByX("isPrimary", "true").then((data) {
      if (data != null) {
        User user = data[0];
        setisLoggedin(true, user.id, user);
      } else {
        setisLoggedin(false);
      }
    });

    if (isLoggedin) {
      return PageRender(
          title: "Chat Room",
          userId: userId,
          screenSize: screenSize,
          userDatabase: widget.userDatabase,
          msgDatabase: msgDatabase,
          userData: userData);
    } else {
      return LoginOrRegister(
          screenSize: screenSize, userDatabase: widget.userDatabase);
    }
  }
}
