bool isWhite(int index) {
  int x = index ~/ 8;
  int y = index % 8;

  return (x + y) % 2 == 0;
}
