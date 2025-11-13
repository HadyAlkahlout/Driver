import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';

class AgoraTokenGenerator {
  static const String appId = 'fce29dd9bc6e4d7aafc65350d1bf98e2';
  static const String appCertificate = '963a03975d2748a79d50ccda1dedc511';

  // Token expiration time (24 hours from now)
  static int get expireTime =>
      (DateTime.now().millisecondsSinceEpoch ~/ 1000) + (24 * 3600);

  /// Generate RTC Token for video calling
  ///
  /// [channelName] - The channel name for the video call
  /// [uid] - User ID (0 for auto-generated)
  /// [role] - User role (1 for publisher/broadcaster, 2 for subscriber)
  /// [expireTimestamp] - Token expiration timestamp (optional)
  static String generateRtcToken({
    required String channelName,
    required int uid,
    int role = 1, // 1 = publisher (broadcaster), 2 = subscriber
    int? expireTimestamp,
  }) {
    try {
      final int expireTs = expireTimestamp ?? expireTime;

      // Create token using simplified approach for testing
      // Note: This is a simplified token for testing purposes
      // In production, use proper Agora token server

      final String randomSalt = _generateRandomString(32);
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Create a basic token structure
      final Map<String, dynamic> tokenData = {
        'appId': appId,
        'channelName': channelName,
        'uid': uid,
        'role': role,
        'expireTime': expireTs,
        'salt': randomSalt,
        'timestamp': timestamp,
      };

      // For testing purposes, create a deterministic token
      // This won't work with Agora servers but helps with local testing
      final String tokenBase = base64Encode(utf8.encode(jsonEncode(tokenData)));
      final String signature = _createSignature(tokenBase, appCertificate);

      return '007$signature$tokenBase';
    } catch (e) {
      print('Error generating token: $e');
      // Fallback to null token for testing
      return '';
    }
  }

  /// Generate a proper Agora token using official algorithm (simplified)
  static String generateProperToken({
    required String channelName,
    required int uid,
    int role = 1,
    int? expireTimestamp,
  }) {
    // For production use, you should implement the full Agora token algorithm
    // or use an Agora token server

    // This is a placeholder that returns empty string to use no token
    // which works for testing in development mode
    return '';
  }

  static String _generateRandomString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  static String _createSignature(String message, String secret) {
    final key = utf8.encode(secret);
    final bytes = utf8.encode(message);
    final hmacSha256 = Hmac(sha256, key);
    final digest = hmacSha256.convert(bytes);
    return base64Encode(digest.bytes);
  }

  /// Get temporary token for development/testing
  /// This returns null/empty which allows joining channels without authentication
  /// Only works in Agora's testing mode
  static String? getTestToken(String channelName, int uid) {
    // Return null for testing - this works when Agora project is in testing mode
    // In testing mode, Agora allows joining without valid tokens
    return null;
  }
}
