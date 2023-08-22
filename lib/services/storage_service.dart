import 'dart:html';
import 'dart:ui' as ui;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
// import XFile
import 'dart:async';
import 'package:image_picker/image_picker.dart';

import 'dart:async';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // method to list all files in a folder
  Future<List<String>?> listAll() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    List<String> files = [];
    String folderName = 'users/${user.uid}/pages';
    try {
      // list all files in a folder
      ListResult result = await _storage.ref(folderName).listAll();
      print(result);
      // return result
      result.items.forEach((Reference ref) {
        /*files.add(ref.fullPath);*/
        // get download url
        ref.getDownloadURL().then((value) {
          files.add(value);
          print(value);
        });
      });
      print(files);
      return files;
    } catch (e) {
      // print error
      print(e);
      // return null
      return null;
    }
  }

  // put blob
  Future<void> uploadBlob(String path, Blob blob) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    print('uploading blob');
    String folderName = 'users/${user.uid}/pages';
    // get the number of files in the folder
    List? lst = await listAll();
    int number = lst?.length ?? 0;

    try {
      // upload image

      // convert image to bytes
      UploadTask uploadTask;
      Reference ref =
          FirebaseStorage.instance.ref().child('$folderName/${number}.png');
      final metadata = SettableMetadata(
        contentType: 'image/png',
      );

      uploadTask = ref.putBlob(blob, metadata);

      return Future.value(uploadTask);
    } catch (e) {
      // print error
      print(e);
    }
  }
}
