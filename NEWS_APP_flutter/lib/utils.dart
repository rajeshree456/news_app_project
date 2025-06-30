import 'dart:convert';
import 'package:crypto/crypto.dart';

String generateArticleId(String url) {
  var bytes = utf8.encode(url);
  var digest = sha1.convert(bytes);
  return digest.toString();
}
