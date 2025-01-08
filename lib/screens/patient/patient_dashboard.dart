// lib/screens/patient/patient_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/appointment_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/patient_provider.dart';
import '../../widgets/AppointmentListWidget.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({Key? key}) : super(key: key);

  @override
  _PatientDashboardState createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  late Future<void> _fetchDataFuture;

  String get keycloakUserId => Provider.of<AuthProvider>(context, listen: false).keycloakUserId;

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = _fetchPatientData();
  }

  Future<void> _fetchPatientData() async {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    await patientProvider.fetchPatientDataViaKeycloakUserId(keycloakUserId);

    if (patientProvider.patient != null) {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      await appointmentProvider.fetchAppointmentsForPatient();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final patientProvider = Provider.of<PatientProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Dashboard for ${patientProvider.patient?.name ?? ''}'),
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
      body: FutureBuilder<void>(
        future: _fetchDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const AppointmentListWidget();
          }
        },
      ),
    );
  }
}