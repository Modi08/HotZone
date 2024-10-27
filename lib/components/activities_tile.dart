import 'package:flutter/material.dart';

class ActivitiesTile extends StatefulWidget {
  const ActivitiesTile({super.key, required this.userList, required this.type});
  final List<List<dynamic>> userList;
  final String type;

  @override
  State<ActivitiesTile> createState() => _ActivitiesTileState();
}

class _ActivitiesTileState extends State<ActivitiesTile> {
  List<Widget> userWidgetList = [];

  @override
  Widget build(BuildContext context) {
    userWidgetList = widget.userList.map((e) => Text(e[2])).toList();

    return DecoratedBox(
      decoration: BoxDecoration(
          border: Border.all(
              color: const Color.fromRGBO(255, 205, 67, 1), width: 2),
          color: Colors.amber[300]),
      child: Row(
        children: [
          Text(widget.type),
          const Spacer(),
          Column(
            children: [
              const Text("Users"),
              DecoratedBox(decoration: BoxDecoration(border: Border.all(color: Colors.black)), child: Column(children: userWidgetList,),)
            ],
          )
        ],
      ),
    );
  }
}
