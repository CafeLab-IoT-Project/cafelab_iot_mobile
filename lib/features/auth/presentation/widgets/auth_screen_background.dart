import 'dart:ui';

import 'package:flutter/material.dart';

class AuthScreenBackground extends StatelessWidget {
  const AuthScreenBackground({
    super.key,
    required this.backgroundAsset,
    required this.child,
  });

  final String backgroundAsset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: Image.asset(
              backgroundAsset,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
            ),
          ),
        ),
        Positioned.fill(
          child: ColoredBox(
            color: Colors.black.withValues(alpha: 0.08),
          ),
        ),
        child,
      ],
    );
  }
}
