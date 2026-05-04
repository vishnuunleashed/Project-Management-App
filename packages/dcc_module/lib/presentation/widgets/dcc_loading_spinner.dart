import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DccBaseLoadingSpinner extends StatelessWidget {
  final double? height;
  final double progress;
  const DccBaseLoadingSpinner({Key? key, this.height, this.progress = 0})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              elevation: 1,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              color: Theme.of(context).highlightColor,
              child: Padding(
                padding: const EdgeInsets.all(23.0),
                child: Column(
                  children: [
                    CupertinoActivityIndicator(radius: 17, color: Theme.of(context).colorScheme.primary),

                    Visibility(
                      visible: (progress * 100) > 0 && (progress * 100) < 100,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        child: Column(
                          children: [
                            const SizedBox(height: 12),
                            LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Colors.grey.shade300,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            Text("${(progress * 100).toStringAsFixed(0)}%",
                                style: Theme.of(context).textTheme.bodyLarge),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}
