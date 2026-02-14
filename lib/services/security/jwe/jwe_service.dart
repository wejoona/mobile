/// JWE (JSON Web Encryption) service for encrypting sensitive API payloads.
///
/// Uses RSA-OAEP-256 + A256GCM as per the backend's ServerKeyService.
/// The server's public key is fetched once and cached. Automatically
/// re-fetches if the key has rotated (kid mismatch / decrypt failure).
library;

import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pointycastle/export.dart';
import 'package:usdc_wallet/utils/logger.dart';

final _log = AppLogger('JWE');

/// Represents a cached server public key.
class ServerPublicKey {
  final RSAPublicKey rsaKey;
  final String kid;
  final DateTime fetchedAt;

  ServerPublicKey({required this.rsaKey, required this.kid, required this.fetchedAt});

  bool get isExpired => DateTime.now().difference(fetchedAt).inHours > 24;
}

/// JWE encryption service — encrypts payloads using the server's RSA public key.
class JweService {
  // ignore: unused_field
  static const _tag = 'JWE';

  ServerPublicKey? _cachedKey;
  Dio? _dio;

  /// Initialize with a Dio instance for fetching the server public key.
  void init(Dio dio) {
    _dio = dio;
  }

  /// Fetch and cache the server's public key.
  Future<ServerPublicKey> getServerKey() async {
    if (_cachedKey != null && !_cachedKey!.isExpired) {
      return _cachedKey!;
    }

    if (_dio == null) throw StateError('JweService not initialized');

    _log.info('Fetching server public key...');
    final response = await _dio!.get('/security/public-key');
    final jwk = response.data as Map<String, dynamic>;

    final rsaKey = _jwkToRsaPublicKey(jwk);
    _cachedKey = ServerPublicKey(
      rsaKey: rsaKey,
      kid: jwk['kid'] as String? ?? 'unknown',
      fetchedAt: DateTime.now(),
    );

    _log.info('Server public key cached (kid: ${_cachedKey!.kid})');
    return _cachedKey!;
  }

  /// Encrypt a JSON payload as a JWE compact serialization.
  ///
  /// Format: header.encryptedKey.iv.ciphertext.tag
  /// Algorithm: RSA-OAEP-256 + A256GCM
  Future<String> encrypt(Map<String, dynamic> payload) async {
    final serverKey = await getServerKey();

    final random = SecureRandom('Fortuna');
    random.seed(KeyParameter(
      Uint8List.fromList(List.generate(32, (_) => Random.secure().nextInt(256))),
    ));

    // Generate 256-bit content encryption key (CEK)
    final cek = random.nextBytes(32);

    // Generate 96-bit IV for AES-GCM
    final iv = random.nextBytes(12);

    // Build JWE protected header
    final header = {
      'alg': 'RSA-OAEP-256',
      'enc': 'A256GCM',
      'kid': serverKey.kid,
    };
    final headerB64 = _base64UrlEncode(utf8.encode(jsonEncode(header)));

    // Encrypt CEK with RSA-OAEP-256
    final encryptedCek = _rsaOaepEncrypt(serverKey.rsaKey, cek, random);
    final encryptedCekB64 = _base64UrlEncode(encryptedCek);

    // Encrypt plaintext with AES-256-GCM
    final plaintext = utf8.encode(jsonEncode(payload));
    final aad = utf8.encode(headerB64); // Additional authenticated data

    final gcmResult = _aesGcmEncrypt(cek, iv, Uint8List.fromList(plaintext), Uint8List.fromList(aad));

    final ivB64 = _base64UrlEncode(iv);
    final ciphertextB64 = _base64UrlEncode(gcmResult.ciphertext);
    final tagB64 = _base64UrlEncode(gcmResult.tag);

    // JWE compact serialization: header.encryptedKey.iv.ciphertext.tag
    return '$headerB64.$encryptedCekB64.$ivB64.$ciphertextB64.$tagB64';
  }

  /// Invalidate cached key (call on 400 "re-fetch key" response).
  void invalidateKey() {
    _cachedKey = null;
    _log.info('Server key cache invalidated');
  }

  // ── Crypto helpers ─────────────────────────────────────

  RSAPublicKey _jwkToRsaPublicKey(Map<String, dynamic> jwk) {
    final n = _base64UrlDecode(jwk['n'] as String);
    final e = _base64UrlDecode(jwk['e'] as String);
    return RSAPublicKey(
      _bytesToBigInt(n),
      _bytesToBigInt(e),
    );
  }

  Uint8List _rsaOaepEncrypt(RSAPublicKey key, Uint8List data, SecureRandom random) {
    final encryptor = OAEPEncoding.withSHA256(RSAEngine())
      ..init(true, PublicKeyParameter<RSAPublicKey>(key));
    return encryptor.process(data);
  }

  _AesGcmResult _aesGcmEncrypt(
    Uint8List key,
    Uint8List iv,
    Uint8List plaintext,
    Uint8List aad,
  ) {
    final cipher = GCMBlockCipher(AESEngine());
    final params = AEADParameters(
      KeyParameter(key),
      128, // tag length in bits
      iv,
      aad,
    );
    cipher.init(true, params);

    final output = Uint8List(plaintext.length + 16); // +16 for tag
    final len = cipher.processBytes(plaintext, 0, plaintext.length, output, 0);
    cipher.doFinal(output, len);

    return _AesGcmResult(
      ciphertext: Uint8List.fromList(output.sublist(0, plaintext.length)),
      tag: Uint8List.fromList(output.sublist(plaintext.length)),
    );
  }

  // ── Encoding helpers ───────────────────────────────────

  String _base64UrlEncode(Uint8List bytes) {
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  Uint8List _base64UrlDecode(String input) {
    String padded = input;
    while (padded.length % 4 != 0) {
      padded += '=';
    }
    return base64Url.decode(padded);
  }

  BigInt _bytesToBigInt(Uint8List bytes) {
    BigInt result = BigInt.zero;
    for (final byte in bytes) {
      result = (result << 8) | BigInt.from(byte);
    }
    return result;
  }
}

class _AesGcmResult {
  final Uint8List ciphertext;
  final Uint8List tag;
  _AesGcmResult({required this.ciphertext, required this.tag});
}

/// Riverpod provider for JweService.
final jweServiceProvider = Provider<JweService>((ref) {
  return JweService();
});
