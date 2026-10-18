import 'package:flutter/widgets.dart';

/// Helpers for sizing UI relative to the window instead of fixed dp values.
///
/// Design values are drawn for a ~390dp wide phone. [uiScale] stretches or
/// shrinks them for small phones, large phones and tablets (the app caps its
/// content width, so the MediaQuery size seen here is the capped one).
extension ResponsiveContext on BuildContext {
  Size get screenSize => MediaQuery.sizeOf(this);

  double get uiScale =>
      (screenSize.shortestSide / 390).clamp(0.8, 1.25).toDouble();

  /// Scales a design-time size to the current window.
  double scaled(double value) => value * uiScale;

  bool get isLandscape =>
      MediaQuery.orientationOf(this) == Orientation.landscape;

  /// True when vertical room is tight (landscape phones, split screen).
  bool get isShort => screenSize.height < 520;
}
