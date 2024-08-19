import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:nearmessageapp/components/user_tile.dart';
import 'package:nearmessageapp/services/general/localstorage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Userpage extends StatefulWidget {
  const Userpage(
      {super.key, required this.socketChannel, required this.userId});
  final WebSocketChannel socketChannel;
  final String userId;

  @override
  State<Userpage> createState() => _UserpageState();
}

class _UserpageState extends State<Userpage> {
  List<dynamic> userList = [];
  List<Widget> userWidgetList = [];

  List<Widget> buildUserItemList(List<dynamic> userList) {
    List<Widget> userWidgetList = userList
        .map((document) => buildUserItem(document["email"], document["name"]))
        .toList();

    return userWidgetList;
  }

  Widget buildUserItem(String email, String name) {
    return UserTile(email: email, name: name);
  }

  @override
  void initState() {
    super.initState();
    saveDataToLocalStorage("userList", "[]");
    widget.socketChannel.sink
        .add(jsonEncode({"action": "userDetails", "userId": widget.userId}));
  }

  @override
  Widget build(BuildContext context) {
    readDataFromLocalStorage("userList").then((data) {
      if (data != "[]") {
        if (userList.length != jsonDecode(data!).length) {
          setState(() {
            userList = jsonDecode(data);
            userWidgetList = buildUserItemList(userList);
          });
        }
      } else {
        setState(() {
          userList = [];
        });
      }
    });

    return userList.isEmpty
        ? const Center(
            child: SizedBox(child: CircularProgressIndicator.adaptive()))
        : Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.count(
              crossAxisCount: 4,
              children: userWidgetList
            ));
  }
}
