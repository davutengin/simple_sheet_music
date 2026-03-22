import 'package:flutter/material.dart';
import 'package:simple_sheet_music/src/constants.dart';
import 'package:simple_sheet_music/src/glyph_metadata.dart';
import 'package:simple_sheet_music/src/glyph_path.dart';
import 'package:simple_sheet_music/src/music_objects/interface/musical_symbol.dart';
import 'package:simple_sheet_music/src/music_objects/interface/musical_symbol_metrics.dart';
import 'package:simple_sheet_music/src/music_objects/interface/musical_symbol_renderer.dart';
import 'package:simple_sheet_music/src/musical_context.dart';
import 'package:simple_sheet_music/src/sheet_music_layout.dart';

/// Nota donanımında gösterilecek ölçü işareti (örn. 4/4, 3/4).
class TimeSignature implements MusicalSymbol {
  const TimeSignature({
    required this.numerator,
    required this.denominator,
    this.color = Colors.black,
    this.margin = const EdgeInsets.symmetric(horizontal: 10),
  });

  final int numerator;
  final int denominator;

  @override
  final Color color;

  @override
  final EdgeInsets margin;

  /// SMuFL Bravura fontunda zaman işareti rakamları uniE080–uniE089.
  static String _glyphKey(int digit) =>
      'uniE08${digit.clamp(0, 9)}';

  @override
  MusicalSymbolMetrics setContext(
    MusicalContext context,
    GlyphMetadata metadata,
    GlyphPaths paths,
  ) =>
      TimeSignatureMetrics(this, paths);
}

class TimeSignatureMetrics implements MusicalSymbolMetrics {
  const TimeSignatureMetrics(this.timeSignature, this.paths);

  final TimeSignature timeSignature;
  final GlyphPaths paths;

  Path _digitPath(int digit) =>
      paths.parsePath(TimeSignature._glyphKey(digit));

  // Her rakamın bbox'una göre genişliği hesapla, büyüğünü al.
  double get _digitWidth {
    final nW = _digitPath(timeSignature.numerator).getBounds().width;
    final dW = _digitPath(timeSignature.denominator).getBounds().width;
    return nW > dW ? nW : dW;
  }

  @override
  double get width => _digitWidth;

  // Üst ve alt rakamlar staffın üst/alt yarısında.
  // upperHeight / lowerHeight ölçüm bilgisi için staffSpace * 2 yeterli.
  @override
  double get upperHeight => Constants.staffSpace * 2;

  @override
  double get lowerHeight => Constants.staffSpace * 2;

  @override
  EdgeInsets get margin => timeSignature.margin;

  @override
  MusicalSymbolRenderer renderer(
    SheetMusicLayout layout, {
    required double staffLineCenterY,
    required double symbolX,
  }) =>
      TimeSignatureRenderer(
        this,
        staffLineCenterY: staffLineCenterY,
        symbolX: symbolX,
      );
}

class TimeSignatureRenderer implements MusicalSymbolRenderer {
  const TimeSignatureRenderer(
    this.metrics, {
    required this.staffLineCenterY,
    required this.symbolX,
  });

  final TimeSignatureMetrics metrics;
  final double staffLineCenterY;
  final double symbolX;

  Path _centeredDigitPath(int digit, double targetCenterY) {
    final raw  = metrics._digitPath(digit);
    final bbox = raw.getBounds();
    // Rakamı yatayda ortalıyoruz (her iki rakam için aynı x merkezi).
    final dx = symbolX - bbox.left + (metrics._digitWidth - bbox.width) / 2;
    // Rakamı dikey merkezine konumlandırıyoruz.
    final dy = targetCenterY - bbox.top - bbox.height / 2;
    return raw.shift(Offset(dx, dy));
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()
      ..color = metrics.timeSignature.color
      ..style = PaintingStyle.fill;

    // Numerator: staffın üst yarısının ortası
    final numY = staffLineCenterY - Constants.staffSpace;
    canvas.drawPath(_centeredDigitPath(metrics.timeSignature.numerator, numY), paint);

    // Denominator: staffın alt yarısının ortası
    final denY = staffLineCenterY + Constants.staffSpace;
    canvas.drawPath(_centeredDigitPath(metrics.timeSignature.denominator, denY), paint);
  }

  @override
  bool isHit(Offset position) => false;
}
