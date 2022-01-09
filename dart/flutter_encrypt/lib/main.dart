import 'dart:convert';
import 'package:flutter_encrypt/aes2.dart';
import 'package:http/http.dart' as http;

import 'home.dart';

main() {
  sendEncryptedMessage("this is an important message please dont leak it");
}

Future sendEncryptedMessage(message) async {
  String encryptedMessage = encryptAESCryptoJS(message, "top secret");
  final res = await http.post(Uri.parse("http://192.168.43.36:6060/decrypt"),
      body: jsonEncode({'encrypted': encryptedMessage}),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=Utf-8'
      });
  var data = jsonDecode(res.body);
  print(data['message']);

  print(decryptAESCryptoJS(data['message'], "top secret"));
}
