// lib/widgets/role_based_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

class RoleBasedWidget extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;

  const RoleBasedWidget({
    Key? key,
    required this.allowedRoles,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    bool hasAccess = authProvider.roles.any((role) => allowedRoles.contains(role));

    return hasAccess ? child : const SizedBox.shrink();
  }
}
