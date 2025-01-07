// lib/main.dart

import 'package:flutter/material.dart';
import 'package:medical_records_frontend/provider/patient_provider.dart';
import 'package:provider/provider.dart';
import 'provider/auth_provider.dart';
import 'provider/user_provider.dart';
import 'provider/doctor_provider.dart';
import 'provider/appointment_provider.dart'; // Import AppointmentProvider
import 'routes.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => PatientProvider()),

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
      routes: routes,
    );
  }
}