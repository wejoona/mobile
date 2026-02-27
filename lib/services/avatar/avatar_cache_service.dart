import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';

class AvatarCacheService {
  /// Download avatar from URL and cache locally. Returns local file path.
  Future<String?> cacheAvatar(String url) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory('${dir.path}/avatars');
      if (!await avatarDir.exists()) await avatarDir.create(recursive: true);

      final hash = md5.convert(utf8.encode(url)).toString();
      final ext = url.contains('.png') ? 'png' : 'jpg';
      final file = File('${avatarDir.path}/$hash.$ext');

      if (await file.exists()) return file.path; // Already cached

      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();
      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        await file.writeAsBytes(bytes);
        return file.path;
      }
      return null;
    } catch (e) {
      debugPrint('[AvatarCache] Failed to cache avatar: $e');
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final avatarDir = Directory('${dir.path}/avatars');
      if (await avatarDir.exists()) await avatarDir.delete(recursive: true);
    } catch (_) {}
  }
}

final avatarCacheServiceProvider = Provider<AvatarCacheService>((ref) => AvatarCacheService());
