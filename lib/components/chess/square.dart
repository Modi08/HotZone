import 'package:flutter/material.dart';
import 'package:nearmessageapp/components/chess/piece.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nearmessageapp/values/chess/colors.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;

  const Square({super.key, required this.isWhite, required this.piece});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isWhite ? foregroundColor: backgroundColor,
      child: piece != null ? SvgPicture.asset(piece!.imagePath, color: piece!.isWhite ? Colors.white : Colors.black,) : null
    );
  }
}
