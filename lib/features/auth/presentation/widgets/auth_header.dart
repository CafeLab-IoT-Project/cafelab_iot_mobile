import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_assets.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: AuthColors.header,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            AuthAssets.logo,
            height: 44,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
