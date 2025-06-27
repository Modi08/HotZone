import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nearmessageapp/components/button.dart';
import 'package:nearmessageapp/components/text_field.dart';
import 'package:http/http.dart' as http;
import 'package:nearmessageapp/services/auth/auth_gate.dart';
import 'package:nearmessageapp/services/storage/userStore.dart';
import 'package:nearmessageapp/services/general/snackbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage(
      {super.key,
      required this.onTap,
      required this.screenSize,
      required this.userDatabase});
  final void Function()? onTap;
  final Size screenSize;
  final DatabaseServiceUser userDatabase;

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
      showSnackbar(context, jsonDecode(response.body)['msg'],
          response.statusCode == 400);

      if (response.statusCode == 200) {
        User userData = User(
          id: jsonDecode(response.body)['userId'],
          email: jsonDecode(response.body)["userData"]['email'],
          username: jsonDecode(response.body)["userData"]['username'],
          profilePic: jsonDecode(response.body)["userData"]["profilePic"],
          connectionId: "",
          isPrimary: true,
          );
          widget.userDatabase.clearAll();
          widget.userDatabase.insert(userData);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => AuthGate(userDatabase: widget.userDatabase)));
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
              SizedBox(height: widget.screenSize.height * 0.06),
              Icon(
                Icons.message,
                size: widget.screenSize.height * 0.095,
                color: Colors.grey[800],
              ),
              SizedBox(height: widget.screenSize.height * 0.06),
              const Text(
                "Welcome back. You' ve been missed!",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: widget.screenSize.height * 0.03),
              MyTextField(controller: emailController, hintText: "Email"),
              SizedBox(height: widget.screenSize.height * 0.0119),
              MyTextField(
                  controller: pwdController,
                  hintText: "Password",
                  obscureText: true),
              SizedBox(
                height: widget.screenSize.height * 0.03,
              ),
              CButton(onTap: login, text: "Login"),
              SizedBox(
                height: widget.screenSize.height * 0.06,
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
