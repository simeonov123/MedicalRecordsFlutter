// lib/main.dart

import 'package:flutter/material.dart';
import 'package:medical_records_frontend/provider/medication_provider.dart';
import 'package:medical_records_frontend/provider/statistics_provider.dart';
import 'package:medical_records_frontend/widgets/AppointmentListWidget.dart';
import 'package:provider/provider.dart';

import 'provider/auth_provider.dart';
import 'provider/user_provider.dart';
import 'provider/doctor_provider.dart';
import 'provider/appointment_provider.dart';
import 'provider/patient_provider.dart';

import 'routes.dart'; // We'll still import the routes map for everything except '/patient/appointments'

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),
        ChangeNotifierProvider(create: (_) => MedicationProvider()),
        ChangeNotifierProvider(create: (_) => StatisticsProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medical Records',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      // We'll still use your existing routes map for all but '/patient/appointments'
      routes: routes,
      navigatorObservers: [routeObserver],

      // 1) Use onGenerateRoute to handle '/patient/appointments' with a custom fade route
      onGenerateRoute: (settings) {
        if (settings.name == '/patient/appointments') {
          final patientId = settings.arguments as int?;

          // Return a custom PageRouteBuilder to do a fade transition
          return PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) {
              // Wrap your RoleGuard + AppointmentListWidget in here:
              return RoleGuard(
                allowedRoles: ['admin', 'doctor'],
                child: AppointmentListWidget(
                  fromDoctorOrAdmin: true,
                  patientId: patientId,
                ),
              );
            },
            // 2) Provide a custom fade transition
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            // 3) Adjust the transition duration as desired
            transitionDuration: const Duration(milliseconds: 10),

            // 4) Make sure we don't see a dim background
            opaque: true,
            barrierDismissible: false,
          );
        }

        // If it's not '/patient/appointments', return null so Flutter uses the normal route
        return null;
      },
    );
  }
}
