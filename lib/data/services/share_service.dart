import 'dart:io';

import 'package:flutter/services.dart';

class ShareService {
  static const _channel = MethodChannel('dreamlog/share');

  Future<void> shareFile({
    required File file,
    required String mimeType,
    required String chooserTitle,
    String? text,
  }) async {
    await _channel.invokeMethod<void>('shareFile', {
      'path': file.path,
      'mimeType': mimeType,
      'chooserTitle': chooserTitle,
      'text': text,
    });
  }

  Future<void> shareFiles({
    required List<File> files,
    required String mimeType,
    required String chooserTitle,
    String? text,
  }) async {
    await _channel.invokeMethod<void>('shareFiles', {
      'paths': files.map((file) => file.path).toList(),
      'mimeType': mimeType,
      'chooserTitle': chooserTitle,
      'text': text,
    });
  }
}
