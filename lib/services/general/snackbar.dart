import 'package:flutter/material.dart';

void showSnackbar(context, String msg, bool isError) {
  SnackBar snackBar = SnackBar(content: Text(msg), backgroundColor: isError ? Colors.redAccent : Colors.greenAccent,);
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
