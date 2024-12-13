// lib/screens/doctor/doctor_dashboard.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/doctor_provider.dart';
import '../../domain/doctor.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({Key? key}) : super(key: key);

  @override
  _DoctorDashboardState createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  @override
  void initState() {
    super.initState();
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    doctorProvider.fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    final doctorProvider = Provider.of<DoctorProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: doctorProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : doctorProvider.error != null
            ? Center(child: Text('Error: ${doctorProvider.error}'))
            : ListView.builder(
          itemCount: doctorProvider.doctors.length,
          itemBuilder: (context, index) {
            Doctor doctor = doctorProvider.doctors[index];
            return ListTile(
              title: Text(doctor.name),
              subtitle: Text('Specialties: ${doctor.specialties}'),
              trailing: doctor.primaryCare
                  ? const Icon(Icons.star, color: Colors.yellow)
                  : null,
            );
          },
        ),
      ),
      // TODO: Add more widgets and functionality as needed
    );
  }
}
