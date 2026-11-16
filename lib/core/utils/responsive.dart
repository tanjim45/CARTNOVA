
import 'package:flutter/material.dart';

class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 600;
  static const double tablet = 1024;
  static const double desktop = 1440;
}

class Responsive {
  Responsive._();

  static double width(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }

  static bool isMobile(BuildContext context) {
    return width(context) < AppBreakpoints.mobile;
  }

  static bool isTablet(BuildContext context) {
    final screenWidth = width(context);

    return screenWidth >= AppBreakpoints.mobile &&
        screenWidth < AppBreakpoints.tablet;
  }

  static bool isDesktop(BuildContext context) {
    return width(context) >= AppBreakpoints.tablet;
  }

  static int gridColumns(BuildContext context) {
    final screenWidth = width(context);

    if (screenWidth < AppBreakpoints.mobile) return 2;
    if (screenWidth < AppBreakpoints.tablet) return 3;
    if (screenWidth < AppBreakpoints.desktop) return 4;

    return 5;
  }

  static double horizontalPadding(BuildContext context) {
    final screenWidth = width(context);

    if (screenWidth < AppBreakpoints.mobile) return 16;
    if (screenWidth < AppBreakpoints.tablet) return 24;

    return 40;
  }

  static double contentMaxWidth(BuildContext context) {
    if (isDesktop(context)) return 1440;

    return double.infinity;
  }
}
