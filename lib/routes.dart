// lib/routes.dart

import 'package:flutter/material.dart';
import 'package:medical_records_frontend/screens/admin/statistics_screen.dart';
import 'package:medical_records_frontend/screens/doctor/doctor_dashboard.dart';
import 'package:medical_records_frontend/screens/doctor/doctor_list_screen.dart';
import 'package:medical_records_frontend/screens/patient/patient_list_screen.dart';
// Removed import for AppointmentListWidget because we won't define its route here
import 'package:provider/provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/admin/user_management_panel.dart';
import 'screens/patient/patient_dashboard.dart';
import 'provider/auth_provider.dart';

/// Standard named routes, minus '/patient/appointments' which we handle in onGenerateRoute
final Map<String, WidgetBuilder> routes = {
  '/': (context) => const LoginScreen(),
  '/signup': (context) => const SignupScreen(),
  '/admin/user-management': (context) => const RoleGuard(
    allowedRoles: ['admin'],
    child: UserManagementPanel(),
  ),
  '/doctor/dashboard': (context) => const RoleGuard(
    allowedRoles: ['admin', 'doctor'],
    child: DoctorDashboard(),
  ),
  '/patient/dashboard': (context) => const RoleGuard(
    allowedRoles: ['admin', 'doctor', 'patient'],
    child: PatientDashboard(),
  ),
  '/doctor/list': (context) => const RoleGuard(
    allowedRoles: ['admin', 'doctor'],
    child: DoctorListScreen(),
  ),
  '/patient/list': (context) => const RoleGuard(
    allowedRoles: ['admin', 'doctor'],
    child: PatientListScreen(),
  ),
  '/statistics': (context) => const RoleGuard(
    allowedRoles: ['admin'],
    child: StatisticsScreen(),
  ),

  //  !!! Removed the /patient/appointments route definition !!!
  //  '/patient/appointments': (context) { ... } <-- no longer needed
};

class RoleGuard extends StatelessWidget {
  final List<String> allowedRoles;
  final Widget child;

  const RoleGuard({
    Key? key,
    required this.allowedRoles,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    if (!authProvider.isAuthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/');
      });
      return const SizedBox.shrink();
    }

    bool hasAccess = authProvider.roles.any((role) => allowedRoles.contains(role));
    if (!hasAccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Access Denied')),
        );
        Navigator.pushReplacementNamed(context, '/');
      });
      return const SizedBox.shrink();
    }

    return child;
  }
}
