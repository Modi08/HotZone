import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:nearmessageapp/components/button.dart';
import 'package:nearmessageapp/components/text_field.dart';
import 'package:http/http.dart' as http;
import 'package:nearmessageapp/services/auth/auth_gate.dart';
import 'package:nearmessageapp/services/storage/userStore.dart';
import 'package:nearmessageapp/services/general/snackbar.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage(
      {super.key,
      required this.onTap,
      required this.screenSize,
      required this.userDatabase});
  final void Function()? onTap;
  final Size screenSize;
  final DatabaseServiceUser userDatabase;

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
        User userData = User(
          id: jsonDecode(response.body)['userId'],
          email: jsonDecode(response.body)['email'],
          username: jsonDecode(response.body)['username'],
          profilePic: jsonDecode(response.body)["profilePic"],
          connectionId: "",
          isPrimary: true,
        );
        
        widget.userDatabase.clearAll();
        widget.userDatabase.insert(userData);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => AuthGate(userDatabase: widget.userDatabase)));
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
              SizedBox(height: widget.screenSize.height * 0.06),
              Icon(
                Icons.message,
                size: widget.screenSize.height * 0.095,
                color: Colors.grey[800],
              ),
              SizedBox(height: widget.screenSize.height * 0.06),
              const Text(
                "Let's create your account",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: widget.screenSize.height * 0.03),
              MyTextField(controller: usernameController, hintText: "Username"),
              SizedBox(height: widget.screenSize.height * 0.012),
              MyTextField(controller: emailController, hintText: "Email"),
              SizedBox(height: widget.screenSize.height * 0.012),
              MyTextField(
                  controller: pwdController,
                  hintText: "Password",
                  obscureText: true),
              SizedBox(height: widget.screenSize.height * 0.012),
              MyTextField(
                  controller: confirmPwdController,
                  hintText: "Confirm Password",
                  obscureText: true),
              SizedBox(
                height: widget.screenSize.height * 0.03,
              ),
              CButton(onTap: signUp, text: "Sign up"),
              SizedBox(
                height: widget.screenSize.height * 0.06,
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
