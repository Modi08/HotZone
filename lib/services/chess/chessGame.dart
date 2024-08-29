import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nearmessageapp/components/chess/deadpiece.dart';
import 'package:nearmessageapp/components/chess/piece.dart';
import 'package:nearmessageapp/components/chess/square.dart';
import 'package:nearmessageapp/services/chess/helper_methods.dart';
import 'package:nearmessageapp/services/general/localstorage.dart';
import 'package:nearmessageapp/values/chess/colors.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ChessGame extends StatefulWidget {
  const ChessGame(
      {super.key,
      required this.oppName,
      required this.isWhite,
      required this.socketChannel,
      required this.gameId});
  final String oppName;
  final bool isWhite;
  final WebSocketChannel socketChannel;
  final String gameId;

  @override
  State<ChessGame> createState() => _ChessGameState();
}

class _ChessGameState extends State<ChessGame> {
  late List<List<ChessPiece?>> board;

  ChessPiece? selectedPiece;

  int selectedRow = -1;
  int selectedCol = -1;

  List<List<int>> validMoves = [];

  List<ChessPiece> whitePiecesTaken = [];
  List<ChessPiece> blackPiecesTaken = [];

  bool isWhiteTurn = true;

  List<int> whiteKingPos = [7, 4];
  List<int> blackKingPos = [0, 4];

  bool checkStatus = false;

  @override
  void initState() {
    super.initState();
    initializeBoard();

    blackKingPos = widget.isWhite ? [7, 4] : [0, 4];
    blackKingPos = widget.isWhite ? [0, 4] : [7, 4];

    saveDataToLocalStorage("move", "");
  }

  void initializeBoard() {
    List<List<ChessPiece?>> newBoard =
        List.generate(8, (index) => List.generate(8, (index) => null));

    for (int i = 0; i < 8; i++) {
      newBoard[1][i] =
          ChessPiece(type: ChessPieceType.pawn, isWhite: !widget.isWhite, lastSquare: [1, i]);
      newBoard[6][i] =
          ChessPiece(type: ChessPieceType.pawn, isWhite: widget.isWhite, lastSquare: [6, i]);
    }

    for (int i in [0, 7]) {
      newBoard[0][i] =
          ChessPiece(type: ChessPieceType.rook, isWhite: !widget.isWhite, lastSquare: [0, i]);
      newBoard[7][i] =
          ChessPiece(type: ChessPieceType.rook, isWhite: widget.isWhite, lastSquare: [7, i]);
    }

    for (int i in [1, 6]) {
      newBoard[0][i] =
          ChessPiece(type: ChessPieceType.knight, isWhite: !widget.isWhite, lastSquare: [0, i]);
      newBoard[7][i] =
          ChessPiece(type: ChessPieceType.knight, isWhite: widget.isWhite, lastSquare: [7, i]);
    }

    for (int i in [2, 5]) {
      newBoard[0][i] =
          ChessPiece(type: ChessPieceType.bishop, isWhite: !widget.isWhite, lastSquare: [0, i]);
      newBoard[7][i] =
          ChessPiece(type: ChessPieceType.bishop, isWhite: widget.isWhite, lastSquare: [7, i]);
    }

    newBoard[0][3] =
        ChessPiece(type: ChessPieceType.queen, isWhite: !widget.isWhite, lastSquare: [0, 3]);
    newBoard[7][3] =
        ChessPiece(type: ChessPieceType.queen, isWhite: widget.isWhite, lastSquare: [7, 3]);

    newBoard[0][4] =
        ChessPiece(type: ChessPieceType.king, isWhite: !widget.isWhite, lastSquare: [0, 4]);
    newBoard[7][4] =
        ChessPiece(type: ChessPieceType.king, isWhite: widget.isWhite, lastSquare: [7, 4]);

    board = newBoard;
  }

