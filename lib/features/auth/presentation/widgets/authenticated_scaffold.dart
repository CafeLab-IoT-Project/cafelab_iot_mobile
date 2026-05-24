import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_app_header.dart';
import 'package:cafelab_iot_mobile/features/auth/presentation/widgets/authenticated_menu_drawer.dart';
import 'package:flutter/material.dart';

class AuthenticatedScaffold extends StatefulWidget {
  const AuthenticatedScaffold({
    super.key,
    required this.body,
    required this.onFeatures,
    this.onProfile,
    this.onBeforeLogout,
  });

  final Widget body;
  final VoidCallback onFeatures;
  final VoidCallback? onProfile;
  final Future<void> Function()? onBeforeLogout;

  @override
  State<AuthenticatedScaffold> createState() => _AuthenticatedScaffoldState();
}

class _AuthenticatedScaffoldState extends State<AuthenticatedScaffold> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  void _openMenu() {
    _scaffoldKey.currentState?.openEndDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      endDrawer: AuthenticatedMenuDrawer(
        onFeatures: widget.onFeatures,
        onProfile: widget.onProfile,
        onBeforeLogout: widget.onBeforeLogout,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthenticatedAppHeader(
            onMenuPressed: _openMenu,
            onLogoPressed: widget.onFeatures,
          ),
          Expanded(child: widget.body),
        ],
      ),
    );
  }
}
