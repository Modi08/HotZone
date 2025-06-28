import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:nearmessageapp/components/user_tile.dart';
import 'package:nearmessageapp/services/storage/keyValueStore.dart';
import 'package:nearmessageapp/services/storage/userStore.dart';
import 'package:nearmessageapp/values/general/colors.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Userpage extends StatefulWidget {
  const Userpage(
      {super.key,
      required this.socketChannel,
      required this.userId,
      required this.userData,
      required this.userDatabase});
  final WebSocketChannel socketChannel;
  final String userId;
  final User userData;
  final DatabaseServiceUser userDatabase;

  @override
  State<Userpage> createState() => _UserpageState();
}

class _UserpageState extends State<Userpage> {
  List<dynamic> userList = [];
  List<Widget> userWidgetList = [];

  int getCrossAxisCount(int childCount) {
    if (childCount == 1) {
      return 1;
    } else if (childCount < 3) {
      return 2;
    } else {
      return 3;
    }
  }

  List<Widget> buildUserItemList(List<dynamic> userList) {
    List<Widget> userWidgetList = userList
        .map((document) => buildUserItem(document["email"], document["name"],
            userList.length, document["profilePic"]))
        .toList();

    return userWidgetList;
  }

  Widget buildUserItem(
      String email, String name, int length, String profilePic) {
    return UserTile(
      email: email,
      name: name,
      crossAxisCount: getCrossAxisCount(length),
      socketChannel: widget.socketChannel,
      profilePic: profilePic,
      userId: widget.userId,
      userData: widget.userData,
    );
  }

  @override
  void initState() {
    super.initState();
    readDataFromLocalStorage("cords").then((data) {
      widget.socketChannel.sink.add(jsonEncode(
          {"action": "userDetails", "userId": widget.userId, "roomId": data}));
    });
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = getCrossAxisCount(userWidgetList.length);

    widget.userDatabase.queryAllExcept(widget.userId).then((data) {
      setState(() {
        if (data.isEmpty) {
          userList = [0]; // If no users found, set to a list with a single zero
        } else {
          userList = data;
          userWidgetList = buildUserItemList(userList);
        }
      });
    });

    return Container(
      color: backgroundColorSecondary,
      child: userList.isEmpty
          ? const Center(
              child: SizedBox(child: CircularProgressIndicator.adaptive()))
          : userList[0] != 0
              ? Padding(
                  padding: crossAxisCount == 1
                      ? const EdgeInsets.all(110)
                      : crossAxisCount == 2
                          ? const EdgeInsets.all(20)
                          : const EdgeInsets.all(8),
                  child: GridView.count(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 18,
                      children: userWidgetList),
                )
              : Center(
                  child: SizedBox(
                      child: Text(
                  "No Users Found",
                  style: TextStyle(color: textColorPrimary),
                ))),
    );
  }
}