  void pieceSelected(int row, int col) {
    /*if (board[row][col] != null && board[row][col]!.isWhite == widget.isWhite) {
      return;
    }*/
    setState(() {
      if (board[row][col] != null && (selectedPiece == null)) {
        if (board[row][col]!.isWhite == isWhiteTurn) {
          selectedCol = col;
          selectedRow = row;
          selectedPiece = board[row][col];
        }
      } else if (board[row][col] != null &&
          selectedPiece!.isWhite == board[row][col]!.isWhite) {
        selectedCol = col;
        selectedRow = row;
        selectedPiece = board[row][col];
      } else if (selectedPiece != null &&
          validMoves.any((element) => element[0] == row && element[1] == col)) {
        if (selectedPiece!.type == ChessPieceType.king) {
          if (selectedPiece!.isWhite) {
            whiteKingPos = [row, col];
          } else {
            blackKingPos = [row, col];
          }
        }
        selectedPiece;
        movePiece(row, col, selectedPiece!);
      }

      if (selectedPiece != null) {
        validMoves = calulateRealValidMoves(
            selectedRow, selectedCol, selectedPiece!, true);
      } else {
        validMoves = [];
      }
    });
  }

  List<List<int>> calulateRawValidMoves(int row, int col, ChessPiece piece) {
    List<List<int>> candiateMoves = [];

    int direction = widget.isWhite
        ? piece.isWhite
            ? -1
            : 1
        : !piece.isWhite
            ? -1
            : 1;

    switch (piece.type) {
      case ChessPieceType.pawn:
        if (isInBoard(row + direction, col) &&
            board[row + direction][col] == null) {
          candiateMoves.add([row + direction, col]);
        }
        if (widget.isWhite) {
          if ((piece.isWhite && row == 6) || (!piece.isWhite && row == 1)) {
            if (board[row + direction * 2][col] == null &&
                board[row + direction][col] == null) {
              candiateMoves.add([row + direction * 2, col]);
            }
          }
        } else {
          if ((!piece.isWhite && row == 6) || (piece.isWhite && row == 1)) {
            if (board[row + direction * 2][col] == null &&
                board[row + direction][col] == null) {
              candiateMoves.add([row + direction * 2, col]);
            }
          }
        }
        if (isInBoard(row + direction, col + 1) &&
            board[row + direction][col + 1] != null &&
            board[row + direction][col + 1]!.isWhite != piece.isWhite) {
          candiateMoves.add([row + direction, col + 1]);
        }

        if (isInBoard(row + direction, col - 1) &&
            board[row + direction][col - 1] != null &&
            board[row + direction][col - 1]!.isWhite != piece.isWhite) {
          candiateMoves.add([row + direction, col - 1]);
        }
        break;

      case ChessPieceType.knight:
        var knightMoves = [
          [-2, -1],
          [-2, 1],
          [-1, -2],
          [-1, 2],
          [1, -2],
          [1, 2],
          [2, -1],
          [2, 1]
        ];

        for (var move in knightMoves) {
          var newRow = row + move[0];
          var newCol = col + move[1];
          if (!isInBoard(newRow, newCol)) {
            continue;
          }
          if (board[newRow][newCol] != null &&
              board[newRow][newCol]!.isWhite != piece.isWhite) {
            candiateMoves.add([newRow, newCol]);
          } else if (board[newRow][newCol] == null) {
            candiateMoves.add([newRow, newCol]);
          }
        }

        break;

      case ChessPieceType.bishop:
        var directions = [
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1],
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            } else if (board[newRow][newCol] != null &&
                board[newRow][newCol]!.isWhite != piece.isWhite) {
              candiateMoves.add([newRow, newCol]);
              break;
            } else if (board[newRow][newCol] == null) {
              candiateMoves.add([newRow, newCol]);
              i += 1;
            } else {
              break;
            }
          }
        }

      case ChessPieceType.rook:
        var directions = [
          [0, -1],
          [0, 1],
          [1, 0],
          [-1, 0],
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            } else if (board[newRow][newCol] != null &&
                board[newRow][newCol]!.isWhite != piece.isWhite) {
              candiateMoves.add([newRow, newCol]);
              break;
            } else if (board[newRow][newCol] == null) {
              candiateMoves.add([newRow, newCol]);
              i += 1;
            } else {
              break;
            }
          }
        }

      case ChessPieceType.queen:
        var directions = [
          [0, -1],
          [0, 1],
          [1, 0],
          [-1, 0],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1]
        ];

        for (var direction in directions) {
          var i = 1;
          while (true) {
            var newRow = row + i * direction[0];
            var newCol = col + i * direction[1];
            if (!isInBoard(newRow, newCol)) {
              break;
            } else if (board[newRow][newCol] != null &&
                board[newRow][newCol]!.isWhite != piece.isWhite) {
              candiateMoves.add([newRow, newCol]);
              break;
            } else if (board[newRow][newCol] == null) {
              candiateMoves.add([newRow, newCol]);
              i += 1;
            } else {
              break;
            }
          }
        }

      case ChessPieceType.king:
        var directions = [
          [0, -1],
          [0, 1],
          [1, 0],
          [-1, 0],
          [-1, -1],
          [-1, 1],
          [1, -1],
          [1, 1]
        ];

        for (var direction in directions) {
          var newRow = row + direction[0];
          var newCol = col + direction[1];

          if (!isInBoard(newRow, newCol)) {
            break;
          } else if (board[newRow][newCol] != null &&
              board[newRow][newCol]!.isWhite != piece.isWhite) {
            candiateMoves.add([newRow, newCol]);
            break;
          } else if (board[newRow][newCol] == null) {
            candiateMoves.add([newRow, newCol]);
          } else {
            break;
          }
        }

      default:
        break;
    }
    return candiateMoves;
  }

  List<List<int>> calulateRealValidMoves(
      int row, int col, ChessPiece piece, bool checkSim) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candiateMoves = calulateRawValidMoves(row, col, piece);

    if (checkSim) {
      for (var move in candiateMoves) {
        int endRow = move[0];
        int endCol = move[1];
        if (simulatedMoveIsSafe(piece, row, col, endRow, endCol)) {
          realValidMoves.add(move);
        }
      }
    } else {
      realValidMoves = candiateMoves;
    }

    return realValidMoves;
  }

  void movePiece(int newRow, int newCol, ChessPiece piece) {
    //print("$newRow, $newCol");
    //print(piece.lastSquare);

    if (board[newRow][newCol] != null) {
      if (board[newRow][newCol]!.isWhite) {
        whitePiecesTaken.add(board[newRow][newCol]!);
      } else {
        blackPiecesTaken.add(board[newRow][newCol]!);
      }
    }

    board[newRow][newCol] = selectedPiece;
    board[selectedRow][selectedCol] = null;

    if (isKingInCheck(!isWhiteTurn)) {
      checkStatus = true;
    } else {
      checkStatus = false;
    }

    setState(() {
      selectedRow = -1;
      selectedCol = -1;
      selectedPiece = null;
      validMoves = [];
    });

    if (isCheckMate(!isWhiteTurn)) {
      showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text("CHECK MATE"),
                actions: [
                  TextButton(
                      onPressed: resetGame, child: const Text("Play Again")),
                  TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: const Text("Exit"))
                ],
              ));
    }

    isWhiteTurn = !isWhiteTurn;
    widget.socketChannel.sink.add(jsonEncode({"action": "playMove", "currentPos": piece.lastSquare, "nextPos": [newRow, newCol], "gameId": widget.gameId, "isWhite": widget.isWhite}));
  }

  bool isKingInCheck(bool isWhiteKing) {
    List<int> kingPos = isWhiteKing ? whiteKingPos : blackKingPos;

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calulateRawValidMoves(i, j, board[i][j]!);

        if (pieceValidMoves
            .any((move) => move[0] == kingPos[0] && move[1] == kingPos[1])) {
          return true;
        }
      }
    }
    return false;
  }

  bool simulatedMoveIsSafe(
      ChessPiece piece, int startRow, int startCol, int endRow, int endCol) {
    ChessPiece? originalDesPiece = board[endRow][endCol];

    List<int>? originalKingPos;
    if (piece.type == ChessPieceType.king) {
      originalKingPos = piece.isWhite ? whiteKingPos : blackKingPos;

      if (piece.isWhite) {
        whiteKingPos = [endRow, endCol];
      } else {
        blackKingPos = [endRow, endCol];
      }
    }

    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    bool kingInCheck = isKingInCheck(piece.isWhite);

    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDesPiece;

    if (piece.type == ChessPieceType.king) {
      if (piece.isWhite) {
        whiteKingPos = originalKingPos!;
      } else {
        blackKingPos = originalKingPos!;
      }
    }

    return !kingInCheck;
  }

  bool isCheckMate(bool isWhiteKing) {
    if (!isKingInCheck(isWhiteKing)) {
      return false;
    }

    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves =
            calulateRealValidMoves(i, j, board[i][j]!, true);

        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    return true;
  }

  void resetGame({bool needToClearScreen = true}) {
    if (needToClearScreen) {
      Navigator.pop(context);
    }
    initializeBoard();
    setState(() {
      selectedPiece = null;

      selectedRow = -1;
      selectedCol = -1;

      validMoves.clear();
      whitePiecesTaken.clear();
      blackPiecesTaken.clear();

      isWhiteTurn = true;
      checkStatus = false;

      whiteKingPos = widget.isWhite ? [7, 4] : [0, 4];
      blackKingPos = widget.isWhite ? [0, 4] : [7, 4];
    });
  }

  @override
  Widget build(BuildContext context) {
    readDataFromLocalStorage("move").then((value) {
     print(value); 
    });
    return Scaffold(
        backgroundColor: backgroundColor,
        body: Column(children: [
          const SizedBox(height: 30),
          Row(
            children: [
              IconButton(
                  onPressed: () {
                    resetGame(needToClearScreen: false);
                  },
                  icon: const Icon(Icons.restart_alt_sharp)),
              const Spacer(),
              IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.logout))
            ],
          ),
          Expanded(
              child: GridView.builder(
                  itemCount: whitePiecesTaken.length,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) => DeadPiece(
                      imagePath: whitePiecesTaken[index].imagePath,
                      isWhite: true))),
          widget.isWhite
              ? Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Icon(Icons.circle, size: 17, color: Colors.yellow[700]),
                  const SizedBox(width: 5),
                  const Icon(Icons.circle, size: 35),
                  const SizedBox(width: 10),
                  Text(widget.oppName)
                ])
              : const SizedBox(),
          Text(
            checkStatus ? "CHECK!!" : "",
            style: const TextStyle(
              fontSize: 25,
            ),
          ),
          Expanded(
            flex: 4,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8, childAspectRatio: 1.2),
              itemBuilder: (context, index) {
                int row = index ~/ 8;
                int col = index % 8;

                bool isSelected = selectedRow == row && selectedCol == col;

                bool isValidMove = false;

                for (List<int> move in validMoves) {
                  if (row == move[0] && col == move[1]) {
                    isValidMove = true;
                  }
                }

                return Square(
                  isWhite: isWhite(index),
                  piece: board[row][col],
                  isSelected: isSelected,
                  onTap: () => pieceSelected(row, col),
                  isValidMove: isValidMove,
                  isInverted: !widget.isWhite,
                );
              },
              itemCount: 64,
            ),
          ),
          !widget.isWhite
              ? Row(mainAxisAlignment: MainAxisAlignment.start, children: [
                  Icon(Icons.circle, size: 17, color: Colors.yellow[700]),
                  const SizedBox(width: 5),
                  const Icon(Icons.circle, size: 35),
                  const SizedBox(width: 10),
                  Text(widget.oppName)
                ])
              : const SizedBox(),
          Expanded(
              child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: blackPiecesTaken.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 8),
                  itemBuilder: (context, index) => DeadPiece(
                      imagePath: blackPiecesTaken[index].imagePath,
                      isWhite: false)))
        ]));
  }
}
