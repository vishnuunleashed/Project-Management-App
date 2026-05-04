import 'dart:math';

import 'package:flutter/material.dart';

extension TextSpanExtension on TextSpan {
  TextSpan substring(int start, int end) {
    final substringSpan = <TextSpan>[];
    int lengthCount = 0;

    visitChildren((span) {
      if (lengthCount > end) return false;

      final missingCount = end - lengthCount;
      if (span is TextSpan) {
        substringSpan.add(
          TextSpan(
            text: span.text
                ?.substring(0, min(missingCount, span.text?.length ?? 0)),
            style: span.style,
          ),
        );
        lengthCount += span.text?.length ?? 0;
      }

      return true;
    });

    return TextSpan(children: substringSpan, style: style);
  }
}
