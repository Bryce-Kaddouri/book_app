import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();

  // route name
  static String routeName = '/signup';
}

class _SignupScreenState extends State<SignupScreen> {
  // global key for form
  final _formKey = GlobalKey<FormState>();
  // controller for email field
  final TextEditingController _emailController = TextEditingController();
  // controller for password field
  final TextEditingController _passwordController = TextEditingController();
  // controller for confirm password field
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  // controller for first name field
  final TextEditingController _firstNameController = TextEditingController();
  // controller for last name field
  final TextEditingController _lastNameController = TextEditingController();
  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool isLoading = false;

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
                'Sign Up',
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
                controller: _firstNameController, //
                // assign controller
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: 'First Name',
                  hintText: 'Enter your first name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your first name';
                  } else if (value.length < 3) {
                    return 'First name must be at least 3 characters';
                  } else if (value.length > 20) {
                    return 'First name must be less than 20 characters';
                  } else if (value.contains(' ')) {
                    return 'First name must not contain space';
                  } else if (value.contains(RegExp(r'[0-9]'))) {
                    return 'First name must not contain number';
                  } else if (value
                      .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                    return 'First name must not contain special characters';
                  }

                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _lastNameController, // assign controller
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  labelText: 'Last Name',
                  hintText: 'Enter your last name',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your last name';
                  } else if (value.length < 3) {
                    return 'Last name must be at least 3 characters';
                  } else if (value.length > 20) {
                    return 'Last name must be less than 20 characters';
                  } else if (value.contains(' ')) {
                    return 'Last name must not contain space';
                  } else if (value.contains(RegExp(r'[0-9]'))) {
                    return 'Last name must not contain number';
                  } else if (value
                      .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                    return 'Last name must not contain special characters';
                  }

                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _emailController, // assign controller
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  labelText: 'Email',
                  hintText: 'Enter your email',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  } else if (!value.contains('@')) {
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
                obscureText: hidePassword, //
                // hide text
                decoration: InputDecoration(
                  labelText: 'Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  } else if (!value.contains(RegExp(r'[0-9]'))) {
                    return 'Password must contain number';
                  } else if (!value
                      .contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
                    return 'Password must contain special characters';
                  } else if (!value.contains(RegExp(r'[A-Z]'))) {
                    return 'Password must contain uppercase letter';
                  } else if (!value.contains(RegExp(r'[a-z]'))) {
                    return 'Password must contain lowercase letter';
                  }

                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: _confirmPasswordController, // assign controller
                obscureText: hideConfirmPassword, // hide text
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock),
                  labelText: 'Confirm Password',
                  hintText: 'Enter your password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        hideConfirmPassword = !hideConfirmPassword;
                      });
                    },
                    icon: Icon(
                      hideConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  } else if (value != _passwordController.text) {
                    return 'Password does not match';
                  }

                  return null;
                },
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  if (_formKey.currentState!.validate()) {
                    await AuthService().signUpWithEmailAndPassword(
                      _emailController.text,
                      _passwordController.text,
                      _firstNameController.text,
                      _lastNameController.text,
                    );
                    Navigator.pushNamed(context, '/check-email');

                    // do something
                  }
                  setState(() {
                    isLoading = false;
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
                    : Text('Sign Up'),
              ),
              SizedBox(
                height: 60,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/signin');
                    },
                    child: Text('Sign In'),
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
