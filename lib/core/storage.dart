import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

class BlushyStorage {
  static final Map<String, dynamic> _memoryCache = {};

  static void write(String key, Map<String, dynamic> data) {
    _memoryCache[key] = data;
    if (!kIsWeb) {
      try {
        final file = File(key);
        file.writeAsStringSync(jsonEncode(data));
      } catch (_) {}
    }
  }

  static Map<String, dynamic> read(String key) {
    if (_memoryCache.containsKey(key)) {
      return _memoryCache[key] ?? {};
    }
    if (!kIsWeb) {
      try {
        final file = File(key);
        if (file.existsSync()) {
          final content = file.readAsStringSync();
          final decoded = jsonDecode(content);
          _memoryCache[key] = decoded;
          return decoded;
        }
      } catch (_) {}
    }
    return {};
  }
}
