import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'package:turn_page_transition/turn_page_transition.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();

  // route name
  static String routeName = '/home';
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // animation controller
  late AnimationController _animationController;
  GlobalKey<SfSignaturePadState> signaturePadKey = GlobalKey();

  int _currentIndex = 0;
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

  TurnPageController controller = TurnPageController();

  @override
  void initState() {
    // animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _page.insert(
      _page.length,
      Container(
        height: double.infinity,
        width: double.infinity,
        child: SfSignaturePad(
          key: signaturePadKey,
          minimumStrokeWidth: 1,
          maximumStrokeWidth: 3,
          strokeColor: Colors.black,
          backgroundColor: Colors.white,
        ),
      ),
    );

    super.initState();
  }

  @override
  void dispose() {
    // dispose animation controller
    _animationController.dispose();

    super.dispose();
  }

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
                  Navigator.pushReplacementNamed(context, '/signin');
                });
              },
              icon: Icon(Icons.logout),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: TurnPageView.builder(
                controller: controller,
                itemCount: 5,
                itemBuilder: (context, index) => _page[index],
                overleafColorBuilder: (index) => colors[index],
                animationTransitionPoint: 0.5,
                useOnTap: false,
                useOnSwipe: false,
              ),
            ),
            Container(
              height: 50,
              color: Colors.grey,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // buton to clear signature
                  IconButton(
                    onPressed: () {
                      // clear signature
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Clear signature'),
                          content: Text('Are you sure you want to clear?'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                // clear signature
                                signaturePadKey.currentState!.clear();
                                Navigator.pop(context);
                              },
                              child: Text('Clear'),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: Icon(
                      Icons.delete_forever,
                      color: Colors.red,
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: 200,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            if (_currentIndex > 0) {
                              controller.previousPage();

                              setState(() {
                                _currentIndex--;
                              });
                            }
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color:
                                _currentIndex > 0 ? Colors.white : Colors.black,
                          ),
                        ),
                        RichText(
                          text: TextSpan(
                            text: '${_currentIndex + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                // global key for the form
                                final _formKey = GlobalKey<FormState>();
                                // controller for the text field
                                final _pageController = TextEditingController();
                                // show dialog to input page number
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text('Go to page'),
                                    content: Form(
                                      key: _formKey,
                                      child: TextFormField(
                                        controller: _pageController,
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter page number';
                                          } else if (int.parse(value) >
                                              _page.length) {
                                            return 'Page number must be less than 5';
                                          } else if (int.parse(value) < 1) {
                                            return 'Page number must be greater than 0';
                                          } else if (int.parse(value) ==
                                              _currentIndex + 1) {
                                            return 'You are already on this page';
                                          } else if (!RegExp(r'^[0-9]+$')
                                              .hasMatch(value)) {
                                            return 'Please enter a valid page number';
                                          }

                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: 'Page number',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            setState(() {
                                              _currentIndex = int.parse(
                                                      _pageController.text) -
                                                  1;
                                              controller.animateToPage(
                                                _currentIndex,
                                              );
                                              Navigator.pop(context);
                                            });
                                          }
                                        },
                                        child: Text('Go'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            children: [
                              TextSpan(
                                text: '/5',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          enableFeedback: _currentIndex < _page.length - 1,
                          onPressed: () {
                            if (_currentIndex < _page.length - 1) {
                              controller.nextPage();

                              setState(() {
                                _currentIndex++;
                              });
                            }
                          },
                          icon: Icon(
                            Icons.arrow_forward_ios,
                            color: _currentIndex < _page.length - 1
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // clear signature
                      signaturePadKey.currentState!.clear();
                    },
                    icon: Icon(Icons.clear),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
