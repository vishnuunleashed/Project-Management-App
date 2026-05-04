

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:interior_design/presentation/view/common/expandable_text/src/core/helpers/text_span_helper.dart';
import 'package:interior_design/presentation/view/common/expandable_text/src/data/models/settings.dart';


class RichReadMoreText extends StatefulWidget {
  /// A widget that displays text with an option to show more or show less based on the provided settings.
  ///
  /// The `RichReadMoreText` widget allows you to trim text either based on the character length or the number of lines.
  /// When the text is longer than the specified trim length or exceeds the maximum number of lines, it provides a
  /// toggle option to show more or show less of the text.
  /// If you want to pass a [String] instead of TextSpan, take a look at the `RichReadMoreText.fromString()` constructor.
  ///
  /// Example usage:
  /// ```dart
  ///  RichReadMoreText(
  ///    textSpan,
  ///    settings: LineModeSettings(
  ///      trimLines: 3,
  ///      trimCollapsedText: 'Expand',
  ///      trimExpandedText: ' Collapse ',
  ///      onPressReadMore: () {
  ///       //specific method to be called on press to show more
  ///      },
  ///      onPressReadLess: () {
  ///        // specific method to be called on press to show less
  ///      },
  ///    ),
  ///  ),
  /// ```
  const RichReadMoreText(
    this.data, {
    Key? key,
    required this.settings,
  }) : super(key: key);

  /// A widget that displays text with an option to show more or show less based on the provided settings.
  ///
  /// The `RichReadMoreText` widget allows you to trim text either based on the character length or the number of lines.
  /// When the text is longer than the specified trim length or exceeds the maximum number of lines, it provides a
  /// toggle option to show more or show less of the text.
  ///
  /// [text] is the text that will be displayed
  ///
  /// [textStyle] is the style for the [text]
  /// Example usage:
  /// ```dart
  ///  RichReadMoreText.fromString(
  ///    text: 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
  ///    textStyle: TextStyle(color: Colors.purpleAccent),
  ///    settings: LengthModeSettings(
  ///      trimLength: 20,
  ///      trimCollapsedText: '...Show more',
  ///      trimExpandedText: ' Show less',
  ///      lessStyle: TextStyle(color: Colors.blue),
  ///      moreStyle: TextStyle(color: Colors.blue),
  ///    ),
  ///  ),
  /// ```
  RichReadMoreText.fromString({
    Key? key,
    required String text,
    TextStyle? textStyle,
    required this.settings,
  }) : data = TextSpan(text: text, style: textStyle);

  /// The settings to control the trimming behavior.
  /// Can accept two different types, [LineModeSettings] or [LengthModeSettings]
  /// * Use [LineModeSettings] for trimming with a specific line number
  /// * Use [LengthModeSettings] for trimming with a specific character length
  final ReadMoreSettings settings;

  ///  The text to be displayed
  final TextSpan data;

  @override
  _RichReadMoreTextState createState() => _RichReadMoreTextState();
}

class _RichReadMoreTextState extends State<RichReadMoreText> {
  bool _readMore = true;

  /// The alignment for the text
  ///
  /// Is set to `TextAlign.start` if the [settings.textAlign] is null
  late final TextAlign textAlign;

  /// The string for say if the actions is expand or collapse
  late TextSpan actionText;

  /// The helper class that contains the methods for managing the textSpans
  late final TextSpanHelper textSpanHelper;

  /// A getter for the [TextScaler] to be used for the text.
  /// If the [settings.textScaler] is null, it will use the
  /// `MediaQuery.textScalerOf(context)`.
  TextScaler get textScaler =>
      widget.settings.textScaler ?? MediaQuery.textScalerOf(context);

  @override
  void initState() {
    super.initState();
    textAlign = widget.settings.textAlign ?? TextAlign.start;
    textSpanHelper = TextSpanHelper();
    actionText = textSpanHelper.updateActionText(
        isExpanded: _readMore, onTap: _onTapLink, settings: widget.settings);
  }

  void _onTapLink() {
    setState(() {
      _readMore = !_readMore;
      if (_readMore) {
        widget.settings.onPressReadLess?.call();
      } else {
        widget.settings.onPressReadMore?.call();
      }
    });
  }

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
    actionText = textSpanHelper.updateActionText(
        isExpanded: _readMore, onTap: _onTapLink, settings: widget.settings);
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      textDirection: widget.settings.textDirection,
      label: widget.settings.semanticsLabel,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            assert(constraints.hasBoundedWidth);

            final double maxWidth = constraints.maxWidth;

            // Layout and measure link
            TextPainter textPainter = TextPainter(
              text: actionText,
              textAlign: textAlign,
              textDirection: widget.settings.textDirection ?? TextDirection.rtl,
              textScaler: textScaler,
              maxLines: widget.settings is LineModeSettings
                  ? (widget.settings as LineModeSettings).trimLines
                  : null,
              locale: widget.settings.locale,
            );
            textPainter.layout(minWidth: 0, maxWidth: maxWidth);
            final actionTextSize = textPainter.size;

            // Layout and measure text
            textPainter.text = widget.data;
            textPainter.layout(
                minWidth: constraints.minWidth, maxWidth: maxWidth);
            final textSize = textPainter.size;

            int endIndex;

            if (widget.settings is LengthModeSettings) {
              endIndex = (widget.settings as LengthModeSettings).trimLength - 1;
            } else if (actionTextSize.width < maxWidth) {
              final readMoreSize = actionTextSize.width;
              final pos = textPainter.getPositionForOffset(Offset(
                widget.settings.textDirection == TextDirection.rtl
                    ? readMoreSize
                    : textSize.width - readMoreSize,
                textSize.height,
              ));
              endIndex = textPainter.getOffsetBefore(pos.offset) ?? 0;
            } else {
              var pos = textPainter.getPositionForOffset(
                textSize.bottomLeft(Offset.zero),
              );
              endIndex = pos.offset;
            }

            var textSpan = textSpanHelper.getTextSpanForTrimMode(
              data: widget.data,
              settings: widget.settings,
              isExpanded: _readMore,
              actionText: actionText,
              didExceedMaxLines: textPainter.didExceedMaxLines,
              endIndex: endIndex,
            );

            return SelectableText.rich(
              textSpan,
              textAlign: textAlign,
              textDirection: widget.settings.textDirection,
              scrollPhysics: NeverScrollableScrollPhysics(),
              textScaler: textScaler,
              enableInteractiveSelection: true, // Ensure this is true
              selectionControls: Platform.isIOS
                  ? CupertinoTextSelectionControls()
                  : MaterialTextSelectionControls(),
            );
          },
        ),
      ),
    );
  }
}
