import 'package:flutter/material.dart';

class UserTile extends StatefulWidget {
  const UserTile({super.key, required this.name, required this.email});
  final String name;
  final String email;

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
        decoration: BoxDecoration(
            color: const Color.fromARGB(255, 178, 227, 249),
            boxShadow: [BoxShadow(
              color: const Color.fromARGB(255, 193, 193, 193).withOpacity(0.5), spreadRadius: 8, offset: const Offset(0, 3)
            )],
            borderRadius: BorderRadius.circular(50),
            border: Border.all(color: const Color.fromARGB(255, 69, 60, 255))),
        child: SizedBox(
            height: 150,
            width: 150,
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Text(widget.name), Text(widget.email)])));
  }
}
