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

void listendMsg(WebSocketChannel socket) {
  socket.stream.listen((data) {
    Map<String, dynamic> res = jsonDecode(data)["data"];
    processMsg(res["statusCode"], res, socket);
  }).onDone(() {
    socket.sink.close();
  });
}

void processMsg(
    int statusCode, Map<String, dynamic> data, WebSocketChannel socket) {
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
      saveDataToLocalStorage("userList", data["userList"]);
  }
}
