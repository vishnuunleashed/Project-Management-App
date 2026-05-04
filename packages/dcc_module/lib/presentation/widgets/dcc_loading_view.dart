import 'package:dcc_module/presentation/widgets/dcc_loading_spinner.dart';
import 'package:flutter/material.dart';

class DccBaseLoadingView extends StatelessWidget {
  final String? message;
  final TextStyle? style;
  final double progress;

  const DccBaseLoadingView({Key? key, this.message, this.style, this.progress = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 56),
        Expanded(
          child: Container(
            color: Colors.transparent,
            child: Center(
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    DccBaseLoadingSpinner(progress: progress),
                  ]),
            ),
          ),
        ),
      ],
    );
  }
}
