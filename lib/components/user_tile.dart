import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nearmessageapp/services/general/localstorage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:crypto/crypto.dart';

class UserTile extends StatefulWidget {
  const UserTile(
      {super.key,
      required this.name,
      required this.email,
      required this.crossAxisCount,
      required this.socketChannel,
      required this.profilePic,
      required this.userId});
  final String name;
  final String email;
  final int crossAxisCount;
  final String profilePic;
  final String userId;
  final WebSocketChannel socketChannel;

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  final GlobalKey threeDotsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          color: const Color.fromARGB(255, 178, 227, 249),
          boxShadow: [
            BoxShadow(
                color:
                    const Color.fromARGB(255, 193, 193, 193).withOpacity(0.5),
                spreadRadius: 8,
                offset: const Offset(0, 3))
          ],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color.fromARGB(255, 69, 60, 255))),
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        SizedBox(
          height: 25,
          child: Row(
            children: [
              const Spacer(),
              IconButton(
                  key: threeDotsKey,
                  onPressed: () {
                    RenderBox box = threeDotsKey.currentContext!
                        .findRenderObject() as RenderBox;
                    double xpos = box.localToGlobal(Offset.zero).dx;
                    double ypos = box.localToGlobal(Offset.zero).dy;

                    showMenu(
                        context: context,
                        position: RelativeRect.fromLTRB(
                          xpos,
                          ypos,
                          0,
                          0,
                        ),
                        items: [
                          PopupMenuItem(
                            child: const Text('Play Chess Game'),
                            onTap: () {
                              readDataFromLocalStorage("username")
                                  .then((username) {
                                readDataFromLocalStorage("roomId")
                                    .then((roomId) {
                                  widget.socketChannel.sink.add(jsonEncode({
                                    "action": "challengeUsers",
                                    "username": username,
                                    "target": sha256
                                        .convert(utf8.encode(widget.email))
                                        .toString(),
                                    "type": "chess",
                                    "userId": widget.userId,
                                    "roomId": roomId
                                  }));
                                });
                              });

                              showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                        title: Text(
                                            "Request Sent to ${widget.name}"),
                                      ));
                            },
                          ),
                          PopupMenuItem(
                            child: const Text('Option 2'),
                            onTap: () {
                              // Handle Option 2 click
                              print('Option 2 clicked');
                            },
                          ),
                        ]);
                  },
                  icon: const Icon(
                    Icons.more_vert,
                    size: 20,
                  ))
            ],
          ),
        ),
        widget.crossAxisCount == 3
            ? CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(widget.profilePic),
              )
            : CircleAvatar(
                radius: 50, backgroundImage: NetworkImage(widget.profilePic)),
        const Spacer(),
        Text(widget.name),
        Text(widget.email),
        const Spacer()
      ]),
    );
  }
}
