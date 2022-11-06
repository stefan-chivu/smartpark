import 'package:easy_park/screens/home/home.dart';
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
  final _emailFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();
  final _confirmPasswordFormKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (_emailFormKey.currentState!.validate() &&
              _passwordFormKey.currentState!.validate() &&
              _confirmPasswordFormKey.currentState!.validate()) {
            String result = await _auth.registerWithEmailAndPassword(
                _emailController.text, _passwordController.text);
            if (!result.contains("succes")) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(result)));
            } else {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Home()));
            }
          }
        },
      ),
      body: Center(
          child: SingleChildScrollView(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Padding(
              padding: EdgeInsets.all(AppMargins.S),
              child: Text("Create Account")),
          SizedBox(height: AppMargins.L),
          Padding(
            padding: EdgeInsets.all(AppMargins.S),
            child: Form(
              key: _emailFormKey,
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
          ),
          Padding(
            padding: EdgeInsets.all(AppMargins.S),
            child: Form(
              key: _passwordFormKey,
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
          ),
          Padding(
            padding: EdgeInsets.all(AppMargins.S),
            child: Form(
              key: _confirmPasswordFormKey,
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
          ),
          Padding(
            padding: EdgeInsets.all(AppMargins.S),
            child: InkWell(
              //navigate to login
              onTap: () {
                Navigator.pop(context);
              },
              child: Text("Already have an account?",
                  style: TextStyle(
                      fontSize: AppFontSizes.M, color: AppColors.slateGray)),
            ),
          ),
        ]),
      )),
    );
  }
}
