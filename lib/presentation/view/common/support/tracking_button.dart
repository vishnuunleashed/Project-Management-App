import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';

class ForwardAnimatedIcon extends StatefulWidget {
  final double size;
  const ForwardAnimatedIcon({super.key, this.size = 18});

  @override
  State<ForwardAnimatedIcon> createState() => _ForwardAnimatedIconState();
}

class _ForwardAnimatedIconState extends State<ForwardAnimatedIcon>{






  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          'Track',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Colors.white,
          ),
        ),
        SizedBox(width: 4,),
        Icon(
          Icons.travel_explore,
          size: widget.size,
          color: bayaInfraBlue600,
        ),
      ],
    );
  }
}
