import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../provider/auth_provider.dart';
import '../../../provider/appointment_provider.dart';
import '../../domain/doctor.dart';
import '../../provider/doctor_provider.dart';
import '../../widgets/AppointmentListWidget.dart';

class DoctorDashboard extends StatefulWidget {
  const DoctorDashboard({Key? key}) : super(key: key);

  @override
  State<DoctorDashboard> createState() => _DoctorDashboardState();
}

class _DoctorDashboardState extends State<DoctorDashboard> {
  late Future<void> _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);

    final keycloakUserId = authProvider.getUserId();
    if (keycloakUserId != null) {
      // Fetch the current doctor and all doctors
      await doctorProvider.fetchCurrentDoctor();
      await doctorProvider.fetchDoctors();

      // Fetch appointments for the current doctor
      if (doctorProvider.currentDoctor != null) {
        await appointmentProvider.fetchAppointmentsForUser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final doctorProvider = Provider.of<DoctorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
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
            return Row(
              children: [
                _buildDoctorDetails(doctorProvider.currentDoctor),
                const Expanded(child: AppointmentListWidget()),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildDoctorDetails(Doctor? doctor) {
    if (doctor == null) {
      return Container(
        width: 300,
        color: Colors.blueGrey[50],
        child: const Center(
          child: Text(
            'No doctor details available',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    return Container(
      width: 300,
      color: Colors.blueGrey[50],
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Doctor Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('Name: ${doctor.name}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Specialties: ${doctor.specialties}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Primary Care: ${doctor.primaryCare ? "Yes" : "No"}', style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
