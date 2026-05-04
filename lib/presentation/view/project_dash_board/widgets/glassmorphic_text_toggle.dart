import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

class GlassmorphicSegmentedButton extends StatelessWidget {
  final String selectedLabel;
  final List<String> labels;
  final Function(String) onSelected;
  final Color glassColor;
  final Color? accentColor;
  final TextStyle? labelStyle;


  const GlassmorphicSegmentedButton({
    Key? key,
    required this.selectedLabel,
    required this.labels,
    required this.onSelected,
    this.labelStyle,
    this.glassColor = const Color(0xFFFFFFFF),
    this.accentColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 4),
      child: ClipRRect(

        borderRadius: BorderRadius.circular(14),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32.0), // Optional: adds rounded corners
            side: BorderSide(
              color: Theme.of(context).primaryColor, // The border color
              width: 1.5,        // The border width
            ),
          ),
           color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Row(
              children: List.generate(
                labels.length,
                    (index) => Expanded(
                  child: GestureDetector(
                    onTap: () => onSelected(labels[index]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(32),
                        color: selectedLabel == labels[index]
                            ? accentColor ?? Theme.of(context).primaryColor
                            : Colors.transparent,
                      ),
                      child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                          letterSpacing: 0.5,
                          color: selectedLabel == labels[index]
                              ? Colors.white
                              : Theme.of(context).textTheme.labelLarge?.color,
                        ) ??
                            TextStyle(
                              fontSize: 9,
                              letterSpacing: 0.5,
                              color: selectedLabel == labels[index]
                                  ? Colors.white
                                  : Theme.of(context).textTheme.labelLarge?.color,
                            ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 8,
                            ),
                            child: Text(labels[index],style: labelStyle,),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

