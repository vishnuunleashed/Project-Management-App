import 'package:flutter/material.dart';
import 'package:interior_design/presentation/view/common/expandable_text/src/data/models/trim_modes.dart';


abstract class ReadMoreSettings {
  /// The [TrimMode] to be used for trimming the text.
  final TrimMode trimMode;

  /// The text to be displayed when the text is `expanded`.
  final String trimExpandedText;

  /// The text to be displayed when the text is `collapsed`.
  final String trimCollapsedText;

  /// The [TextAlign] to be used for the text.
  final TextAlign? textAlign;

  /// The [TextDirection] to be used for the text.
  final TextDirection? textDirection;

  /// The [Locale] to be used for the text.
  final Locale? locale;

  /// The [TextScaler] to be used for the text.
  final TextScaler? textScaler;

  /// The semantics label to be used for accessibility purposes.
  final String? semanticsLabel;

  /// TextStyle for expanded text.
  final TextStyle? moreStyle;

  /// TextStyle for compressed text.
  final TextStyle? lessStyle;

  /// Callback to be called on press to read more.
  final VoidCallback? onPressReadMore;

  /// Callback to be called on press to read less.
  final VoidCallback? onPressReadLess;

  ReadMoreSettings({
    required this.trimMode,
    this.trimExpandedText = 'show less',
    this.trimCollapsedText = 'read more',
    this.textAlign,
    this.textDirection,
    this.locale,
    this.textScaler,
    this.semanticsLabel,
    this.moreStyle,
    this.lessStyle,
    this.onPressReadMore,
    this.onPressReadLess,
  });
}

class LineModeSettings extends ReadMoreSettings {
  final int trimLines;

  /// Settings for trim using line numbers
  LineModeSettings(
      {required this.trimLines,
      super.trimExpandedText,
      super.trimCollapsedText,
      super.textAlign,
      super.textDirection,
      super.locale,
      super.textScaler,
      super.semanticsLabel,
      super.moreStyle,
      super.lessStyle,
      super.onPressReadMore,
      super.onPressReadLess})
      : super(trimMode: TrimMode.line);
}

class LengthModeSettings extends ReadMoreSettings {
  final int trimLength;

  /// Settings form trim using characters length
  LengthModeSettings(
      {required this.trimLength,
      super.trimExpandedText,
      super.trimCollapsedText,
      super.textAlign,
      super.textDirection,
      super.locale,
      super.textScaler,
      super.semanticsLabel,
      super.moreStyle,
      super.lessStyle,
      super.onPressReadMore,
      super.onPressReadLess})
      : super(trimMode: TrimMode.length);
}
