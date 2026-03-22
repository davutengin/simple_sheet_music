import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:simple_sheet_music/src/sheet_music_metrics.dart';
import 'package:simple_sheet_music/src/staff/staff_renderer.dart';
import 'package:simple_sheet_music/src/tempo.dart';

/// Represents the layout of the sheet music.
class SheetMusicLayout {
  SheetMusicLayout(
    this.metrics,
    this.lineColor, {
    required this.widgetHeight,
    required this.widgetWidth,
    this.tempo,
  });

  /// The height of the widget.
  final double widgetHeight;

  /// The width of the widget.
  final double widgetWidth;

  /// The metrics for the sheet music.
  final SheetMusicMetrics metrics;

  /// The color of the lines in the sheet music.
  final Color lineColor;

  /// Tempo işareti (opsiyonel).
  final Tempo? tempo;

  // Tempo metni için ekran pikseli cinsinden sabit rezervasyon.
  static const double _tempoScreenPx = 44.0;

  // ─── Horizontal ────────────────────────────────────────────────────────────

  double get _maximumStaffWidth => metrics.maximumStaffWidth;
  double get _maximumStaffHorizontalMarginSum =>
      metrics.maximumStaffHorizontalMarginSum;

  double get _horizontalPadding =>
      widgetWidth -
      (_maximumStaffWidth * canvasScale + _maximumStaffHorizontalMarginSum);
  double get _horizontalPaddingOnCanvas => _horizontalPadding / canvasScale;
  double get _leftPaddingOnCanvas => _horizontalPaddingOnCanvas / 2;

  // ─── Vertical ──────────────────────────────────────────────────────────────

  /// Tempo varsa sabit bir ekran-piksel alanı ayır; yoksa sıfır.
  /// Canvas birimi = _tempoScreenPx / canvasScale  →  ekranda tam _tempoScreenPx px.
  double get _upperPaddingOnCanvas =>
      tempo != null ? _tempoScreenPx / canvasScale : 0;

  // ─── Staff renderers ───────────────────────────────────────────────────────

  List<StaffRenderer> get staffRenderers {
    var currentY = _upperPaddingOnCanvas;
    return metrics.staffsMetricses.map((staffMetrics) {
      currentY += staffMetrics.upperHeight;
      final staffRenderer = staffMetrics.renderer(
        this,
        staffLineCenterY: currentY,
        leftPadding: _leftPaddingOnCanvas,
      );
      currentY += staffMetrics.lowerHeight;
      return staffRenderer;
    }).toList();
  }

  double get _staffsHeightsSum => metrics.staffsHeightSum;

  // ─── Scale ─────────────────────────────────────────────────────────────────

  double get _widthScale =>
      (widgetWidth - _maximumStaffHorizontalMarginSum) / _maximumStaffWidth;

  /// Tempo varsa o alan çıkartılarak hesaplanır; sonsuz döngüyü önlemek için
  /// sabit ekran piksel değeri kullanılır.
  double get _heightScale =>
      tempo != null
          ? (widgetHeight - _tempoScreenPx) / _staffsHeightsSum
          : widgetHeight / _staffsHeightsSum;

  double get canvasScale => min(_widthScale, _heightScale);

  // ─── Render ────────────────────────────────────────────────────────────────

  void render(Canvas canvas, Size size) {
    if (tempo != null) _renderTempo(canvas);
    for (final staff in staffRenderers) {
      staff.render(canvas, size);
    }
  }

  void _renderTempo(Canvas canvas) {
    final t = tempo!;
    // Font boyutu canvas biriminden ekrana yansıyan efektif piksel:
    //   fontSize * canvasScale  =  _tempoScreenPx * 0.364  ≈ 16 px  (sabit)
    final fontSize = _tempoScreenPx * 0.364 / canvasScale;
    final textY    = _tempoScreenPx * 0.12 / canvasScale;

    final pb = ui.ParagraphBuilder(
      ui.ParagraphStyle(
        textDirection: ui.TextDirection.ltr,
        maxLines: 1,
      ),
    )
      ..pushStyle(ui.TextStyle(
        fontSize:   fontSize,
        color:      t.color,
        fontWeight: ui.FontWeight.w500,
      ))
      ..addText(t.displayText);

    final paragraph = pb.build()
      ..layout(ui.ParagraphConstraints(width: widgetWidth / canvasScale));

    canvas.drawParagraph(paragraph, Offset(_leftPaddingOnCanvas, textY));
  }
}
