import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

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

  // method to upload file with a progress indicator in a dialog
  Future<String?> uploadFileWithProgressIndicator(
      File file, Function(double) onProgress) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return null;
    }
    String folderName = 'users/${user.uid}/pages';

    // get the number of files in the folder
    ListResult? result = await listAll();
    int fileCount = result!.items.length;

    String fileName = 'page${fileCount + 1}.jpg';

    try {
      // upload file
      UploadTask uploadTask = _storage
          .ref('$folderName/$fileName')
          .putFile(file, SettableMetadata(contentType: 'image/jpeg'));

      // listen to the progress
      uploadTask.snapshotEvents.listen((event) {
        // get the progress
        double progress = event.bytesTransferred / event.totalBytes;
        // call the onProgress function
        onProgress(progress);
      });

      // wait for the upload to complete
      await uploadTask;
      // get the download url
      String downloadURL =
          await _storage.ref('$folderName/$fileName').getDownloadURL();
      // return download url
      return downloadURL;
    } catch (e) {
      // print error
      print(e);
      // return null
      return null;
    }
  }
}
