import 'dart:convert';

import 'package:crypto/crypto.dart';

/// 签名
String signature({
  required String accessKeyId, // 应用API Key
  required String secretAccessKey, // 应用Secret Key
  required String path, // 请求URL
  required String method, // 请求方法
  required String timestamp, // 请求时间，例如："2024-05-23T05:40:47Z"，必须是UTC时间
  Map<String, dynamic>? queryParameters,
  Map<String, dynamic>? headers,
}) {
  const int expirationPeriodInSeconds = 1800; // 30分钟过期

  // 任务一：创建前缀字符串(authStringPrefix)
  final String authStringPrefix =
      'bce-auth-v1/$accessKeyId/$timestamp/$expirationPeriodInSeconds';

  // 任务二：创建规范请求(canonicalRequest)，确定签名头域(signedHeaders)
  final String canonicalMethod = method.toUpperCase();
  final String canonicalQueryString =
      _createCanonicalQueryString(queryParameters);
  final String canonicalHeaders = _createCanonicalHeaders(headers);
  final String signedHeaders = _createSignedHeaders(headers);
  final String canonicalRequest =
      '$canonicalMethod\n$path\n$canonicalQueryString\n$canonicalHeaders';

  // 任务三：生成派生签名密钥(signingKey)
  final String signingKey = _hmacSha256(secretAccessKey, authStringPrefix);

  // 任务四：生成签名摘要(signature)，并拼接最终的认证字符串(authorization)
  final String signature = _hmacSha256(signingKey, canonicalRequest);
  final String authorization =
      'bce-auth-v1/$accessKeyId/$timestamp/$expirationPeriodInSeconds/$signedHeaders/$signature';

  return authorization;
}

String _createCanonicalQueryString(Map<String, dynamic>? queryParameters) {
  if (queryParameters == null || queryParameters.isEmpty) {
    return '';
  }
  final List<String> pairs = queryParameters.entries.map((e) {
    final String key = Uri.encodeComponent(e.key);
    final String value = Uri.encodeComponent(e.value.toString());
    return '$key=$value';
  }).toList();
  pairs.sort();
  return pairs.join('&');
}

String _createCanonicalHeaders(Map<String, dynamic>? headers) {
  if (headers == null || headers.isEmpty) {
    return '';
  }
  final List<String> headerLines = headers.entries
      .map((e) {
        final String key = e.key.toLowerCase();
        final String value = Uri.encodeComponent(e.value.toString().trim());
        return '$key:$value';
      })
      .where((h) => h.isNotEmpty)
      .toList();
  headerLines.sort();
  return headerLines.join('\n');
}

String _createSignedHeaders(Map<String, dynamic>? headers) {
  if (headers == null || headers.isEmpty) {
    return '';
  }
  final List<String> signedHeaders =
      headers.keys.map((h) => h.toLowerCase()).toList();
  signedHeaders.sort();
  return signedHeaders.join(';');
}

String _hmacSha256(String key, String message) {
  final hmac = Hmac(sha256, utf8.encode(key));
  final signatureBytes = hmac.convert(utf8.encode(message));
  return signatureBytes.toString();
}
