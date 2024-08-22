enum ChessPieceType { pawn, rook, knight, bishop, queen, king }

class ChessPiece {
  final ChessPieceType type;
  final bool isWhite;
  
  ChessPiece({
    required this.type,
    required this.isWhite,
  });

  String get imagePath {
    switch (type) {
    case ChessPieceType.pawn:
      return "lib/assets/chess/pawn.svg";
    case ChessPieceType.knight:
      return "lib/assets/chess/knight.svg";
    case ChessPieceType.bishop:
      return "lib/assets/chess/bishop.svg";
    case ChessPieceType.rook:
      return "lib/assets/chess/rook.svg";
    case ChessPieceType.queen:
      return "lib/assets/chess/queen.svg";
    case ChessPieceType.king:
      return "lib/assets/chess/king.svg";
    default:
      return "error";
    }}
  }


