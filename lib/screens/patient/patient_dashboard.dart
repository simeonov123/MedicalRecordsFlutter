// lib/screens/patient/patient_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';

class PatientDashboard extends StatelessWidget {
  const PatientDashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          'Welcome, Patient!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
      // TODO: Add more widgets and functionality as needed
    );
  }
}
