import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/presentation/view/common/expandable_text/src/core/extensions/text_span_extensions.dart';
import 'package:interior_design/presentation/view/common/expandable_text/src/data/models/settings.dart';
import 'package:interior_design/presentation/view/common/expandable_text/src/data/models/trim_modes.dart';


class TextSpanHelper {
  /// A helper class for managing [TextSpan] objects.
  ///
  /// This class provides methods for substring and build a text span adding the [actionText] for that, the necessary methods for trimming.
  TextSpanHelper();

  /// Returns a [TextSpan] adding the [actionText] on the children
  TextSpan buildTextSpan(
          {required TextSpan span, required TextSpan actionText}) =>
      TextSpan(children: [
        span,
        actionText,
      ]);

  /// Returns a treated TextSpan depending on the [TrimMode] provided.
  TextSpan getTextSpanForTrimMode(
      {required TextSpan data,
      required ReadMoreSettings settings,
      required bool isExpanded,
      required TextSpan actionText,
      required bool didExceedMaxLines,
      required int endIndex}) {
    switch (settings.trimMode) {
      case TrimMode.length:
        final LengthModeSettings lengthSettings =
            settings as LengthModeSettings;
        if (lengthSettings.trimLength < data.toPlainText().length) {
          final textSpan = isExpanded ? data.substring(0, endIndex) : data;
          return buildTextSpan(span: textSpan, actionText: actionText);
        } else {
          return data;
        }
      case TrimMode.line:
        if (didExceedMaxLines) {
          final textSpan = isExpanded ? data.substring(0, endIndex) : data;
          return buildTextSpan(span: textSpan, actionText: actionText);
        } else {
          return data;
        }
    }
  }

  /// Updates the [actionText] depending on the [isExpanded] value
  TextSpan updateActionText(
          {required ReadMoreSettings settings,
          required bool isExpanded,
          required VoidCallback onTap}) =>
      TextSpan(
        text: ' ' +
            (isExpanded
                ? settings.trimCollapsedText
                : settings.trimExpandedText),
        style: isExpanded ? settings.moreStyle : settings.lessStyle,
        recognizer: TapGestureRecognizer()..onTap = onTap,
      );
}
