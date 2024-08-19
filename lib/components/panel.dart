import 'package:flutter/material.dart';

class Panel extends StatefulWidget {
  Panel(
      {super.key,
      required this.title,
      required this.width, required this.selected});
  final String title;
  final double width;
  bool selected = true;

  @override
  State<Panel> createState() => _PanelState();
}

class _PanelState extends State<Panel> {

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(widget.title,
                style: const TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontWeight: FontWeight.bold)),
        Container(
            height: widget.selected ? 2.5 : 0,
            width: widget.width,
            decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 255, 255, 1),
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: const Color.fromRGBO(255, 255, 255, 1)))),
        const SizedBox(height: 15)
      ],
    );
  }
}
