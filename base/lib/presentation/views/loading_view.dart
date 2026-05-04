
import 'package:base/presentation/views/base_loading_spinner.dart';
import 'package:flutter/material.dart';

class BaseLoadingView extends StatelessWidget {
  final String? message;
  final TextStyle? style;
  final double progress;

  const BaseLoadingView({Key? key, this.message, this.style,this.progress = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 56,),
        Expanded(
          child: Container(
            color:Colors.transparent,
            child: Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    BaseLoadingSpinner(progress: progress),
                  ]),
            ),
          ),
        ),
      ],
    );
  }
}
