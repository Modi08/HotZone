import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nearmessageapp/services/auth/login_or_signup.dart';
import 'package:nearmessageapp/services/general/localstorage.dart';
import 'package:nearmessageapp/services/general/pagerender.dart';


class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  Future<String?> isUserIdFound = readDataFromLocalStorage("userId");
  late String userId;
  bool isLoggedin = false;

  void setisLoggedin(bool value, String? userID) {
    setState(() {
      isLoggedin = value;
      if (value) {
        userId = userID!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    isUserIdFound.then((value) {
      if (value == null) {
        setisLoggedin(false, value!);
      } else {
        setisLoggedin(true, value);
      }
    });

    if (isLoggedin) {
      return PageRender(title: "Chat Room", userId: userId);
    } else {
      return const LoginOrRegister();
    }
  }
}