import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ContactController extends GetxController {
  final storage = const FlutterSecureStorage();
  String last = '';
  String dat = '';
  void putVar() async {
    print('Last: $last');
    print('Date:$dat');
    await storage.write(key: 'data', value: dat);
    Get.snackbar('Done'.tr, last,
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM);
    //send
    // postNumber();
  }

  postNumber() async {
    try {
      var headers = {
        'Accept': 'application/json',
        'Authorization':
            'Bearer 6|8misXfJtPYIuDWZ5ZJfM2wW1ZC0Lhrl4D8up3Aiz3e46cdab'
      };
      var request = http.MultipartRequest(
          'POST', Uri.parse('https://phones.alwafierp.com/api/phone-store'));
      request.fields.addAll({'phone': '9045865787'});

      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        print(await response.stream.bytesToString());
        Get.snackbar('Done'.tr, '',
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM);
      } else {
        print(response.statusCode);
        print(response.reasonPhrase);
      }
    } catch (e) {
      print('Error$e');
    }
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
