import 'package:flutter/material.dart';
import 'package:nearmessageapp/components/chess/piece.dart';
import 'package:nearmessageapp/components/chess/square.dart';
import 'package:nearmessageapp/services/chess/helper_methods.dart';

class Activiespage extends StatefulWidget {
  const Activiespage({super.key});

  @override
  State<Activiespage> createState() => _ActiviespageState();
}

class _ActiviespageState extends State<Activiespage> {
  late List<List<ChessPiece?>> board;

  final myPawn = ChessPiece(
      type: ChessPieceType.pawn,
      isWhite: true,
      imagePath: 'lib/assets/chess/pawn.svg');

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 8, childAspectRatio: 1.2),
      itemBuilder: (context, index) => Square(
        isWhite: isWhite(index),
        piece: myPawn,
      ),
      itemCount: 64,
    );
  }
}
