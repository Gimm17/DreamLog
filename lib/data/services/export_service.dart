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
import '../models/dream_symbol_catalog.dart';
import '../models/user_profile.dart';
import '../models/weekly_report.dart';

enum DreamShareFormat {
  socialCard,
  story,
}

enum _WeeklyShareSlide {
  overview,
  symbols,
  summary,
  journey,
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

    final dir = await _shareOutputDirectory();
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

  Future<File> exportWeeklyReportPdf({
    required WeeklyReport report,
    required List<DreamEntry> entries,
    required String range,
  }) async {
    final document = pw.Document();

    document.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'DreamLog Weekly Report',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(range),
              pw.Text('${entries.length} dreams analyzed'),
              pw.SizedBox(height: 24),
              pw.Text(
                report.dominantTheme,
                style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 18),
              pw.Text(
                'Summary',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(report.weekSummary),
              pw.SizedBox(height: 18),
              pw.Text(
                'Emotional Journey',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(report.emotionalJourney),
              pw.SizedBox(height: 18),
              pw.Text(
                'Recurring Symbols',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(
                report.recurringSymbols.isEmpty
                    ? 'No recurring symbols detected yet.'
                    : report.recurringSymbols.join(', '),
              ),
              pw.SizedBox(height: 18),
              pw.Text(
                'Insight',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(report.insight),
              pw.SizedBox(height: 18),
              pw.Text(
                'Affirmation',
                style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              ),
              pw.Text(report.affirmation),
            ],
          );
        },
      ),
    );

