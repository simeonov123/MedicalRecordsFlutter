// lib/screens/patient/patient_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/patient_provider.dart';
import '../../widgets/patient_data_widget.dart';

// lib/screens/patient/patient_list_screen.dart

import '../../widgets/patient_data_widget.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({Key? key}) : super(key: key);

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  late Future<void> _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    await patientProvider.fetchPatients();
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient List'),
      ),
      body: FutureBuilder<void>(
        future: _fetchDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: patientProvider.patients.length,
              itemBuilder: (context, index) {
                final patient = patientProvider.patients[index];
                return PatientDataWidget(
                  patient: patient,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      '/patient/appointments',
                      arguments: patient.id,
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}

