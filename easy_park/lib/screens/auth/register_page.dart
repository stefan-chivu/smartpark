import 'package:easy_park/ui_components/custom_button.dart';
import 'package:flutter/material.dart';
import '../../services/auth.dart';
import '../../ui_components/custom_textfield.dart';
import '../../ui_components/ui_specs.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _auth = AuthService();
  final _registerFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  double widthRatio = 1.3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _registerFormKey,
            child: Column(children: [
              const Padding(padding: EdgeInsets.all(AppMargins.XL)),
              SizedBox(
                width: MediaQuery.of(context).size.width / widthRatio,
                child: Image.asset(
                  "assets/images/logo.png",
                  width: 500,
                ),
              ),
              const Padding(padding: EdgeInsets.all(AppMargins.S)),
              SizedBox(
                width: MediaQuery.of(context).size.width / widthRatio,
                child: CustomTextField(
                  label: "E-mail",
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return "Please enter a valid e-mail address";
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
              const Padding(padding: EdgeInsets.all(AppMargins.XS)),
              SizedBox(
                width: MediaQuery.of(context).size.width / widthRatio,
                child: CustomTextField(
                  label: "Password",
                  isPassword: true,
                  validator: (val) {
                    if (val!.trim().isEmpty) {
                      return "Please enter a valid password";
                    }
                    return null;
                  },
                  controller: _passwordController,
                ),
              ),
              const Padding(padding: EdgeInsets.all(AppMargins.XS)),
              SizedBox(
                width: MediaQuery.of(context).size.width / widthRatio,
                child: CustomTextField(
                  label: "Confirm password",
                  isPassword: true,
                  validator: (val) {
                    if (val!.trim() != _passwordController.text) {
                      return "The passwords do not match";
                    }
                    return null;
                  },
                  controller: _confirmPasswordController,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(AppMargins.M),
                child: CustomButton(
                    text: "Create account",
                    onPressed: () async {
                      if (_registerFormKey.currentState!.validate()) {
                        String result =
                            await _auth.registerWithEmailAndPassword(
                                _emailController.text,
                                _passwordController.text);
                        if (mounted) {
                          if (!result.contains("success")) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(result)));
                          } else {
                            Navigator.pushNamed(context, '/');
                          }
                        }
                      }
                    }),
              ),
              Padding(
                padding: const EdgeInsets.all(AppMargins.S),
                child: InkWell(
                  //navigate to login
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Already have an account?",
                      style: TextStyle(
                          fontSize: AppFontSizes.M,
                          color: AppColors.slateGray)),
                ),
              ),
              const SizedBox(
                height: AppMargins.L,
              )
            ]),
          ),
        ),
      ),
    );
  }
}
