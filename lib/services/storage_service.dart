import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
// import XFile
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'dart:io';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // method to list all files in a folder
  Future<ListResult?> listAll() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    String folderName = 'users/${user.uid}/pages';
    try {
      // list all files in a folder
      ListResult result = await _storage.ref(folderName).listAll();
      print(result);
      // return result
      return result;
    } catch (e) {
      // print error
      print(e);
      // return null
      return null;
    }
  }

  Future<UploadTask> uploadFile(XFile? file) async {
    if (file == null) {
      /* ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No file was selected'),
        ),
      );*/
      throw Exception('No file was selected');
    }

    UploadTask uploadTask;

    // Create a Reference to the file
    Reference ref = FirebaseStorage.instance
        .ref()
        .child('flutter-tests')
        .child('/some-image.jpg');

    final metadata = SettableMetadata(
      contentType: 'image/jpeg',
      customMetadata: {'picked-file-path': file.path},
    );

    if (kIsWeb) {
      uploadTask = ref.putData(await file.readAsBytes(), metadata);
    } else {
      uploadTask = ref.putFile(File(file.path), metadata);
    }

    return Future.value(uploadTask);
  }
}