    final dir = await _shareOutputDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/dreamlog-weekly-report-$stamp.pdf');
    await file.writeAsBytes(await document.save());
    return file;
  }

  Future<File> exportDreamLogBackupJson({
    required List<DreamEntry> entries,
    required UserProfile profile,
    required AppSettings settings,
  }) async {
    final dir = await _shareOutputDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/dreamlog-backup-$stamp.json');
    final profileJson = Map<String, dynamic>.from(profile.toJson())
      ..remove('avatar_path');
    final settingsJson = settings.toJson();
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

  Future<Directory> _shareOutputDirectory() async {
    final externalCacheDirs = await getExternalCacheDirectories();
    if (externalCacheDirs?.isNotEmpty == true) {
      return externalCacheDirs!.first;
    }
    return getTemporaryDirectory();
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

  Future<List<File>> createWeeklyReportShareImages({
    required WeeklyReport report,
    required List<DreamEntry> entries,
    required String range,
    required DreamShareFormat format,
  }) async {
    final size = switch (format) {
      DreamShareFormat.socialCard => const Size(900, 1125),
      DreamShareFormat.story => const Size(720, 1280),
    };
    final dir = await _shareOutputDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final files = <File>[];

    for (final slide in _WeeklyShareSlide.values) {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(0, 0, size.width, size.height),
      );

      _drawWeeklyShareBackground(canvas, size);
      _drawWeeklyShareContent(
        canvas,
        size,
        report: report,
        entries: entries,
        range: range,
        format: format,
        slide: slide,
      );

      final picture = recorder.endRecording();
      final image =
          await picture.toImage(size.width.toInt(), size.height.toInt());
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      if (bytes == null) {
        throw StateError('Could not render weekly share image.');
      }

      final file = File(
        '${dir.path}/dreamlog-weekly-${format.name}-${slide.name}-$stamp.png',
      );
      await file.writeAsBytes(bytes.buffer.asUint8List());
      files.add(file);
    }

    return files;
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
          [
            DreamColors.background,
            DreamColors.surface,
            const Color(0xFF10281F),
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

  void _drawWeeklyShareBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset.zero,
          Offset(size.width, size.height),
          const [
            Color(0xFF080710),
            Color(0xFF191532),
            Color(0xFF08332B),
          ],
          const [0, 0.58, 1],
        ),
    );

    canvas.drawCircle(
      Offset(size.width * 0.76, size.height * 0.13),
      size.width * 0.25,
      Paint()..color = DreamColors.aurora.withValues(alpha: 0.20),
    );
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.13),
      size.width * 0.19,
      Paint()..color = const Color(0xFF080710).withValues(alpha: 0.72),
    );
    canvas.drawCircle(
      Offset(size.width * 0.14, size.height * 0.48),
      size.width * 0.34,
      Paint()..color = DreamColors.primaryLight.withValues(alpha: 0.12),
    );

    final starPaint = Paint()
      ..color = DreamColors.textPrimary.withValues(alpha: 0.42);
    for (var index = 0; index < 64; index++) {
      final x = ((index * 157) % size.width.toInt()).toDouble();
      final y = ((index * 241) % size.height.toInt()).toDouble();
      final radius = 1.0 + (index % 5) * 0.42;
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }

    final linePaint = Paint()
      ..color = DreamColors.aurora.withValues(alpha: 0.16)
      ..strokeWidth = 2;
    for (var index = 0; index < 5; index++) {
      final y = size.height * (0.28 + index * 0.08);
      canvas.drawLine(
        Offset(size.width * 0.10, y),
        Offset(size.width * 0.90, y + 26),
        linePaint,
      );
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

  void _drawWeeklyShareContent(
    Canvas canvas,
    Size size, {
    required WeeklyReport report,
    required List<DreamEntry> entries,
    required String range,
    required DreamShareFormat format,
    required _WeeklyShareSlide slide,
  }) {
    final isStory = format == DreamShareFormat.story;
    final margin = isStory ? 56.0 : 64.0;
    final maxWidth = size.width - (margin * 2);
    final footerY = size.height - (isStory ? 118.0 : 104.0);
    final slideIndex = _WeeklyShareSlide.values.indexOf(slide) + 1;

    _drawWeeklyHeader(
      canvas,
      size,
      margin: margin,
      maxWidth: maxWidth,
      range: range,
      slideText: '$slideIndex / 4',
    );

    switch (slide) {
      case _WeeklyShareSlide.overview:
        _drawWeeklyOverviewSlide(
          canvas,
          size,
          report: report,
          entries: entries,
          margin: margin,
          maxWidth: maxWidth,
          isStory: isStory,
        );
      case _WeeklyShareSlide.symbols:
        _drawWeeklySymbolsSlide(
          canvas,
          size,
          report: report,
          margin: margin,
          maxWidth: maxWidth,
          isStory: isStory,
        );
      case _WeeklyShareSlide.summary:
        _drawWeeklyTextSlide(
          canvas,
          size,
          title: 'Week Summary',
          body: report.weekSummary,
          caption: 'Full text',
          margin: margin,
          maxWidth: maxWidth,
          isStory: isStory,
        );
      case _WeeklyShareSlide.journey:
        _drawWeeklyJourneySlide(
          canvas,
          size,
          report: report,
          margin: margin,
          maxWidth: maxWidth,
          isStory: isStory,
        );
    }

    _drawWeeklyFooter(
      canvas,
      size,
      margin: margin,
      maxWidth: maxWidth,
      footerY: footerY,
    );
  }

  void _drawWeeklyHeader(
    Canvas canvas,
    Size size, {
    required double margin,
    required double maxWidth,
    required String range,
    required String slideText,
  }) {
    _paintText(
      canvas,
      'DreamLog Weekly',
      Offset(margin, 68),
      maxWidth: maxWidth * 0.66,
      style: const TextStyle(
        color: DreamColors.aurora,
        fontSize: 27,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
    _paintText(
      canvas,
      slideText,
      Offset(size.width - margin - 96, 72),
      maxWidth: 96,
      maxLines: 1,
      style: const TextStyle(
        color: DreamColors.textSecondary,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );

    _paintText(
      canvas,
      range,
      Offset(margin, 106),
      maxWidth: maxWidth,
      style: const TextStyle(
        color: DreamColors.textSecondary,
        fontSize: 22,
        letterSpacing: 0,
      ),
    );
  }

  void _drawWeeklyOverviewSlide(
    Canvas canvas,
    Size size, {
    required WeeklyReport report,
    required List<DreamEntry> entries,
    required double margin,
    required double maxWidth,
    required bool isStory,
  }) {
    final titleTop = isStory ? 174.0 : 150.0;
    final statsTop = isStory ? 370.0 : 306.0;
    final summaryTop = isStory ? 496.0 : 420.0;
    final insightTop = isStory ? 812.0 : 704.0;

    _paintText(
      canvas,
      report.dominantTheme,
      Offset(margin, titleTop),
      maxWidth: maxWidth,
      maxLines: isStory ? 3 : 2,
      style: TextStyle(
        color: DreamColors.textPrimary,
        fontSize: isStory ? 42 : 43,
        fontWeight: FontWeight.w900,
        height: 1.06,
        letterSpacing: 0,
      ),
    );

    final topEmotion = _topEmotion(entries);
    final symbolCount =
        entries.fold<int>(0, (total, entry) => total + entry.symbols.length);
    final statWidth = (maxWidth - 22) / 3;
    _drawStatTile(
      canvas,
      Offset(margin, statsTop),
      statWidth,
      '${entries.length}',
      'dreams',
      DreamColors.primaryLight,
    );
    _drawStatTile(
      canvas,
      Offset(margin + statWidth + 11, statsTop),
      statWidth,
      '$symbolCount',
      'symbols',
      DreamColors.aurora,
    );
    _drawStatTile(
      canvas,
      Offset(margin + (statWidth + 11) * 2, statsTop),
      statWidth,
      topEmotion,
      'top mood',
      emotionColor(topEmotion),
    );

    _drawWeeklyPanel(
      canvas,
      Offset(margin, summaryTop),
      Size(maxWidth, isStory ? 272 : 236),
      label: 'WEEK SUMMARY',
      body: report.weekSummary,
      maxLines: isStory ? 4 : 3,
      bodyFontSize: isStory ? 30 : 29,
    );

    _drawWeeklyPanel(
      canvas,
      Offset(margin, insightTop),
      Size(maxWidth, isStory ? 178 : 148),
      label: 'KEY INSIGHT',
      body: report.insight,
      maxLines: isStory ? 3 : 2,
      bodyFontSize: isStory ? 28 : 27,
    );
  }

  void _drawWeeklySymbolsSlide(
    Canvas canvas,
    Size size, {
    required WeeklyReport report,
    required double margin,
    required double maxWidth,
    required bool isStory,
  }) {
    _paintText(
      canvas,
      'Recurring Symbols',
      Offset(margin, isStory ? 170 : 150),
      maxWidth: maxWidth,
      maxLines: 2,
      style: TextStyle(
        color: DreamColors.textPrimary,
        fontSize: isStory ? 48 : 48,
        fontWeight: FontWeight.w900,
        height: 1.05,
        letterSpacing: 0,
      ),
    );
    _paintText(
      canvas,
      'Simbol yang paling sering muncul minggu ini.',
      Offset(margin, isStory ? 280 : 242),
      maxWidth: maxWidth,
      maxLines: 2,
      style: const TextStyle(
        color: DreamColors.textSecondary,
        fontSize: 25,
        height: 1.2,
        letterSpacing: 0,
      ),
    );

    final symbols = report.recurringSymbols.isEmpty
        ? const ['No recurring symbols detected yet.']
        : report.recurringSymbols.take(4).toList();
    final rowHeight = isStory ? 158.0 : 142.0;
    var y = isStory ? 370.0 : 326.0;
    for (var index = 0; index < symbols.length; index++) {
      _drawSymbolPanel(
        canvas,
        Offset(margin, y),
        Size(maxWidth, rowHeight),
        symbols[index],
        index + 1,
      );
      y += rowHeight + 18;
    }
  }

  void _drawWeeklyTextSlide(
    Canvas canvas,
    Size size, {
    required String title,
    required String body,
    required String caption,
    required double margin,
    required double maxWidth,
    required bool isStory,
  }) {
    _paintText(
      canvas,
      title,
      Offset(margin, isStory ? 176 : 152),
      maxWidth: maxWidth,
      maxLines: 2,
      style: TextStyle(
        color: DreamColors.textPrimary,
        fontSize: isStory ? 52 : 52,
        fontWeight: FontWeight.w900,
        height: 1.04,
        letterSpacing: 0,
      ),
    );
    _paintText(
      canvas,
      caption,
      Offset(margin, isStory ? 292 : 258),
      maxWidth: maxWidth,
      maxLines: 1,
      style: const TextStyle(
        color: DreamColors.aurora,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
    _drawWeeklyPanel(
      canvas,
      Offset(margin, isStory ? 350 : 316),
      Size(maxWidth, isStory ? 728 : 622),
      label: 'DETAIL',
      body: body,
      maxLines: isStory ? 14 : 10,
      bodyFontSize: isStory ? 30 : 30,
    );
  }

  void _drawWeeklyJourneySlide(
    Canvas canvas,
    Size size, {
    required WeeklyReport report,
    required double margin,
    required double maxWidth,
    required bool isStory,
  }) {
    _paintText(
      canvas,
      'Journey & Insight',
      Offset(margin, isStory ? 176 : 152),
      maxWidth: maxWidth,
      maxLines: 2,
      style: TextStyle(
        color: DreamColors.textPrimary,
        fontSize: isStory ? 52 : 52,
        fontWeight: FontWeight.w900,
        height: 1.04,
        letterSpacing: 0,
      ),
    );
    _drawWeeklyPanel(
      canvas,
      Offset(margin, isStory ? 310 : 286),
      Size(maxWidth, isStory ? 330 : 272),
      label: 'EMOTIONAL JOURNEY',
      body: report.emotionalJourney,
      maxLines: isStory ? 6 : 4,
      bodyFontSize: isStory ? 28 : 28,
    );
    _drawWeeklyPanel(
      canvas,
      Offset(margin, isStory ? 678 : 592),
      Size(maxWidth, isStory ? 268 : 224),
      label: 'AI INSIGHT',
      body: report.insight,
      maxLines: isStory ? 5 : 4,
      bodyFontSize: isStory ? 28 : 28,
    );
    _drawConstrainedPill(
      canvas,
      Offset(margin, isStory ? 986 : 856),
      report.affirmation,
      maxWidth: maxWidth,
      color: DreamColors.aurora.withValues(alpha: 0.16),
      textColor: DreamColors.textPrimary,
    );
  }

  void _drawWeeklyFooter(
    Canvas canvas,
    Size size, {
    required double margin,
    required double maxWidth,
    required double footerY,
  }) {
    canvas.drawLine(
      Offset(margin, footerY - 28),
      Offset(size.width - margin, footerY - 28),
      Paint()
        ..color = DreamColors.textPrimary.withValues(alpha: 0.16)
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
        fontWeight: FontWeight.w800,
        letterSpacing: 0,
      ),
    );
    _paintText(
      canvas,
      'AI dream journal and weekly pattern map',
      Offset(margin, footerY + 40),
      maxWidth: maxWidth,
      style: const TextStyle(
        color: DreamColors.textSecondary,
        fontSize: 23,
        letterSpacing: 0,
      ),
    );
  }

  void _drawStatTile(
    Canvas canvas,
    Offset offset,
    double width,
    String value,
    String label,
    Color accent,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, width, 86),
      const Radius.circular(22),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = DreamColors.surfaceTwo.withValues(alpha: 0.76),
    );
    canvas.drawCircle(
      Offset(offset.dx + width - 24, offset.dy + 22),
      18,
      Paint()..color = accent.withValues(alpha: 0.28),
    );
    _paintText(
      canvas,
      value,
      Offset(offset.dx + 18, offset.dy + 15),
      maxWidth: width - 36,
      maxLines: 1,
      style: const TextStyle(
        color: DreamColors.textPrimary,
        fontSize: 28,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
    _paintText(
      canvas,
      label,
      Offset(offset.dx + 18, offset.dy + 52),
      maxWidth: width - 36,
      maxLines: 1,
      style: const TextStyle(
        color: DreamColors.textSecondary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: 0,
      ),
    );
  }

  double _drawWeeklyPanel(
    Canvas canvas,
    Offset offset,
    Size size, {
    required String label,
    required String body,
    required int maxLines,
    required double bodyFontSize,
  }) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
      const Radius.circular(28),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = DreamColors.surface.withValues(alpha: 0.74),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = DreamColors.aurora.withValues(alpha: 0.18),
    );
    canvas.save();
    canvas.clipRRect(rect);
    _paintText(
      canvas,
      label,
      Offset(offset.dx + 26, offset.dy + 26),
      maxWidth: size.width - 52,
      style: const TextStyle(
        color: DreamColors.aurora,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
    _paintText(
      canvas,
      body.trim(),
      Offset(offset.dx + 26, offset.dy + 68),
      maxWidth: size.width - 52,
      maxLines: maxLines,
      style: const TextStyle(
        color: DreamColors.textPrimary,
        fontSize: 1,
        height: 1.28,
        letterSpacing: 0,
      ).copyWith(fontSize: bodyFontSize),
    );
    canvas.restore();
    return size.height;
  }

  void _drawSymbolPanel(
    Canvas canvas,
    Offset offset,
    Size size,
    String rawSymbol,
    int index,
  ) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx, offset.dy, size.width, size.height),
      const Radius.circular(28),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = DreamColors.surface.withValues(alpha: 0.74),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = DreamColors.aurora.withValues(alpha: 0.16),
    );

    final symbol = _symbolShareText(rawSymbol);
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(offset.dx + 24, offset.dy + 26, 48, 48),
      const Radius.circular(16),
    );
    canvas.drawRRect(
      badgeRect,
      Paint()..color = DreamColors.aurora.withValues(alpha: 0.18),
    );
    _paintText(
      canvas,
      '$index',
      Offset(offset.dx + 42, offset.dy + 35),
      maxWidth: 24,
      maxLines: 1,
      style: const TextStyle(
        color: DreamColors.aurora,
        fontSize: 23,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );

    canvas.save();
    canvas.clipRRect(rect);
    _paintText(
      canvas,
      symbol.title,
      Offset(offset.dx + 92, offset.dy + 26),
      maxWidth: size.width - 122,
      maxLines: 1,
      style: const TextStyle(
        color: DreamColors.textPrimary,
        fontSize: 27,
        fontWeight: FontWeight.w900,
        letterSpacing: 0,
      ),
    );
    _paintText(
      canvas,
      symbol.detail,
      Offset(offset.dx + 92, offset.dy + 68),
      maxWidth: size.width - 122,
      maxLines: 2,
      style: const TextStyle(
        color: DreamColors.textSecondary,
        fontSize: 22,
        height: 1.22,
        letterSpacing: 0,
      ),
    );
    canvas.restore();
  }

  ({String title, String detail}) _symbolShareText(String rawSymbol) {
    final canonical = canonicalDreamSymbol(rawSymbol);
    if (canonical != null) {
      return (title: canonical.name, detail: canonical.meaning);
    }

    final cleaned = rawSymbol.trim();
    if (cleaned.isEmpty) {
      return (
        title: 'No recurring symbols',
        detail: 'DreamLog needs more dreams before it can map symbol patterns.'
      );
    }

    final parts = cleaned.split(RegExp(r'\s+-\s+'));
    final title = parts.first.trim();
    final detail = parts.length > 1
        ? parts.sublist(1).join(' - ').trim()
        : 'Muncul sebagai simbol berulang yang bisa menjadi petunjuk pola mimpi minggu ini.';
    return (title: title, detail: detail);
  }

  String _topEmotion(List<DreamEntry> entries) {
    if (entries.isEmpty) {
      return 'Quiet';
    }
    final counts = <String, int>{};
    for (final entry in entries) {
      counts.update(
        entry.primaryEmotion,
        (value) => value + 1,
        ifAbsent: () => 1,
      );
    }
    final sorted = counts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first.key;
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

  void _drawConstrainedPill(
    Canvas canvas,
    Offset offset,
    String text, {
    required double maxWidth,
    required Color color,
    required Color textColor,
  }) {
    final width = _pillWidth(text).clamp(96, maxWidth).toDouble();
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
