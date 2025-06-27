import 'dart:convert';

import 'package:nearmessageapp/services/storage/keyValueStore.dart';
import 'package:nearmessageapp/services/storage/msgStore.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Cords {
  final double lat;
  final double lon;

  Cords(this.lat, this.lon);
}

WebSocketChannel connectToWebsocket(paramsApiUrl) {
  print("connected");
  final socket = WebSocketChannel.connect(Uri.parse(paramsApiUrl));
  return socket;
}

void listendMsg(WebSocketChannel socket, Function refreshPage, DatabaseServiceMsg msgDatabase) {
  socket.stream.listen((data) {
    Map<String, dynamic> res = jsonDecode(data)["data"];
    processMsg(res["statusCode"], res, socket, refreshPage, msgDatabase);
  }).onDone(() {
    socket.sink.close();
  });
}

void processMsg(
    int statusCode,
    Map<String, dynamic> data,
    WebSocketChannel socket,
    Function refreshPage,
    DatabaseServiceMsg msgDatabase) {
  print(statusCode.toString());

  switch (statusCode) {
    case 100: // Empty Message
      break;

    case 201: // Get room details
      List<String> cords = data["roomId"].split(",");

      Cords location = Cords(double.parse(cords[0]), double.parse(cords[1]));
      saveDataToLocalStorage("cords", "${location.lat},${location.lon}");
      var messages = jsonDecode(data["msgs"]);
      msgDatabase.clearAll();
      for (var msg in messages) {
        msgDatabase.insert(Message.fromMap(msg, true));
      }
      
      break;

    case 202: // New message recieved
      msgDatabase.insert(Message.fromMap(data["msg"], true));
      break;

    case 203: // User List recived
      if (data["userList"] != "[]") {
        List<dynamic> userList = jsonDecode(data["userList"])[0];
        for (var user in userList) {
          print(user.toString());
        }
      } else {
        saveDataToLocalStorage("userList", "[0]");
      }

    case 204: // User recived a challenge
      saveDataToLocalStorage("userChallenge", jsonEncode(data["body"]));
      refreshPage();

    case 205: // User Has to play a game
      saveDataToLocalStorage("userGame", jsonEncode(data["body"]));
      refreshPage();

    case 206: // New move has come in
      saveDataToLocalStorage("move", jsonEncode(data["body"]));

    case 207: // Activities List recived

      if (data["activities"] != "[]") {
        var activities = jsonDecode(data["activities"]);
        print(activities);
        saveDataToLocalStorage("activitiesList", jsonEncode(activities));
      } else {
        saveDataToLocalStorage("activitiesList", "[0]");
      }
  }
}
