import 'dart:convert';
import 'dart:io';

/// 使用gzip压缩字符串，并进行base64编码和URL编码
String gzipCompress(String source) {
  List<int> compressedBytes = gzip.encode(utf8.encode(source));
  final compressedString = Uri.encodeComponent(base64Encode(compressedBytes));
  return compressedString;
}

/// 使用gzip解压缩字符串，先进行URL解码和base64解码
String gzipDecompress(String compressedString) {
  List<int> compressedBytes =
      base64Decode(Uri.decodeComponent(compressedString));
  List<int> bytes = gzip.decode(compressedBytes);
  return utf8.decode(bytes);
}
