import 'package:flutter/material.dart';
import 'package:medical_records_frontend/domain/doctor.dart';
import 'package:provider/provider.dart';
import '../../domain/patient.dart';
import '../../provider/appointment_provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/patient_provider.dart';
import '../../provider/doctor_provider.dart';
import '../../widgets/AppointmentListWidget.dart';
import '../../widgets/create_appointment_widget.dart';

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
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    await patientProvider.fetchPatientDataViaKeycloakUserId(keycloakUserId);
    await doctorProvider.fetchDoctors();

    final primaryDoctor = doctorProvider.doctors.firstWhere(
          (doc) => doc.id == patientProvider.patient?.primaryDoctorId,
    );

    if (patientProvider.patient != null) {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      await appointmentProvider.fetchAppointmentsForUser();
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            // Mobile Layout
            return _buildMobileLayout();
          } else {
            // Tablet/Desktop Layout
            return _buildDesktopLayout(patientProvider);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final patientId = Provider.of<PatientProvider>(context, listen: false).patient?.id;
          if (patientId != null) {
            final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
            _showCreateAppointmentDialog(context, doctorProvider.doctors, patientId);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return FutureBuilder<void>(
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
    );
  }

  Widget _buildDesktopLayout(PatientProvider patientProvider) {
    return Row(
      children: [
        _buildPatientDetails(patientProvider.patient),
        const Expanded(child: AppointmentListWidget()),
      ],
    );
  }

  Widget _buildPatientDetails(Patient? patient) {
    if (patient == null) {
      return Container(
        width: 300,
        color: Colors.blueGrey[50],
        child: const Center(
          child: Text(
            'No patient details available',
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
            'Patient Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text('Name: ${patient.name}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('EGN: ${patient.egn}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Health Insurance Paid: ${patient.healthInsurancePaid ? "Yes" : "No"}', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text(
            'Primary Doctor ID: ${patient.primaryDoctorId ?? "Not Assigned"}',
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }

  void _showCreateAppointmentDialog(BuildContext context, List<Doctor> doctors, int patientId) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: CreateAppointmentWidget(doctors: doctors, patientId: patientId),
        );
      },
    );
  }
}
