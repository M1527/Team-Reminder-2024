import 'package:abc/api/apis.dart';
import 'package:abc/main.dart';
import 'package:flutter/material.dart';

import '../../constants.dart';
import '../../dto/user_dto.dart';
import 'components/login_form.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final APIs api = APIs();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              Image.asset(
                "assets/images/banner.png",
                fit: BoxFit.cover,
              ),
              Padding(
                padding: const EdgeInsets.all(defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back!",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    const Text(
                      "Log in with your data that you intered during your registration.",
                    ),
                    const SizedBox(height: defaultPadding),
                    LogInForm(
                        formKey: _formKey,
                        emailController: _emailController,
                        passwordController: _passwordController),
                    Align(
                      child: TextButton(
                        child: const Text("Forgot password"),
                        onPressed: () {
                          Navigator.pushNamed(context, "/forgot");
                        },
                      ),
                    ),
                    const SizedBox(height: 30),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                setState(() {
                                  _isLoading = true;
                                });
                                UserDto? user = await api.signIn(
                                  _emailController.text,
                                  _passwordController.text,
                                );
                                setState(() {
                                  _isLoading = false;
                                });
                                if (user != null && user.role == 'admin') {
                                  Navigator.of(navigatorKey.currentContext!)
                                      .pushNamedAndRemoveUntil(
                                    "/admin",
                                    (Route<dynamic> route) => false,
                                  );
                                } else if (user != null) {
                                  Navigator.of(navigatorKey.currentContext!)
                                      .pushNamedAndRemoveUntil(
                                    "/home",
                                    (Route<dynamic> route) => false,
                                  );
                                }
                              }
                            },
                            child: const Text('Login'),
                          ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Don't have an account?"),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, "/signup");
                          },
                          child: const Text("Sign up"),
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
