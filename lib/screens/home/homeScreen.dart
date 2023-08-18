import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  // route name
  static String routeName = '/home';
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // app bar
        appBar: AppBar(
          title: Text('Home Screen'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () {
                // sign out
                AuthService().signOut();
                setState(() {
                  Navigator.pushNamed(context, '/signin');
                });
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        body: Center(
          child: Text('Home Screen'),
        ),
      ),
    );
  }
}
