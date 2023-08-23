import 'dart:js_interop';
import 'dart:typed_data';

import 'package:book_app/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import '../../services/auth_service.dart';
import 'dart:ui' as ui;
import 'dart:async';
// import gesture detector
import 'package:flutter/gestures.dart';
import 'dart:html' as html;

class HomeScreen extends StatefulWidget {
  HomeScreen({super.key});

  // route name
  static String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  // animation controller
  late AnimationController _controller;
  int _currentPage = 1;
  late PageController controller;
  GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();
  bool showSearchBar = false;
  SearchController searchController = SearchController();

  @override
  void initState() {
    print('initState');
    super.initState();
    // Create an animation controller
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 3),
      lowerBound: 0,
      upperBound: 3,
    );

    controller = PageController(initialPage: 0);

    // Listen for changes in the controller's currentIndex
  }

  @override
  void dispose() {
    print('dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        drawer: Drawer(
          child: ListView(
            children: [
              DrawerHeader(
                child: Stack(
                  children: [
                    // book icon with shadow
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        alignment: Alignment.center,
                        child: Text(
                          'Your Own Book',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    Container(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.chrome_reader_mode_outlined,
                        size: 150,
                        color: Colors.black87,
                      ),
                    ),

                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Positioned(
                          // <1 : 32, <2 : 48, <3 : 54
                          top: _controller.value < 1
                              ? 32
                              : _controller.value < 2
                                  ? 48
                                  : _controller.value < 3
                                      ? 64
                                      : 32,
                          // move from 54 to 130 if value is between 0 and 1 or between 1 and 2 or between 2 and 3
                          left: _controller.value % 1 * 76 + 54,
                          right: 0,
                          child: Icon(
                            Icons.edit,
                            size: 40,
                            color: Colors.blue,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Sign out'),
                onTap: () async {
                  await AuthService().signOut().then((value) {
                    Navigator.pushReplacementNamed(context, '/signin');
                  });
                },
              ),
            ],
          ),
        ),
        // app bar
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
                _controller.repeat(reverse: false);
              },
              icon: Icon(Icons.menu),
            ),
          ),
          title: Container(
            height: 46,
            child: SearchAnchor.bar(
              barBackgroundColor: MaterialStateProperty.all(Colors.blueGrey),

              barElevation: MaterialStateProperty.all(1),
              barShape: MaterialStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              barOverlayColor: MaterialStateProperty.all(Colors.blueGrey),
              barPadding: MaterialStateProperty.all(EdgeInsets.all(2)),
              barSide: MaterialStateProperty.all(BorderSide.none),
              viewSide: BorderSide.none,
              suggestionsBuilder: (context, query) {
                print('query: $query');
                return [
                  ListTile(
                    title: Text('test'),
                  ),
                  ListTile(
                    title: Text('test'),
                  ),
                  ListTile(
                    title: Text('test'),
                  ),
                ];
              },
              searchController: searchController,
              // suggestions: [
              //   ListTile(
              //     title: Text('test'),
              //   ),
              //   ListTile(
              //     title: Text('test'),
              //   ),
              //   ListTile(
              //     title: Text('test'),
              //   ),
              // ],
            ),
          ),
          automaticallyImplyLeading: false,
        ),
        body: StreamBuilder(
            stream: StorageService().listAll().asStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                ListResult? lst = snapshot.data as ListResult?;
                print(lst!.items.length);

                return PageView(
                  physics: NeverScrollableScrollPhysics(),
                  controller: controller,
                  children: [
                    Container(
                      child: SfSignaturePad(
                        key: _signaturePadKey,
                        backgroundColor: Colors.grey[200],
                        strokeColor: Colors.black,
                        minimumStrokeWidth: 1,
                        maximumStrokeWidth: 4,
                      ),
                    ),
                    ...lst.items.map((e) {
                      return FutureBuilder(
                        future: e.getDownloadURL(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Image.network(snapshot.data as String);
                          } else {
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }
                        },
                      );
                    }).toList(),
                  ],
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index + 1;
                    });
                  },
                );
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            }),

        persistentFooterAlignment: AlignmentDirectional.center,
        persistentFooterButtons: [
          IconButton(
            onPressed: () {
              // clear signature
              _signaturePadKey.currentState!.clear();
            },
            icon: Icon(Icons.delete_forever_sharp, color: Colors.red),
          ),
          SizedBox(
            width: 40,
          ),
          FutureBuilder(
              future: StorageService().getNbFiles(),
              builder: (context, snapshot) {
                int number = 0;
                if (snapshot.hasData) {
                  number = snapshot.data as int;
                }
                print('number of files: $number');
                return Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (controller.page!.toInt() > 0) {
                            controller.previousPage(
                              duration: Duration(seconds: 1),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('This is the first page'),
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.arrow_back_ios, color: Colors.blue),
                      ),
                      RichText(
                        text: TextSpan(
                          // check if controller is initialized before using controller.currentIndex
                          text: '$_currentPage of ${number + 1}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 20,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // global key for the form
                              final _formKey = GlobalKey<FormState>();
                              // controller for number field
                              final TextEditingController _numberController =
                                  TextEditingController();

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Go to page'),
                                  content: Form(
                                    key: _formKey,
                                    child: TextFormField(
                                      controller: _numberController,
                                      decoration: InputDecoration(
                                        labelText: 'Page number',
                                        hintText: 'Enter page number',
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter a page number';
                                        } else if (int.tryParse(value) ==
                                            null) {
                                          return 'Please enter a valid page number';
                                        } else if (int.parse(value) >
                                                number + 1 ||
                                            int.parse(value) < 1) {
                                          return 'Please enter a number between 1 and ${number + 1}';
                                        } else {
                                          return null;
                                        }
                                      },
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
                                        Navigator.pop(context);
                                        if (_formKey.currentState!.validate()) {
                                          print(_numberController.text);
                                          controller.animateToPage(
                                              int.parse(
                                                      _numberController.text) -
                                                  1,
                                              duration: Duration(seconds: 1),
                                              curve: Curves.easeInOut);
                                        }
                                      },
                                      child: Text('Go'),
                                    ),
                                  ],
                                ),
                              );
                            },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (controller.page!.toInt() < number) {
                            print(controller.page!.toInt());
                            controller.nextPage(
                                duration: Duration(seconds: 1),
                                curve: Curves.easeInOut);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('This is the last page'),
                              ),
                            );
                          }
                        },
                        icon: Icon(Icons.arrow_forward_ios, color: Colors.blue),
                      ),
                    ],
                  ),
                );
              }),
          SizedBox(
            width: 40,
          ),
          IconButton(
            onPressed: () async {
              print('save signature');
              // check if the signature pad is empty

              // get width and height of _signaturePadKey
              final width = _signaturePadKey.currentContext!.size!.width;
              final height = _signaturePadKey.currentContext!.size!.height;

              final canvas = html.CanvasElement(
                  width: width.toInt(), height: height.toInt());
              final contextt = canvas.context2D;

              //Get the signature in the canvas context.
              _signaturePadKey.currentState!.renderToContext2D(contextt);

              //Get the image from the canvas context
              final blob = await canvas.toBlob('image/jpeg', 1.0);
              print(blob);

              await StorageService().uploadBlob('image.png', blob).whenComplete(
                    () => ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Signature saved'),
                      ),
                    ),
                  );
              _signaturePadKey.currentState!.clear();
              setState(() {});
            },
            icon: Icon(Icons.add_circle_outline, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
