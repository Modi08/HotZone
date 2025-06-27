import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nearmessageapp/components/chat_bubble.dart';
import 'package:nearmessageapp/components/text_field.dart';
import 'package:nearmessageapp/services/storage/keyValueStore.dart';
import 'package:nearmessageapp/services/storage/msgStore.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class HomePage extends StatefulWidget {
  const HomePage(
      {super.key,
      required this.userId,
      required this.socketChannel,
      required this.screenSize,
      required this.msgDatabase});
  final String? userId;
  final Size screenSize;
  final WebSocketChannel socketChannel;
  final DatabaseServiceMsg msgDatabase;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final msgController = TextEditingController();
  List<dynamic> messages = [];
  List<Widget> messagesWidgets = [];

  List<Widget> buildMessageWidgetsLists() {
    if (messages != []) {
      setState(() {
        messagesWidgets = messages
            .map((document) => buildMessageWidgetItem(document))
            .toList();
      });
    } else {
      setState(() {
        messagesWidgets = [];
      });
    }
    return messagesWidgets;
  }

  Widget buildMessageWidgetItem(Map<String, dynamic> data) {
    var alignment = (data['senderId'] == widget.userId)
        ? Alignment.centerRight
        : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
            crossAxisAlignment: (data['senderId'] == widget.userId)
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            mainAxisAlignment: (data['senderId'] == widget.userId)
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              ChatBubble(
                  message: data['message'],
                  sent: data['senderId'] == widget.userId),
            ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> messageList = buildMessageWidgetsLists();

    widget.msgDatabase.queryAll().then((data) {
      setState(() {
        messages = data;
      });
    });

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SingleChildScrollView(
            child: Column(
              children: messageList,
            ),
          ),
          const Spacer(),
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: widget.screenSize.width * 0.76,
                      child: MyTextField(
                          controller: msgController,
                          hintText: "Type message here")),
                  SizedBox(
                    width: widget.screenSize.width * 0.01,
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.blueGrey,
                        borderRadius: BorderRadius.circular(20)),
                    child: IconButton(
                        onPressed: () {
                          readDataFromLocalStorage("cords").then((data) {
                            List<String> cords = data!.split(",");

                            String lat = cords[0];
                            String lon = cords[1];

                            widget.socketChannel.sink.add(jsonEncode({
                              "action": "sendMessage",
                              "msg": msgController.text,
                              "time": DateTime.now().toString(),
                              "sender": widget.userId,
                              "lat": lat,
                              "lon": lon
                            }));
                            msgController.text = "";
                          });
                        },
                        icon: const Icon(Icons.send)),
                  )
                ],
              )),
          const SizedBox(height: 10)
        ],
      ),
    );
  }
}
