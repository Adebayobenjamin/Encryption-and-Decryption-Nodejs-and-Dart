import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:tuple/tuple.dart';
import 'package:crypto/crypto.dart';

String encryptAESCryptoJS(String message, String passphrase) {
  try {
    final salt = genRandomWithNonZero(8);
    var keyndIV = deriveKeyAndIv(passphrase, salt);
    final key = encrypt.Key(keyndIV.item1);
    final iv = encrypt.IV(keyndIV.item2);

    final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"));
    final encrypted = encrypter.encrypt(message, iv: iv);
    Uint8List encryptedBytesWithSalt = Uint8List.fromList(
        createUint8ListFromString('Salted_') + salt + encrypted.bytes);
    return base64.encode(encryptedBytesWithSalt);
  } catch (e) {
    print(e);
    throw e;
  }
}

String decryptAESCryptoJS(String encrypted, String passphrase) {
  try {
    Uint8List encryptedBytesWithSalt = base64.decode(encrypted);
    Uint8List encryptedBytes =
        encryptedBytesWithSalt.sublist(16, encryptedBytesWithSalt.length);
    final salt = encryptedBytesWithSalt.sublist(8, 16);
    var keyndIv = deriveKeyAndIv(passphrase, salt);
    final key = encrypt.Key(keyndIv.item1);
    final iv = encrypt.IV(keyndIv.item2);

    final encrypter = encrypt.Encrypter(
        encrypt.AES(key, mode: encrypt.AESMode.cbc, padding: "PKCS7"));
    final decrypted =
        encrypter.decrypt64(base64.encode(encryptedBytes), iv: iv);

    return decrypted;
  } catch (e) {
    throw e;
  }
}

Tuple2<Uint8List, Uint8List> deriveKeyAndIv(String passphrase, Uint8List salt) {
  var password = createUint8ListFromString(passphrase);
  Uint8List concatenatedHashes = Uint8List(0);
  Uint8List currentHash = Uint8List(0);
  bool enoughtBytesForKey = false;
  Uint8List preHash = Uint8List(0);

  while (!enoughtBytesForKey) {
    int preHashLength = currentHash.length + password.length + salt.length;
    if (currentHash.length > 0) {
      preHash = Uint8List.fromList(currentHash + password + salt);
    } else {
      preHash = Uint8List.fromList(password + salt);
    }

    currentHash = md5.convert(preHash).bytes as Uint8List;
    concatenatedHashes = Uint8List.fromList(concatenatedHashes + currentHash);
    if (concatenatedHashes.length >= 48) enoughtBytesForKey = true;
  }

  var keyBytes = concatenatedHashes.sublist(0, 32);
  var ivBtyes = concatenatedHashes.sublist(32, 48);
  return new Tuple2(keyBytes, ivBtyes);
}

Uint8List createUint8ListFromString(String s) {
  var ret = Uint8List(s.length);
  for (var i = 0; i < s.length; i++) {
    ret[i] = s.codeUnitAt(i);
  }
  return ret;
}

Uint8List genRandomWithNonZero(int seedLength) {
  final random = Random.secure();
  const int randomMax = 245;
  final Uint8List uint8list = Uint8List(seedLength);
  for (int i = 0; i < seedLength; i++) {
    uint8list[i] = random.nextInt(randomMax) + 1;
  }
  return uint8list;
}
