import 'package:easy_park/ui_components/custom_button.dart';
import 'package:easy_park/ui_components/custom_textfield.dart';
import 'package:flutter/material.dart';

import '../../services/auth.dart';
import '../../ui_components/ui_specs.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthService _auth = AuthService();
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
          child: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Image.asset(
            "assets/images/logo.png",
            width: 500,
          ),
          Padding(
            padding: const EdgeInsets.all(AppMargins.S),
            child: Form(
              key: _emailFormKey,
              child: CustomTextField(
                label: "E-mail",
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return "An e-mail address is required";
                  }
                  // Check if the entered email has the right format
                  if (!RegExp(r'\S+@\S+\.\S+').hasMatch(val)) {
                    return "Please enter a valid e-mail address";
                  }
                  // Return null if the entered email is valid
                  return null;
                },
                controller: _emailController,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppMargins.S),
            child: Form(
              key: _passwordFormKey,
              child: CustomTextField(
                label: "Password",
                isPassword: true,
                validator: (val) {
                  if (val!.trim().isEmpty) {
                    return "Please enter your password";
                  }
                  return null;
                },
                controller: _passwordController,
              ),
            ),
          ),
          Padding(
              padding: const EdgeInsets.all(AppMargins.M),
              child: CustomButton(
                  onPressed: () async {
                    if (_emailFormKey.currentState!.validate() &&
                        _passwordFormKey.currentState!.validate()) {
                      String result = await _auth.signInWithEmailAndPassword(
                          _emailController.text, _passwordController.text);
                      if (mounted) {
                        if (!result.contains("success")) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(result)));
                        } else {
                          Navigator.pushNamed(context, '/');
                        }
                      }
                    }
                  },
                  text: "Sign-in")),
          Padding(
            padding: const EdgeInsets.all(AppMargins.S),
            child: InkWell(
              //navigate to register
              onTap: () {
                Navigator.pushNamed(context, '/register');
              },
              child: const Text("Don't have an account? Sign-up",
                  style: TextStyle(
                      fontSize: AppFontSizes.M, color: AppColors.slateGray)),
            ),
          ),
        ]),
      )),
    );
  }
}
