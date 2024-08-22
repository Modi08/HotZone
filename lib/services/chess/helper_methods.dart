bool isWhite(int index) {
  int x = index ~/ 8;
  int y = index % 8;

  return (x + y) % 2 == 0;
}

bool isInBoard(int row, int col) {
  if (row <= 7 && row >= 0 && col <= 7 && col >= 0) {
    return true;
  } else {
    return false;
  }
}
