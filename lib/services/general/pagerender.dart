import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:location/location.dart';
import 'package:nearmessageapp/components/panel.dart';
import 'package:nearmessageapp/pages/activiespage.dart';
import 'package:nearmessageapp/pages/homepage.dart';
import 'package:nearmessageapp/pages/userpage.dart';
import 'package:nearmessageapp/services/general/socket.dart';
import 'package:nearmessageapp/services/auth/auth_gate.dart';
import 'package:nearmessageapp/services/general/localstorage.dart';
import 'package:nearmessageapp/services/general/cordslocation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PageRender extends StatefulWidget {
  const PageRender({super.key, required this.title});
  final String title;

  @override
  State<PageRender> createState() => _PageRenderState();
}

class _PageRenderState extends State<PageRender> {
  late WebSocketChannel socket;
  String? userId = "";
  int pageSelected = 0;

  void joinRoom(data) async {
    Future<String?> parUserID = readDataFromLocalStorage("userId");

    await dotenv.load();
    String? apiUrl = dotenv.env["Websocket_URL"];

    parUserID.then((userID) {
      final paramsApiUrl =
          "$apiUrl?lat=${data[0]}&long=${data[1]}&userId=$userID";

      setState(() {
        socket = connectToWebsocket(paramsApiUrl);
        userId = userID;
      });
      socket.sink.add(jsonEncode(
          {"action": "ChatDetails", "lat": data[0], "long": data[1]}));
      listendMsg(socket);
    });
  }

  void switchPage(int pageNum) {
    setState(() {
      pageSelected = pageNum;
    });
    print(pageSelected);
  }

  @override
  void initState() {
    super.initState();
    Future<bool> status = Location().serviceEnabled();
    status.then((data) {
      if (data) {
        getLocation().then((data) => joinRoom(data));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    requestLocationPermission();

    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 70,
            backgroundColor: const Color.fromARGB(255, 0, 34, 255),
            title: Column(
              children: [
                Row(
                  children: <Widget>[
                    Text(widget.title, style: const TextStyle(color: Color.fromRGBO(255, 255, 255, 1)),),
                    const Spacer(),
                    IconButton(
                        onPressed: () {
                          socket.sink.close();
                          clearSharedPreferences();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const AuthGate()));
                        },
                        icon: const Icon(Icons.logout))
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            pageSelected = 0;
                          });
                        },
                        child: Panel(
                            title: "General chat",
                            width: 100,
                            selected: pageSelected == 0)),
                    const SizedBox(width: 10),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            pageSelected = 1;
                          });
                        },
                        child: Panel(
                            title: "Users",
                            width: 50,
                            selected: pageSelected == 1)),
                    const SizedBox(width: 10),
                    TextButton(
                        onPressed: () {
                          setState(() {
                            pageSelected = 2;
                          });
                        },
                        child: Panel(
                            title: "Activities",
                            width: 70,
                            selected: pageSelected == 2))
                  ],
                ),
              ],
            )),
        body: userId != ""
            ? pageSelected == 0
                ? HomePage(userId: userId, socketChannel: socket)
                : pageSelected == 1
                    ? Userpage(socketChannel: socket, userId: userId!)
                    : const ChessGame()
            : const Center(
                child: SizedBox(child: CircularProgressIndicator.adaptive())));
  }
}
