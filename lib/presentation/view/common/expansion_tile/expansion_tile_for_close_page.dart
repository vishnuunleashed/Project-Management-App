import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:interior_design/presentation/view/common/expandable_text/src/data/models/settings.dart';
import 'package:interior_design/presentation/view/common/expandable_text/src/presentation/rich_readmore.dart';


class CustomExpandableCard extends StatelessWidget {
  final String title;
  final String content;
  final int trimLength;
  final double minHeightFactor; // e.g. 0.28
  final double borderRadius;
  final bool showCopyButton;
  final EdgeInsetsGeometry? padding;
  final TextStyle? titleStyle;
  final TextStyle? contentStyle;
  final String readMoreText;
  final String readLessText;

  const CustomExpandableCard({
    super.key,
    required this.title,
    required this.content,
    this.trimLength = 500,
    this.minHeightFactor = 0.28,
    this.borderRadius = 10,
    this.showCopyButton = true,
    this.padding,
    this.titleStyle,
    this.contentStyle,
    this.readMoreText = 'Read more',
    this.readLessText = 'Show less',
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0.5,
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 12.0, bottom: 16),
                  child: Text(
                    title,
                    style: titleStyle ??
                        Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const Spacer(),
                if (showCopyButton)
                  IconButton(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: content));
                      if (Platform.isIOS) {
                        // Replace with your snackbar/toast implementation
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Copied to clipboard")),
                        );
                      }
                    },
                    icon: Icon(
                      Icons.copy,
                      size: 20,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
              ],
            ),
          ),

          // Content
          LayoutBuilder(
            builder: (context, constraints) {
              double screenHeight = MediaQuery.of(context).size.height;
              double minContentHeight = screenHeight * minHeightFactor;

              return ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: minContentHeight,
                  maxHeight: double.infinity,
                ),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    border: Border(
                      top: BorderSide(
                        width: 0.3,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(borderRadius),
                      bottomLeft: Radius.circular(borderRadius),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: RichReadMoreText.fromString(
                      text: content.trim(),
                      textStyle: contentStyle ??
                          Theme.of(context).textTheme.titleMedium,
                      settings: LengthModeSettings(
                        trimLength: trimLength,
                        textAlign: TextAlign.justify,
                        trimCollapsedText: readMoreText,
                        trimExpandedText: readLessText,
                        moreStyle: TextStyle(
                          color: Theme.of(context).primaryColor,

                        ),
                        lessStyle: TextStyle(
                          color: Theme.of(context).primaryColor,

                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
