import 'dart:math' as math;
import 'package:flutter/material.dart';

/// responsive utility for adjusting UI sizes, padding, and fonts across various device screens.
class Responsive {
  static double _screenWidth = 390;
  static double _screenHeight = 844;
  static double _pixelRatio = 1.0;
  static bool _initialized = false;

  static const double baseWidth = 390; // Base width (iPhone 14)
  static const double baseHeight = 844; // Base height (iPhone 14)

  /// Initialize responsiveness with MediaQuery data
  static void init(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    _screenWidth = mediaQuery.size.width;
    _screenHeight = mediaQuery.size.height;
    _pixelRatio = mediaQuery.devicePixelRatio;
    _initialized = true;
  }

  static double get width => _screenWidth;
  static double get height => _screenHeight;
  static double get pixelRatio => _pixelRatio;
  static bool get isSmall => _screenWidth < 375;
  static bool get isTablet => _screenWidth >= 768;

  /// Linear scale for width-related sizes
  static double scale(double size) {
    return (_screenWidth / baseWidth) * size;
  }

  /// Scale for fonts with upper/lower bounds (max 30% larger, min 15% smaller)
  static double fontScale(double size) {
    final double scaled = scale(size);
    final double maxScale = size * 1.3;
    final double minScale = size * 0.85;
    return math.min(math.max(scaled, minScale), maxScale);
  }

  /// Vertical scale for padding/margin
  static double vertScale(double size) {
    return (_screenHeight / baseHeight) * size;
  }

  /// Clamp function to prevent extreme values
  static double clamp(double value, double min, double max) {
    return math.min(math.max(value, min), max);
  }
}

/// Extension on BuildContext for quick responsive access
extension ResponsiveContext on BuildContext {
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  double get paddingBottom => MediaQuery.of(this).padding.bottom;
  double get paddingTop => MediaQuery.of(this).padding.top;
  double get paddingLeft => MediaQuery.of(this).padding.left;
  double get paddingRight => MediaQuery.of(this).padding.right;

  double get scaleWidth => screenWidth / Responsive.baseWidth;
  double get scaleHeight => screenHeight / Responsive.baseHeight;

  double scale(double size) => scaleWidth * size;
  double vertScale(double size) => scaleHeight * size;
  double fontScale(double size) {
    final double scaled = scale(size);
    return math.min(math.max(scaled, size * 0.85), size * 1.3);
  }
}

/// Extension on num for quick inline sizing (e.g. 16.w, 24.h, 14.sp)
extension ResponsiveNum on num {
  double get w => Responsive.scale(toDouble());
  double get h => Responsive.vertScale(toDouble());
  static double get sp => 0; // dummy for compilation
}

extension ResponsiveDouble on double {
  double get w => Responsive.scale(this);
  double get h => Responsive.vertScale(this);
  double get sp => Responsive.fontScale(this);
}

extension ResponsiveInt on int {
  double get w => Responsive.scale(toDouble());
  double get h => Responsive.vertScale(toDouble());
  double get sp => Responsive.fontScale(toDouble());
}
