import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nearmessageapp/services/storage/keyValueStore.dart';
import 'package:nearmessageapp/services/storage/userStore.dart';
import 'package:nearmessageapp/values/general/colors.dart';
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
      required this.userId,
      required this.userData});
  final String name;
  final String email;
  final int crossAxisCount;
  final String profilePic;
  final String userId;
  final User userData;
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
          color: foregroundColorPrimary,
          boxShadow: [
            BoxShadow(
                color: foregroundShadowColorPrimary,
                spreadRadius: 8,
                offset: const Offset(0, 3))
          ],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: foregroundColorPrimary)),
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        SizedBox(
          height: 25,
          child: Row(
            children: [
              const Spacer(),
              IconButton(
                  color: textColorPrimary,
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
                              readDataFromLocalStorage("cords").then((roomId) {
                                widget.socketChannel.sink.add(jsonEncode({
                                  "action": "challengeUsers",
                                  "username": widget.userData.username,
                                  "target": sha256
                                      .convert(utf8.encode(widget.email))
                                      .toString(),
                                  "type": "chess",
                                  "userId": widget.userId,
                                  "roomId": roomId
                                }));
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
                              debugPrint('Option 2 clicked');
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
        Text(
          widget.name,
          style: TextStyle(color: textColorPrimary),
        ),
        Text(
          widget.email,
          style: TextStyle(color: textColorPrimary),
        ),
        const Spacer()
      ]),
    );
  }
}
