import 'package:flutter/material.dart';
import 'package:nearmessageapp/components/chess/piece.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:nearmessageapp/values/chess/colors.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final void Function()? onTap;
  final bool isValidMove;

  const Square(
      {super.key,
      required this.isWhite,
      required this.piece,
      required this.isSelected,
      required this.onTap,
      required this.isValidMove,
      });

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    if (isSelected) {
      squareColor = Colors.amber;
    } else if (isValidMove) {
      squareColor = Colors.green;
    } else {
      squareColor = isWhite ? foregroundColor : backgroundColor;
    }

    return GestureDetector(
      onTap: onTap,
        child: Container(
          margin: EdgeInsets.all(isValidMove ? 8 : 0),
            color: squareColor,
            child: piece != null
                ? SvgPicture.asset(
                    piece!.imagePath,
                    // ignore: deprecated_member_use
                    color: piece!.isWhite ? Colors.white : Colors.black,
                  )
                : null));
  }
}
