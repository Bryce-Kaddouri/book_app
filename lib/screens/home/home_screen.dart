import 'dart:typed_data';

import 'package:book_app/services/storage_service.dart';
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

class _HomeScreenState extends State<HomeScreen> {
  List<Widget> pages = [];
  int _currentPage = 1;
  late PageController controller;
  GlobalKey<SfSignaturePadState> _signaturePadKey = GlobalKey();

  @override
  void initState() {
    print('initState');
    super.initState();
    StorageService().listAll().then((value) {
      for (int i = 0; i < value!.length; i++) {
        pages.add(
          Container(
            child: Image.network(
              'https://firebasestorage.googleapis.com/v0/b/my-digital-writting-book.appspot.com/users/jOLOb5O665OyWfu1WElIJvhFm1F3/pages/0.png?alt=media&token=https://firebasestorage.googleapis.com/v0/b/my-digital-writting-book.appspot.com/o/users%2FjOLOb5O665OyWfu1WElIJvhFm1F3%2Fpages%2F0.png?alt=media&token=19d6cb3e-be0b-4660-9915-d5d1ee27edd0',
              fit: BoxFit.cover,
            ),
            height: double.infinity,
            width: double.infinity,
          ),
        );
      }
    });
    for (int i = 0; i < 10; i++) {
      pages.add(
        Container(
          color: Colors.blue,
          child: Center(
            child: Text(
              'Page ${i + 1}',
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
    }

    pages.add(
      SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: SfSignaturePad(
          key: _signaturePadKey,
          backgroundColor: Colors.grey[200],
        ),
      ),
    );

    controller = PageController(initialPage: pages.length - 1);

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
        // app bar
        appBar: AppBar(
          title: const Text('Home Screen'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () async {
                // sign out
                await AuthService().signOut().then((value) {
                  Navigator.pushReplacementNamed(context, '/signin');
                });
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: PageView(
          physics: NeverScrollableScrollPhysics(),
          controller: controller,
          children: pages,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index + 1;
            });
          },
        ),

        persistentFooterAlignment: AlignmentDirectional.center,
        persistentFooterButtons: [
          IconButton(
            onPressed: () {
              // save signature
            },
            icon: Icon(Icons.delete_forever_sharp, color: Colors.red),
          ),
          SizedBox(
            width: 40,
          ),
          Container(
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
                    text: '$_currentPage of ${pages.length}',
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
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a page number';
                                  } else if (int.tryParse(value) == null) {
                                    return 'Please enter a valid page number';
                                  } else if (int.parse(value) > 10 ||
                                      int.parse(value) < 1) {
                                    return 'Please enter a number between 1 and 10';
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
                                        int.parse(_numberController.text) - 1,
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
                    if (controller.page!.toInt() < pages.length - 1) {
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
          ),
          SizedBox(
            width: 40,
          ),
          IconButton(
            onPressed: () async {
              print('save signature');
              // get signature
              /* ui.Image? image =
                  await _signaturePadKey.currentState!.toImage(pixelRatio: 3.0);

              // upload signature
              await StorageService().uploadSignature(image).then((value) {
                print('Signature uploaded');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Signature uploaded'),
                  ),
                );
              });*/

              final canvas = html.CanvasElement(width: 500, height: 500);
              final context = canvas.context2D;

              //Get the signature in the canvas context.
              _signaturePadKey.currentState!.renderToContext2D(context);

              //Get the image from the canvas context
              final blob = await canvas.toBlob('image/jpeg', 1.0);
              print(blob);

              StorageService().uploadBlob('image.png', blob).then((value) {
                print('Signature uploaded');
              });
            },
            icon: Icon(Icons.add_circle_outline, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
