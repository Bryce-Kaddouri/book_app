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
  Future<ListResult?> listAll() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    String folderName = 'users/${user.uid}/pages';
    try {
      // list all get download urls
      ListResult result = await _storage.ref(folderName).listAll();
      // loop through result
      return Future.value(result);
    } catch (e) {
      // print error
      print(e);
      // return null
      return null;
    }
  }

  Future<int> getNbFiles() async {
    ListResult? result = await listAll();
    int number = 0;
    if (result != null) {
      number = result.items.length;
    }
    print('number of files: $number');
    return number;
  }

  // method to get metadata for all files in a folder
  Future<List<FullMetadata>> getMetadata() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return [];
    }
    String folderName = 'users/${user.uid}/pages';
    try {
      // list all get download urls
      ListResult result = await _storage.ref(folderName).listAll();
      // loop through result
      List<FullMetadata> metadata = [];
      for (var ref in result.items) {
        FullMetadata data = await ref.getMetadata();
        metadata.add(data);
      }
      return Future.value(metadata);
    } catch (e) {
      // print error
      print(e);
      // return null
      return [];
    }
  }

  // put blob
  Future<void> uploadBlob(String path, Blob blob, List<String> keyWords) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }
    print('uploading blob');
    String folderName = 'users/${user.uid}/pages';
    int number = await getNbFiles(); // get the number of files in the folder
    // get the number of files in the folder

    try {
      // upload image

      // convert image to bytes
      UploadTask uploadTask;
      Reference ref =
          FirebaseStorage.instance.ref().child('$folderName/${number}.png');

      final metadata = SettableMetadata(
        customMetadata: {
          'keywords': keyWords.join(','),
        },
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
