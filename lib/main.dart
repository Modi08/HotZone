import 'package:flutter/material.dart';
import 'package:nearmessageapp/services/auth/auth_gate.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const AuthGate();
  }
}