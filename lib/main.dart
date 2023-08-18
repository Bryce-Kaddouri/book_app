import 'package:book_app/screens/auth/checkEmail.dart';
import 'package:book_app/screens/auth/signin.dart';
import 'package:book_app/screens/auth/signup.dart';
import 'package:book_app/screens/home/homeScreen.dart';
import 'package:book_app/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:turn_page_transition/turn_page_transition.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TurnPageTransition Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        inputDecorationTheme: InputDecorationTheme(
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.red,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.red,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.blue,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.blue,
          textTheme: ButtonTextTheme.primary,
          height: 60,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      routes: {
        '/signin': (context) => SigninScreen(),
        '/signup': (context) => SignupScreen(),
        '/check-email': (context) => CheckEmailScreen(),
        '/home': (context) => HomeScreen(),
      },
      home: StreamBuilder(
        stream: AuthService().userChanges,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            default:
              if (snapshot.hasError) {
                return Scaffold(
                  body: Center(
                    child: Text('Error: ${snapshot.error}'),
                  ),
                );
              } else if (snapshot.hasData) {
                return StreamBuilder(
                  stream: AuthService().emailVerified,
                  builder: (context, snapshot1) {
                    switch (snapshot1.connectionState) {
                      case ConnectionState.waiting:
                        return Scaffold(
                          body: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      default:
                        if (snapshot1.hasError) {
                          return Scaffold(
                            body: Center(
                              child: Text('Error: ${snapshot.error}'),
                            ),
                          );
                        } else if (snapshot1.data == true) {
                          return PageViewPage();
                        } else {
                          String email = snapshot.data!.email!;
                          return CheckEmailScreen();
                        }
                    }
                  },
                );
              } else {
                return SigninScreen();
              }
          }
        },
      ),
    );
  }
}

class PageViewPage extends StatelessWidget {
  PageViewPage({super.key});
  List _page = [
    Container(
      color: Colors.red,
    ),
    Container(
      color: Colors.green,
    ),
    Container(
      color: Colors.blue,
    ),
    Container(
      color: Colors.yellow,
    ),
    Container(
      color: Colors.orange,
    ),
  ];

  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.yellow,
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    final controller = TurnPageController();
    return Scaffold(
      body: TurnPageView.builder(
        controller: controller,
        itemCount: 5,
        itemBuilder: (context, index) => _page[index],
        overleafColorBuilder: (index) => colors[index],
        animationTransitionPoint: 0.5,
        useOnTap: false,
        useOnSwipe: true,
      ),
    );
  }
}
