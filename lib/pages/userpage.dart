import 'dart:convert';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:nearmessageapp/components/user_tile.dart';
import 'package:nearmessageapp/services/general/localstorage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Userpage extends StatefulWidget {
  const Userpage(
      {super.key,
      required this.socketChannel,
      required this.userId});
  final WebSocketChannel socketChannel;
  final String userId;

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
        .map((document) =>
            buildUserItem(document["email"], document["name"], userList.length, document["profilePic"]))
        .toList();

    return userWidgetList;
  }

  Widget buildUserItem(String email, String name, int length, String profilePic) {
    return UserTile(
        email: email,
        name: name,
        crossAxisCount: getCrossAxisCount(length),
        socketChannel: widget.socketChannel,
        profilePic: profilePic);
  }

  @override
  void initState() {
    super.initState();
    saveDataToLocalStorage("userList", "[]");
    readDataFromLocalStorage("cords").then((data) {
      widget.socketChannel.sink.add(jsonEncode(
          {"action": "userDetails", "userId": widget.userId, "roomId": data}));
    });
  }

  @override
  Widget build(BuildContext context) {
    int crossAxisCount = getCrossAxisCount(userWidgetList.length);

    readDataFromLocalStorage("userList").then((data) {
      if (data != "[]" && data != "[0]") {
        if (userList.length != jsonDecode(data!).length) {
          setState(() {
            userList = jsonDecode(data);
            userWidgetList = buildUserItemList(userList);
          });
        }
      } else if (data == "[0]") {
        setState(() {
          userList = [0];
        });
      } else {
        setState(() {
          userList = [];
        });
      }
    });
    return userList.isEmpty
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
            : const Center(child: SizedBox(child: Text("No Users Found")));
  }
}
