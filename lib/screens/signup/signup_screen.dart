import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../api/apis.dart';
import '../../dto/user_dto.dart';
import '../../main.dart';
import 'components/sign_up_form.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final APIs api = APIs();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                "assets/images/banner.png",
                height: 400,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Let’s get started!",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    const Text(
                      "Please enter your valid data in order to create an account.",
                    ),
                    const SizedBox(height: defaultPadding),
                    SignUpForm(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        usernameController: _usernameController),
                    const SizedBox(height: defaultPadding),
                    Row(
                      children: [
                        Checkbox(
                          onChanged: (value) {},
                          value: true,
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: "I agree with the",
                              children: [
                                TextSpan(
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {},
                                  text: " Terms of service ",
                                  style: const TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const TextSpan(
                                  text: "& privacy policy.",
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: defaultPadding * 2),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save(); // Save the form
                                setState(() {
                                  _isLoading = true;
                                });
                                User? user = await api.signUp(UserDto(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                    username: _usernameController.text));
                                setState(() {
                                  _isLoading = false;
                                });
                                if (user != null) {
                                  Navigator.of(navigatorKey.currentContext!)
                                      .pushNamedAndRemoveUntil(
                                    "/home",
                                    (Route<dynamic> route) => false,
                                  );
                                }
                              }
                            },
                            child: const Text("Continue"),
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Do you have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/login");
                          },
                          child: const Text("Log in"),
                        )
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
