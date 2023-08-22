import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import 'dart:async';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();

  // route name
  static String routeName = '/signin';
}

class _SigninScreenState extends State<SigninScreen> {
  // global key for form
  final _formKey = GlobalKey<FormState>();
  // controller for email field
  final TextEditingController _emailController = TextEditingController();
  // controller for password field
  final TextEditingController _passwordController = TextEditingController();
  bool hidePassword = true;
  bool isLoading = false;
  bool isEmailError = false;
  bool isRequesting = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // dispose controllers
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Form(
          key: _formKey, // assign key to form
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                'Sign In',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
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
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    setState(() {
                      isEmailError = true;
                    });
                    return 'Please enter your email';
                  } else if (!value.contains('@')) {
                    setState(() {
                      isEmailError = true;
                    });
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _passwordController, // assign controller
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  prefixIcon: Icon(Icons.lock),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        hidePassword = !hidePassword;
                      });
                    },
                    icon: Icon(
                      hidePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
                obscureText: hidePassword,
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t remember your password?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: Text('Reset Password'),
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                    isRequesting = true;
                  });
                  if (_formKey.currentState!.validate() && isRequesting) {
                    // do something
                    print('Sign In');
                    UserCredential? user =
                        await AuthService().signInWithEmailAndPassword(
                      _emailController.text.trim(),
                      _passwordController.text.trim(),
                    );
                    if (user != null) {
                      Navigator.pushReplacementNamed(context, '/home');
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Email or password is incorrect'),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          closeIconColor: Colors.white,
                          backgroundColor: Colors.red,
                          showCloseIcon: true,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                  setState(() {
                    isLoading = false;
                    isRequesting = false;
                  });
                },
                child: isLoading
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : Text('Sign In'),
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Don\'t have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signup');
                    },
                    child: Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
