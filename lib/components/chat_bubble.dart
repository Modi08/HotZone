import 'package:flutter/material.dart';
import 'package:nearmessageapp/values/general/colors.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool sent;
  const ChatBubble({super.key, required this.message, required this.sent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          color: (sent) ? accentColorPrimary : accentColorSecondary),
      child: Text(
        message,
        style: TextStyle(fontSize: 16, color: textColorSecondary),
      ),
    );
  }
}
