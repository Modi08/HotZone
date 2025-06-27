import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nearmessageapp/components/activities_tile.dart';
import 'package:nearmessageapp/services/storage/keyValueStore.dart';
import 'package:nearmessageapp/services/storage/userStore.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Activitiespage extends StatefulWidget {
  const Activitiespage({super.key, required this.socketChannel});
  final WebSocketChannel socketChannel;

  @override
  State<Activitiespage> createState() => _ActivitiespageState();
}

class _ActivitiespageState extends State<Activitiespage> {
  List<dynamic> activitiesList = [];
  List<Widget> activitiesWidgetList = [];

  List<Widget> buildActivitiesItemList(List<dynamic> activitiesList) {
    List<Widget> activitiesWidgetList =
        activitiesList.map((document) => buildActivityItem(document[2], document[1])).toList();

    return activitiesWidgetList;
  }

  Widget buildActivityItem(List<dynamic> activeUsersUnOrdered, String type) {
    List<List<dynamic>> activeUsers = activeUsersUnOrdered.map((e) {
      List<dynamic> activeUser = e.map((w) => w.toString()).toList();
      return activeUser;
    }).toList();


    return ActivitiesTile(userList: activeUsers, type: type);
  }

  @override
  void initState() {
    super.initState();
    saveDataToLocalStorage("activitiesList", "[]");
    readDataFromLocalStorage("cords").then((data) {
      widget.socketChannel.sink
          .add(jsonEncode({"action": "activitiesDetails", "roomId": data}));
    });
  }

  @override
  Widget build(BuildContext context) {
    readDataFromLocalStorage("activitiesList").then((data) {
      if (data != "[]" && data != "[0]") {
        if (activitiesList.length != jsonDecode(data!).length) {
          setState(() {
            activitiesList = jsonDecode(data);
            activitiesWidgetList = buildActivitiesItemList(activitiesList);
          });
        }
      } else if (data == "[0]") {
        setState(() {
          activitiesList = [0];
        });
      } else {
        setState(() {
          activitiesList = [];
        });
      }
    });

    return activitiesList.isEmpty
        ? const Center(
            child: SizedBox(child: CircularProgressIndicator.adaptive()))
        : activitiesList[0] != 0
            ? Padding(
                padding: const EdgeInsets.all(8),
                child: Column(children: activitiesWidgetList))
            : const Center(child: SizedBox(child: Text("No Users Found")));
  }
}
