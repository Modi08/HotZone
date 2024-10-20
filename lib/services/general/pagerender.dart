import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:location/location.dart';
import 'package:nearmessageapp/components/panel.dart';
import 'package:nearmessageapp/pages/profilepage.dart';
import 'package:nearmessageapp/services/chess/chessGame.dart';
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
  bool isSocketInitialized = false;
  late WebSocketChannel socket;
  String? userId;
  String? profilePic;
  int pageSelected = 0;

  void refreshPage() {
    setState(() {
      pageSelected = pageSelected;
    });
  }

  void joinRoom(data) async {
    print(data);
    Future<String?> parUserID = readDataFromLocalStorage("userId");

    await dotenv.load();
    String? apiUrl = dotenv.env["Websocket_URL"];

    parUserID.then((userID) {
      final paramsApiUrl =
          "$apiUrl?lat=${data[0]}&long=${data[1]}&userId=$userID";

      setState(() {
        socket = connectToWebsocket(paramsApiUrl);
        userId = userID;
        isSocketInitialized = true;
      });
      socket.sink.add(jsonEncode(
          {"action": "ChatDetails", "lat": data[0], "long": data[1]}));
      listendMsg(socket, refreshPage);
    });
  }

  void switchPage(int pageNum) {
    setState(() {
      pageSelected = pageNum;
    });
  }

  void pushProfilePage() {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                Profilepage(userId: userId!, socketChannel: socket)));
  }

  @override
  void initState() {
    super.initState();
    requestLocationPermission();

    Future<bool> status = Location().serviceEnabled();
    status.then((data) {
      if (data) {
        getLocation().then((data) => joinRoom(data));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!isSocketInitialized) {
      requestLocationPermission();
/*
      Future<bool> status = Location().serviceEnabled();
      status.then((data) {
        if (data) {
          getLocation().then((data) => joinRoom(data));
        }
      });*/
    }

    readDataFromLocalStorage("userChallenge").then((data) {
      if (data == null || data == "") {
        return null;
      }

      Map<String, dynamic> res = jsonDecode(data);

      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("New Game Challenge",
                    style: TextStyle(fontSize: 25)),
                actions: [
                  Column(
                    children: [
                      Text(
                        "${res["username"]} challenged you to a game of ${res["type"]}",
                        style: const TextStyle(fontSize: 17),
                      ),
                      Row(
                        children: [
                          const Spacer(),
                          TextButton(
                              onPressed: () {
                                Navigator.pop(context);

                                readDataFromLocalStorage("userId")
                                    .then((data) {});
                                socket.sink.add(jsonEncode({
                                  "action": "joinGame",
                                  "player1": res["userId"],
                                  "player2": userId,
                                  "isPlayer": "True",
                                }));
                              },
                              child: const Text("Accept"))
                        ],
                      )
                    ],
                  )
                ],
              ));

      saveDataToLocalStorage("userChallenge", "");
    });

    readDataFromLocalStorage("userGame").then((data) {
      if (data == null || data == "") {
        return null;
      }
      Map<String, dynamic> gameInfo = jsonDecode(data);
      print(gameInfo["gameId"]);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChessGame(
                oppName: gameInfo["oppName"],
                isWhite: gameInfo["isWhite"],
                socketChannel: socket,
                gameId: gameInfo["gameId"])),
      );

      saveDataToLocalStorage("userGame", "");
    });

    readDataFromLocalStorage("profilePic").then((data) {
      if (data != "") {
        setState(() {
          profilePic = data;
        });
      }
    });

    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 100,
            backgroundColor: const Color.fromARGB(255, 0, 34, 255),
            title: Column(
              children: [
                Row(
                  children: <Widget>[
                    userId != null
                        ? profilePic != null
                            ? OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    side: BorderSide.none),
                                onPressed: () {
                                  pushProfilePage();
                                },
                                child: Stack(children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: NetworkImage(profilePic!),
                                  )
                                ]))
                            : IconButton(
                                onPressed: () {
                                  pushProfilePage();
                                },
                                icon: const Icon(Icons.upload))
                        : const SizedBox(),
                    Text(
                      widget.title,
                      style: const TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1)),
                    ),
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
        body: userId != null
            ? pageSelected == 0
                ? HomePage(userId: userId, socketChannel: socket)
                : pageSelected == 1
                    ? Userpage(socketChannel: socket, userId: userId!)
                    : ChessGame(
                        oppName: "Ekansh",
                        isWhite: true,
                        socketChannel: socket,
                        gameId: "123456789098765432123456789",
                      )
            : const Center(
                child: SizedBox(child: CircularProgressIndicator.adaptive())));
  }
}
