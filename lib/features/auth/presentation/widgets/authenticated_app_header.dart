import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_assets.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/constants/auth_colors.dart';
import 'package:flutter/material.dart';

class AuthenticatedAppHeader extends StatelessWidget {
  const AuthenticatedAppHeader({
    super.key,
    required this.onMenuPressed,
    this.onLogoPressed,
  });

  final VoidCallback onMenuPressed;
  final VoidCallback? onLogoPressed;

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.paddingOf(context).top;

    final logo = Image.asset(
      AuthAssets.logo,
      height: 44,
      fit: BoxFit.contain,
    );

    return ColoredBox(
      color: AuthColors.header,
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, topPadding + 10, 4, 12),
        child: Row(
          children: [
            if (onLogoPressed != null)
              InkWell(
                onTap: onLogoPressed,
                borderRadius: BorderRadius.circular(24),
                child: logo,
              )
            else
              logo,
            const Spacer(),
            IconButton(
              onPressed: onMenuPressed,
              icon: const Icon(
                Icons.menu,
                color: Colors.black87,
                size: 28,
              ),
              tooltip: 'Menú',
            ),
          ],
        ),
      ),
    );
  }
}
