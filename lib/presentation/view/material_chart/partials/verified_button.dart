// Verified Badge Widget
import 'package:base/presentation/theme_config.dart';
import 'package:flutter/material.dart';

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 10.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [bayaInfraGreen, bayaInfraPaleGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified,
            color: Colors.white,
            size: 16.0,
          ),
          SizedBox(width: 10.0),
          Text(
            'Verified',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}