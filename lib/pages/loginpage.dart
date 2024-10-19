import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nearmessageapp/components/button.dart';
import 'package:nearmessageapp/components/text_field.dart';
import 'package:http/http.dart' as http;
import 'package:nearmessageapp/services/auth/auth_gate.dart';
import 'package:nearmessageapp/services/general/localstorage.dart';
import 'package:nearmessageapp/services/general/snackbar.dart';

class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  const LoginPage({super.key, required this.onTap});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final pwdController = TextEditingController();

  void login() async {
    await dotenv.load();
    String? apiUrl = dotenv.env['BASE_URL'];

    var paramsApiUrl =
        "$apiUrl/LoginUser?email=${emailController.text}&pwd=${pwdController.text}";

    var response = http.put(Uri.parse(paramsApiUrl));
    response.then((http.Response response) {
      print(response.body);
      showSnackbar(context, jsonDecode(response.body)['msg'],
          response.statusCode == 400);

      if (response.statusCode == 200) {
        saveDataToLocalStorage("userId", jsonDecode(response.body)['userId']);

        saveDataToLocalStorage(
            "username", jsonDecode(response.body)['username']);

        saveDataToLocalStorage(
            "profilePic", jsonDecode(response.body)["profilePic"]);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const AuthGate()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const SizedBox(height: 50),
              Icon(
                Icons.message,
                size: 80,
                color: Colors.grey[800],
              ),
              const SizedBox(height: 50),
              const Text(
                "Welcome back. You' ve been missed!",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 25),
              MyTextField(controller: emailController, hintText: "Email"),
              const SizedBox(height: 10),
              MyTextField(
                  controller: pwdController,
                  hintText: "Password",
                  obscureText: true),
              const SizedBox(
                height: 25,
              ),
              CButton(onTap: login, text: "Login"),
              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Register now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
