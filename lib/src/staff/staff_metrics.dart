import 'package:simple_sheet_music/src/extension/list_extension.dart';
import 'package:simple_sheet_music/src/measure/measure_metrics.dart';
import 'package:simple_sheet_music/src/measure/measure_renderer.dart';
import 'package:simple_sheet_music/src/sheet_music_layout.dart';
import 'package:simple_sheet_music/src/staff/staff_renderer.dart';

/// Represents the metrics of a staff, including the metrics of its measures.
class StaffMetrics {
  const StaffMetrics(this.measuresMetricses);

  /// The list of measure metrics for each measure in the staff.
  final List<MeasureMetrics> measuresMetricses;

  /// The height of the upper part of the staff.
  double get upperHeight =>
      measuresMetricses.map((measure) => measure.upperHeight).max;

  /// The height of the lower part of the staff.
  double get lowerHeight =>
      measuresMetricses.map((measure) => measure.lowerHeight).max;

  /// The total width of the staff, including the width of its objects and margins.
  double get width => _objectsWidth + horizontalMarginSum;

  /// The total width of the objects in the staff.
  double get _objectsWidth =>
      measuresMetricses.map((measure) => measure.objectsWidth).sum;

  /// The sum of the horizontal margins between measures in the staff.
  double get horizontalMarginSum =>
      measuresMetricses.map((measure) => measure.horizontalMarginSum).sum;

  /// The total height of the staff.
  double get height => upperHeight + lowerHeight;

  /// Creates a [StaffRenderer] with the given layout and rendering parameters.
  StaffRenderer renderer(
    SheetMusicLayout layout, {
    required double staffLineCenterY,
    required double leftPadding,
    double? availableWidth,
  }) {
    final n = measuresMetricses.length;

    // First pass: compute each measure's natural width.
    final widths = <double>[];
    for (final measure in measuresMetricses) {
      final m = measure.renderer(
        layout,
        measureInitialX: 0,
        staffLineCenterY: staffLineCenterY,
      );
      widths.add(m.width);
    }

    // Compute equal gap between measures so they fill availableWidth.
    double gap = 0;
    if (availableWidth != null && n > 1) {
      final totalW = widths.fold<double>(0.0, (s, w) => s + w);
      gap = ((availableWidth - totalW) / (n - 1)).clamp(0.0, double.infinity) + 80.0;
    }

    // Second pass: place measures with gap.
    var currentX = leftPadding;
    final measureRendereres = <MeasureRenderer>[];
    for (int i = 0; i < n; i++) {
      final m = measuresMetricses[i].renderer(
        layout,
        measureInitialX: currentX,
        staffLineCenterY: staffLineCenterY,
      );
      measureRendereres.add(m);
      currentX += widths[i] + (i < n - 1 ? gap : 0);
    }

    return StaffRenderer(measureRendereres);
  }
}
