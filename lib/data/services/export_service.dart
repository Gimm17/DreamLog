import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../core/constants/app_tokens.dart';
import '../models/app_settings.dart';
import '../models/dream_entry.dart';
import '../models/user_profile.dart';

enum DreamShareFormat {
  socialCard,
  story,
}

class ExportService {
  static const _shareChannel = MethodChannel('dreamlog/share');

  Future<File> exportDreamPdf(DreamEntry entry) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                entry.title,
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Text('Emotion: ${entry.primaryEmotion}'),
              pw.Text('Clarity: ${(entry.clarity * 100).round()}%'),
              pw.SizedBox(height: 24),
              pw.Text(entry.content),
              pw.SizedBox(height: 24),
              pw.Text(
                'AI Interpretation',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(entry.interpretation.interpretation),
              pw.SizedBox(height: 18),
              pw.Text('Symbols: ${entry.symbols.join(', ')}'),
              pw.SizedBox(height: 18),
              pw.Text('Reflection: ${entry.interpretation.reflectionQuestion}'),
            ],
          );
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${entry.id}.pdf');
    await file.writeAsBytes(await document.save());
    return file;
  }

  Future<File> exportDreamsPdf(List<DreamEntry> entries) async {
    final document = pw.Document();

    for (final entry in entries) {
      document.addPage(
        pw.Page(
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  entry.title,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text('Date: ${entry.createdAt.toIso8601String()}'),
                pw.Text('Emotion: ${entry.primaryEmotion}'),
                pw.Text('Clarity: ${(entry.clarity * 100).round()}%'),
                pw.SizedBox(height: 18),
                pw.Text(entry.content),
                pw.SizedBox(height: 18),
                pw.Text(
                  'AI Interpretation',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.Text(entry.interpretation.interpretation),
                pw.SizedBox(height: 12),
                pw.Text('Symbols: ${entry.symbols.join(', ')}'),
                pw.SizedBox(height: 12),
                pw.Text(
                    'Reflection: ${entry.interpretation.reflectionQuestion}'),
              ],
            );
          },
        ),
      );
    }

    if (entries.isEmpty) {
      document.addPage(
        pw.Page(
          build: (context) => pw.Center(
            child: pw.Text('DreamLog export: no dreams saved yet.'),
          ),
        ),
      );
    }

    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/dreamlog-export-$stamp.pdf');
    await file.writeAsBytes(await document.save());
    return file;
  }

  Future<File> exportDreamsJson(List<DreamEntry> entries) async {
    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/dreamlog-export-$stamp.json');
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(
      encoder.convert(entries.map((entry) => entry.toJson()).toList()),
    );
    return file;
  }

  Future<File> exportDreamLogBackupJson({
    required List<DreamEntry> entries,
    required UserProfile profile,
    required AppSettings settings,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/dreamlog-backup-$stamp.json');
    final profileJson = Map<String, dynamic>.from(profile.toJson())
      ..remove('avatar_path');
    final settingsJson = settings.copyWith(tokenRouterApiKey: '').toJson();
    final avatar = await _avatarBackup(profile.avatarPath);

    final backup = <String, dynamic>{
      'format': 'dreamlog_backup',
      'version': 1,
      'exported_at': DateTime.now().toIso8601String(),
      'profile': profileJson,
      'settings': settingsJson,
      'dreams': entries.map((entry) => entry.toJson()).toList(),
      if (avatar != null) 'avatar': avatar,
    };

    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString(encoder.convert(backup));
    return file;
  }

  Future<Map<String, dynamic>?> _avatarBackup(String? avatarPath) async {
    if (avatarPath == null || avatarPath.trim().isEmpty) {
      return null;
    }
    final file = File(avatarPath);
    if (!await file.exists()) {
      return null;
    }
    final bytes = await file.readAsBytes();
    final extension = avatarPath.split('.').last.toLowerCase();
    final mimeType = switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      _ => 'image/png',
    };
    return {
      'mime_type': mimeType,
      'extension': extension == 'jpeg' ? 'jpg' : extension,
      'base64': base64Encode(bytes),
    };
  }

  Future<File> shareDreamPdf(DreamEntry entry) async {
    return exportDreamPdf(entry);
  }

  Future<File> createDreamShareImage(
    DreamEntry entry, {
    required DreamShareFormat format,
  }) async {
    if (Platform.isAndroid) {
      final path = await _shareChannel.invokeMethod<String>(
        'createShareImage',
        {
          'format': format.name,
          'title': entry.title,
          'date': DateFormat('EEEE, d MMM yyyy').format(entry.createdAt),
          'emotion': entry.primaryEmotion,
          'clarity': (entry.clarity * 100).round(),
          'dream': entry.content,
          'interpretation': entry.interpretation.interpretation,
          'symbols': entry.symbols.take(4).toList(),
        },
      );
      if (path == null || path.trim().isEmpty) {
        throw StateError('Could not create share image.');
      }
      return File(path);
    }

    return _createDreamShareImageWithFlutterCanvas(entry, format: format);
  }

  Future<File> _createDreamShareImageWithFlutterCanvas(
    DreamEntry entry, {
    required DreamShareFormat format,
  }) async {
    final size = switch (format) {
      DreamShareFormat.socialCard => const Size(900, 1125),
      DreamShareFormat.story => const Size(720, 1280),
    };
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(
      recorder,
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    _drawShareBackground(canvas, size);
    _drawShareContent(canvas, size, entry, format);

    final picture = recorder.endRecording();
    final image =
        await picture.toImage(size.width.toInt(), size.height.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) {
      throw StateError('Could not render share image.');
    }

    final externalCacheDirs = await getExternalCacheDirectories();
    final dir = externalCacheDirs?.isNotEmpty == true
        ? externalCacheDirs!.first
        : await getTemporaryDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final file =
        File('${dir.path}/dreamlog-${entry.id}-${format.name}-$stamp.png');
    await file.writeAsBytes(bytes.buffer.asUint8List());
    return file;
  }

  void _drawShareBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, size.height),
          const [
            DreamColors.background,
            DreamColors.surface,
            Color(0xFF10281F),
          ],
        ),
    );

    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.16),
      260,
      Paint()..color = DreamColors.primaryLight.withValues(alpha: 0.18),
    );
    canvas.drawCircle(
      Offset(size.width * 0.12, size.height * 0.72),
      320,
      Paint()..color = DreamColors.aurora.withValues(alpha: 0.10),
    );

    final starPaint = Paint()
      ..color = DreamColors.textPrimary.withValues(alpha: 0.50);
    for (var index = 0; index < 46; index++) {
      final x = ((index * 193) % size.width.toInt()).toDouble();
      final y = ((index * 277) % size.height.toInt()).toDouble();
      final radius = 1.4 + (index % 4) * 0.55;
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  void _drawShareContent(
    Canvas canvas,
    Size size,
    DreamEntry entry,
    DreamShareFormat format,
  ) {
    final margin = format == DreamShareFormat.story ? 82.0 : 72.0;
    final maxWidth = size.width - (margin * 2);
    var y = format == DreamShareFormat.story ? 145.0 : 96.0;

    _paintText(
      canvas,
      'DreamLog',
      Offset(margin, y),
      maxWidth: maxWidth,
      style: const TextStyle(
        color: DreamColors.textPrimary,
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
    y += 54;

    _paintText(
      canvas,
      DateFormat('EEEE, d MMM yyyy').format(entry.createdAt),
      Offset(margin, y),
      maxWidth: maxWidth,
      style: const TextStyle(
        color: DreamColors.textSecondary,
        fontSize: 28,
        letterSpacing: 0,
      ),
    );
    y += format == DreamShareFormat.story ? 98 : 76;

    final titleHeight = _paintText(
      canvas,
      entry.title,
      Offset(margin, y),
      maxWidth: maxWidth,
      maxLines: format == DreamShareFormat.story ? 3 : 2,
      style: TextStyle(
        color: DreamColors.textPrimary,
        fontSize: format == DreamShareFormat.story ? 70 : 58,
        fontWeight: FontWeight.w800,
        height: 1.05,
        letterSpacing: 0,
      ),
    );
    y += titleHeight + 34;

    _drawPill(
      canvas,
      Offset(margin, y),
      '${entry.primaryEmotion}  -  clarity ${(entry.clarity * 100).round()}%',
      color: emotionColor(entry.primaryEmotion).withValues(alpha: 0.22),
      textColor: DreamColors.textPrimary,
    );
    y += 78;

    y += _paintSection(
      canvas,
      label: 'The Dream',
      body: entry.content,
      offset: Offset(margin, y),
      maxWidth: maxWidth,
      maxLines: format == DreamShareFormat.story ? 8 : 4,
    );
    y += 44;

    y += _paintSection(
      canvas,
      label: 'AI Interpretation',
      body: entry.interpretation.interpretation,
      offset: Offset(margin, y),
      maxWidth: maxWidth,
      maxLines: format == DreamShareFormat.story ? 8 : 4,
    );
    y += 40;

    if (entry.symbols.isNotEmpty) {
      final labelHeight = _paintText(
        canvas,
        'Symbols',
        Offset(margin, y),
        maxWidth: maxWidth,
        style: const TextStyle(
          color: DreamColors.aurora,
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      );
      y += labelHeight + 18;

      var x = margin;
      for (final symbol in entry.symbols.take(4)) {
        final chipWidth = _pillWidth(symbol);
        if (x + chipWidth > size.width - margin) {
          break;
        }
        _drawPill(
          canvas,
          Offset(x, y),
          symbol,
          color: DreamColors.surfaceTwo.withValues(alpha: 0.88),
          textColor: DreamColors.textPrimary,
        );
        x += chipWidth + 14;
      }
    }

    final footerY =
        size.height - (format == DreamShareFormat.story ? 178 : 118);
    canvas.drawLine(
      Offset(margin, footerY - 30),
      Offset(size.width - margin, footerY - 30),
      Paint()
        ..color = DreamColors.textPrimary.withValues(alpha: 0.14)
        ..strokeWidth = 2,
    );
    _paintText(
      canvas,
      'Shared from DreamLog',
      Offset(margin, footerY),
      maxWidth: maxWidth,
      style: const TextStyle(
        color: DreamColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
    _paintText(
      canvas,
      'AI dream journal and pattern analyzer',
      Offset(margin, footerY + 42),
      maxWidth: maxWidth,
      style: const TextStyle(
        color: DreamColors.textSecondary,
        fontSize: 24,
        letterSpacing: 0,
      ),
    );
  }

  double _paintSection(
    Canvas canvas, {
    required String label,
    required String body,
    required Offset offset,
    required double maxWidth,
    required int maxLines,
  }) {
    final labelHeight = _paintText(
      canvas,
      label,
      offset,
      maxWidth: maxWidth,
      style: const TextStyle(
        color: DreamColors.aurora,
        fontSize: 24,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
    final bodyHeight = _paintText(
      canvas,
      body.trim(),
      Offset(offset.dx, offset.dy + labelHeight + 16),
      maxWidth: maxWidth,
      maxLines: maxLines,
      style: const TextStyle(
        color: DreamColors.textPrimary,
        fontSize: 34,
        height: 1.35,
        letterSpacing: 0,
      ),
    );
    return labelHeight + 16 + bodyHeight;
  }

  double _paintText(
    Canvas canvas,
    String text,
    Offset offset, {
    required double maxWidth,
    required TextStyle style,
    int? maxLines,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: ui.TextDirection.ltr,
      maxLines: maxLines,
      ellipsis: maxLines == null ? null : '...',
    )..layout(maxWidth: maxWidth);
    painter.paint(canvas, offset);
    return painter.height;
  }

  void _drawPill(
    Canvas canvas,
    Offset offset,
    String text, {
    required Color color,
    required Color textColor,
  }) {
    final width = _pillWidth(text);
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, width, 48),
      const Radius.circular(999),
    );
    canvas.drawRRect(rect, Paint()..color = color);
    _paintText(
      canvas,
      text,
      Offset(offset.dx + 22, offset.dy + 9),
      maxWidth: width - 44,
      maxLines: 1,
      style: TextStyle(
        color: textColor,
        fontSize: 22,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }

  double _pillWidth(String text) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter.width + 44;
  }
}
