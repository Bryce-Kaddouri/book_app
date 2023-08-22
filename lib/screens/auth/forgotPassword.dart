import 'package:book_app/screens/auth/signin.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();

  // route name
  static String routeName = '/forgotPassword';
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // global key for form
  final _formKey = GlobalKey<FormState>();
  // controller for email field
  final TextEditingController _emailController = TextEditingController();
  bool isEmailError = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: ListView(
          padding: EdgeInsets.symmetric(horizontal: 20),
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              'Forgot Password',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 20,
            ),
            Form(
              key: _formKey, // assign key to form
              child: TextFormField(
                controller: _emailController, // assign controller
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.email,
                    color: isEmailError ? Colors.red : null,
                  ),
                  labelText: 'Email',
                  hintText: 'Enter your email',
                  suffixIcon: isEmailError
                      ? Icon(
                          Icons.error,
                          color: Colors.red,
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    setState(() {
                      isEmailError = true;
                    });
                    return 'Please enter your email';
                  } else {
                    setState(() {
                      isEmailError = false;
                    });
                    return null;
                  }
                },
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  // validate form
                  setState(() {
                    isLoading = true;
                  });
                  // send password reset email
                  AuthService()
                      .sendPasswordResetEmail(_emailController.text.trim())
                      .then((value) {
                    // show snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Password reset email has been sent to ${_emailController.text}'),
                      ),
                    );
                    // navigate to signin screen
                    Navigator.pushReplacementNamed(
                        context, SigninScreen.routeName);
                  }).catchError((error) {
                    // show snackbar
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error.toString()),
                      ),
                    );
                  }).whenComplete(() {
                    setState(() {
                      isLoading = false;
                    });
                  });
                }
              },
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                      ),
                    )
                  : Text('Send Email'),
            ),
          ],
        ),
      ),
    );
  }
}
