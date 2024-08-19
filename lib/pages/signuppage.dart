import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nearmessageapp/components/button.dart';
import 'package:nearmessageapp/components/text_field.dart';
import 'package:http/http.dart' as http;
import 'package:nearmessageapp/services/auth/auth_gate.dart';
import 'package:nearmessageapp/services/general/localstorage.dart';
import 'package:nearmessageapp/services/general/snackbar.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final emailController = TextEditingController();
  final pwdController = TextEditingController();
  final confirmPwdController = TextEditingController();
  final usernameController = TextEditingController();

  void signUp() async {
    await dotenv.load();
    String? apiUrl = dotenv.env['BASE_URL'];

    if (pwdController.text != confirmPwdController.text) {
      showSnackbar(context, "Passwords don't match", true);
      return null;
    }

    var paramsApiUrl =
        "$apiUrl/SignupUser?email=${emailController.text}&pwd=${pwdController.text}&username=${usernameController.text}";

    var response = http.post(Uri.parse(paramsApiUrl));
    response.then((http.Response response) {
      showSnackbar(context, jsonDecode(response.body)['msg'],
          response.statusCode == 400);

      if (response.statusCode == 200) {
        saveDataToLocalStorage("userId", jsonDecode(response.body)['userId']);
        saveDataToLocalStorage("username", usernameController.text);

        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => const AuthGate()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
        child: Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
          child: SingleChildScrollView(
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
                "Let's create your account",
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 25),
              MyTextField(controller: usernameController, hintText: "Username"),
              const SizedBox(height: 10),
              MyTextField(controller: emailController, hintText: "Email"),
              const SizedBox(height: 10),
              MyTextField(
                  controller: pwdController,
                  hintText: "Password",
                  obscureText: true),
              const SizedBox(height: 10),
              MyTextField(
                  controller: confirmPwdController,
                  hintText: "Confirm Password",
                  obscureText: true),
              const SizedBox(
                height: 25,
              ),
              CButton(onTap: signUp, text: "Sign up"),
              const SizedBox(
                height: 50,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Already have an account?"),
                  const SizedBox(width: 4),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Login now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
            ]),
          ),
        ),
      )),
    ));
  }
}
