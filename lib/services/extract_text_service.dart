import 'dart:async';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_tesseract_ocr/flutter_tesseract_ocr.dart';
import 'dart:io';
import 'package:flutter/foundation.dart'; // import image picker
import 'package:image_picker/image_picker.dart';

class ExtractTextService {
  Future<void> writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return new File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  static Future<String> extractText(Uri imageUri) async {
    String? text = await FlutterTesseractOcr.extractText(imageUri.path);
    if (text == null) {
      return '';
    }
    return text;
  }

  void ocr(url) async {
    String _ocrText = '';

    String path = url;
    /*  if (kIsWeb == false &&
        (url.indexOf("http://") == 0 || url.indexOf("https://") == 0)) {
      Directory tempDir = await getTemporaryDirectory();
      HttpClient httpClient = new HttpClient();
      HttpClientRequest request = await httpClient.getUrl(Uri.parse(url));
      HttpClientResponse response = await request.close();
      Uint8List bytes = await consolidateHttpClientResponseBytes(response);
      String dir = tempDir.path;
      print('$dir/test.jpg');
      File file = new File('$dir/test.jpg');
      await file.writeAsBytes(bytes);
      url = file.path;
    }*/

    _ocrText =
        await FlutterTesseractOcr.extractText(url, language: "fra", args: {
      "preserve_interword_spaces": "1",
    });

    print(_ocrText);
  }
}
