import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nearmessageapp/pages/activitiespage.dart';
import 'package:nearmessageapp/pages/profilepage.dart';
import 'package:nearmessageapp/services/chess/chessGame.dart';
import 'package:nearmessageapp/pages/homepage.dart';
import 'package:nearmessageapp/pages/userpage.dart';
import 'package:nearmessageapp/services/general/socket.dart';
import 'package:nearmessageapp/services/auth/auth_gate.dart';
import 'package:nearmessageapp/services/storage/keyValueStore.dart';
import 'package:nearmessageapp/services/storage/msgStore.dart';
import 'package:nearmessageapp/services/storage/userStore.dart';
import 'package:nearmessageapp/services/general/cordslocation.dart';
import 'package:nearmessageapp/values/general/colors.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class PageRender extends StatefulWidget {
  const PageRender(
      {super.key,
      required this.title,
      required this.userId,
      required this.screenSize,
      required this.userData,
      required this.userDatabase,
      required this.msgDatabase});
  final String title;
  final String userId;
  final Size screenSize;
  final User userData;
  final DatabaseServiceUser userDatabase;
  final DatabaseServiceMsg msgDatabase;

  @override
  State<PageRender> createState() => _PageRenderState();
}

class _PageRenderState extends State<PageRender> {
  bool isSocketInitialized = false;
  late WebSocketChannel socket;
  String? profilePic;
  int pageSelected = 0;

  void refreshPage() {
    setState(() {
      pageSelected = pageSelected;
    });
  }

  void joinRoom(data) async {
    await dotenv.load();
    String? apiUrl = dotenv.env["Websocket_URL"];

    final paramsApiUrl =
        "$apiUrl?lat=${data[0]}&long=${data[1]}&userId=${widget.userId}";

    debugPrint("Connecting to: $paramsApiUrl");

    setState(() {
      socket = connectToWebsocket(paramsApiUrl);
      isSocketInitialized = true;
    });

    socket.sink.add(
        jsonEncode({"action": "ChatDetails", "lat": data[0], "long": data[1]}));
    listendMsg(socket, refreshPage, widget.msgDatabase, widget.userDatabase, widget.userId);
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
            builder: (context) => Profilepage(
                  userId: widget.userId,
                  socketChannel: socket,
                  userData: widget.userData,
                  userDatabase: widget.userDatabase,
                )));
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      profilePic = widget.userData.profilePic;
    });
    
    Future<bool> status = requestLocationPermission();
    status.then((data) {
      if (data) {
        getLocation().then((data) => joinRoom(data));
      }
    });
  }

  /*@override
  void dispose() {
    widget.userDatabase.clearAll();
    widget.msgDatabase.clearAll();
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    if (!isSocketInitialized) {
      requestLocationPermission();
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

                                readDataFromLocalStorage("cords")
                                    .then((roomId) {
                                  socket.sink.add(jsonEncode({
                                    "action": "joinGame",
                                    "player1": res["userId"],
                                    "player2": widget.userId,
                                    "isPlayer": "True",
                                    "roomId": roomId,
                                  }));
                                });
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
      debugPrint(gameInfo["gameId"]);
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => ChessGame(
                oppName: gameInfo["oppName"],
                isWhite: gameInfo["isWhite"],
                socketChannel: socket,
                gameId: gameInfo["gameId"],
                screenSize: widget.screenSize)),
      );

      saveDataToLocalStorage("userGame", "");
    });

    return Scaffold(
        appBar: AppBar(
            toolbarHeight: widget.screenSize.height * 0.12,
            backgroundColor: backgroundColorPrimary,
            title: Column(
              children: [
                Row(
                  children: <Widget>[
                    isSocketInitialized
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
                                icon: Icon(
                                  Icons.upload,
                                  color: textColorPrimary,
                                ))
                        : const SizedBox(),
                    Text(
                      widget.title,
                      style: TextStyle(
                        color: textColorPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                        onPressed: () {
                          socket.sink.close();
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AuthGate(
                                        userDatabase: widget.userDatabase,
                                        msgDatabase: widget.msgDatabase,
                                      )),
                              (route) => false);
                        },
                        icon: Icon(
                          Icons.logout,
                          color: textColorPrimary,
                        ))
                  ],
                ),
              ],
            )),
        bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: accentColorPrimary,
          unselectedItemColor: textColorPrimary,
          backgroundColor: backgroundColorPrimary,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
                icon: Icon(Icons.chat),
                label: 'General Chat',
                tooltip: 'Go to General Chat'),
            BottomNavigationBarItem(
                icon: Icon(Icons.people),
                label: 'Users',
                tooltip: 'Go to Profile Page'),
            BottomNavigationBarItem(
                icon: Icon(Icons.leaderboard),
                label: 'Activites',
                tooltip: 'Go to Settings Page'),
          ],
          currentIndex: pageSelected,
          onTap: switchPage,
        ),
        body: isSocketInitialized
            ? pageSelected == 0
                ? HomePage(
                    userId: widget.userId,
                    socketChannel: socket,
                    screenSize: widget.screenSize,
                    msgDatabase: widget.msgDatabase,
                  )
                : pageSelected == 1
                    ? Userpage(
                        socketChannel: socket,
                        userId: widget.userId,
                        userData: widget.userData,
                        userDatabase: widget.userDatabase,
                      )
                    : Activitiespage(socketChannel: socket)
            /*ChessGame(
                        oppName: "Ekansh",
                        isWhite: true,
                        socketChannel: socket,
                        gameId: "123456789098765432123456789",
                      )*/
            : const Center(
                child: SizedBox(child: CircularProgressIndicator.adaptive())));
  }
}
