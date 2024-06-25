import 'dart:convert';

import 'package:crypto/crypto.dart';

/// 计算字符串的SHA-256哈希值
String sha256Hash(String input) {
  var bytes = utf8.encode(input); // 将输入字符串转换为字节数组
  var digest = sha256.convert(bytes); // 计算SHA-256哈希值
  return digest.toString(); // 将哈希值转换为十六进制字符串
}