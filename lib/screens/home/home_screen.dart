import 'dart:js_interop';
import 'dart:typed_data';

import 'package:book_app/services/extract_text_service.dart';
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
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  void _addNewKeywordField() {
    setState(() {});
  }

  @override
  void initState() {
    print('initState');
    super.initState();
    _nameController = TextEditingController();

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
    _nameController.dispose();
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
            child: FutureBuilder(
              future: StorageService().getMetadata(),
              builder: (context, snapshot) {
                List<Widget> lstWidget = [];

                if (snapshot.hasData) {
                  List<FullMetadata> lst = snapshot.data as List<FullMetadata>;

                  return SearchAnchor.bar(
                    barBackgroundColor:
                        MaterialStateProperty.all(Colors.blueGrey),
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
                      if (query.text.isNotEmpty) {
                        lstWidget = lst
                            .where((element) =>
                                element.name
                                    .toLowerCase()
                                    .contains(query.text.toLowerCase()) ||
                                element.customMetadata!['keywords']!
                                    .toLowerCase()
                                    .contains(query.text.toLowerCase()))
                            .map((e) {
                          return ListTile(
                            title: Text(e.customMetadata!['keywords']!),
                            trailing: Text(e.customMetadata!['page']!),
                            onTap: () {
                              Navigator.pop(context);
                              controller.animateToPage(lst.indexOf(e) + 1,
                                  duration: Duration(seconds: 1),
                                  curve: Curves.easeInOut);
                            },
                          );
                        }).toList();
                        // check if there are no results
                        if (lstWidget.isEmpty) {
                          return [
                            ListTile(
                              title: Text('No results found'),
                            ),
                          ];
                        }
                        return lstWidget;
                      } else {
                        lstWidget = lst.map((e) {
                          return ListTile(
                            title: Text(e.customMetadata!['keywords']!),
                            trailing: Text(e.customMetadata!['page']!),
                            onTap: () {
                              Navigator.pop(context);
                              controller.animateToPage(lst.indexOf(e) + 1,
                                  duration: Duration(seconds: 1),
                                  curve: Curves.easeInOut);
                            },
                          );
                        }).toList();
                        return lstWidget;
                      }
                    },
                    searchController: searchController,
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  );
                }
              },
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
          },
        ),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DynamicTextfieldsApp(
                    signaturePadKey: _signaturePadKey,
                  ),
                ),
              );
            },
            icon: Icon(Icons.add_circle_outline, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}

class DynamicTextfieldsApp extends StatefulWidget {
  GlobalKey<SfSignaturePadState> signaturePadKey;

  DynamicTextfieldsApp({super.key, required this.signaturePadKey});

  @override
  State createState() => _DynamicTextfieldsAppState();
}

class _DynamicTextfieldsAppState extends State<DynamicTextfieldsApp> {
  // global key for the form
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<String> keyWordsList = [''];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        automaticallyImplyLeading: true,
        title: Text('Add keywords'),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: keyWordsList.length,
                padding: const EdgeInsets.all(20),
                itemBuilder: (context, index) => Row(
                  children: [
                    Expanded(
                      child: DynamicTextfield(
                        key: UniqueKey(),
                        initialValue: keyWordsList[index],
                        onChanged: (v) => keyWordsList[index] = v,
                      ),
                    ),
                    const SizedBox(width: 20),
                    _textfieldBtn(index),
                  ],
                ),
                separatorBuilder: (context, index) => const SizedBox(
                  height: 20,
                ),
              ),
            ),
            // submit button
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: Size(double.infinity, 50),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      keyWordsList.isNotEmpty) {
                    print(keyWordsList);

                    final width =
                        widget.signaturePadKey.currentContext!.size!.width;
                    final height =
                        widget.signaturePadKey.currentContext!.size!.height;

                    final canvas = html.CanvasElement(
                        width: width.toInt(), height: height.toInt());
                    final contextt = canvas.context2D;

                    //Get the signature in the canvas context.
                    widget.signaturePadKey.currentState!
                        .renderToContext2D(contextt);

                    //Get the image from the canvas context
                    final blob = await canvas.toBlob('image/jpeg', 1.0);
                    print(blob);

                    await StorageService()
                        .uploadBlob('image.png', blob, keyWordsList)
                        .whenComplete(() {
                      Navigator.pushReplacementNamed(
                          context, HomeScreen.routeName);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          closeIconColor: Colors.white,
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          showCloseIcon: true,
                          duration: Duration(seconds: 2),
                          content: Text('New page added successfully !'),
                        ),
                      );
                    });

                    widget.signaturePadKey.currentState!.clear();

                    // call the callback function
                    // widget function
                    // widget.uploadImage();
                  }
                },
                child: const Text('Submit'),
              ),
            )
          ],
        ),
      ),
    );
  }

  /// last textfield will have an add button, tapping which will add a new textfield below
  /// and all other textfields will have a remove button, tapping which will remove the textfield at the index
  Widget _textfieldBtn(int index) {
    bool isLast = index == keyWordsList.length - 1;

    return IconButton(
      onPressed: () => setState(
        () => isLast ? keyWordsList.add('') : keyWordsList.removeAt(index),
      ),
      icon: Icon(
        isLast ? Icons.add_circle : Icons.remove_circle,
        color: isLast ? Colors.green : Colors.red,
      ),
    );
  }
}

class DynamicTextfield extends StatefulWidget {
  final String initialValue;
  final void Function(String) onChanged;

  const DynamicTextfield({
    super.key,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State createState() => _DynamicTextfieldState();
}

class _DynamicTextfieldState extends State<DynamicTextfield> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.text = widget.initialValue ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: const InputDecoration(hintText: "Enter a keyword"),
      validator: (v) {
        if (v == null || v.trim().isEmpty) {
          return 'Please enter something';
        } else if (RegExp(r'[!@#<>?":_`~;[\]\\|=+)(*&^%-]').hasMatch(v)) {
          return 'Please enter a valid keyword without special characters';
        } else if (v.contains(' ') || v.contains('\n')) {
          return 'Please enter a valid keyword without spaces or new lines';
        }
        return null;
      },
    );
  }
}
