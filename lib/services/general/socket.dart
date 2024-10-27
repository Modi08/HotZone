import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:nearmessageapp/services/general/localstorage.dart';

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

void listendMsg(WebSocketChannel socket, Function refreshPage) {
  socket.stream.listen((data) {
    Map<String, dynamic> res = jsonDecode(data)["data"];
    processMsg(res["statusCode"], res, socket, refreshPage);
  }).onDone(() {
    socket.sink.close();
  });
}

void processMsg(
    int statusCode, Map<String, dynamic> data, WebSocketChannel socket, Function refreshPage) {
  print(statusCode);
  switch (statusCode) {
    case 100: // Empty Message
      break;
    
    case 201: // Get room details
      List<String> cords = data["roomId"].split(",");

      Cords location = Cords(double.parse(cords[0]), double.parse(cords[1]));
      saveDataToLocalStorage("cords", "${location.lat},${location.lon}");
      saveDataToLocalStorage("messages", data["msgs"]);

      break;
    
    case 202: // New message recieved
      var messages = readDataFromLocalStorage("messages");
      Map<String, dynamic> newMessage = data["msg"];
      messages.then((data) {
        List<dynamic> messages = jsonDecode(data!);
        messages.add(newMessage);
        saveDataToLocalStorage("messages", jsonEncode(messages));
      });
      break;
    
    case 203: // User List recived
      if (data["userList"] != "[]") {
        var message = jsonDecode(data["userList"])[0];
        saveDataToLocalStorage("userList", jsonEncode([message]));
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
