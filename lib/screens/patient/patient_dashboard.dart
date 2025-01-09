import 'package:flutter/material.dart';
import 'package:medical_records_frontend/domain/doctor.dart';
import 'package:provider/provider.dart';
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

    if (patientProvider.patient != null) {
      final appointmentProvider = Provider.of<AppointmentProvider>(context, listen: false);
      await appointmentProvider.fetchAppointmentsForUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final patientProvider = Provider.of<PatientProvider>(context);
    final doctorProvider = Provider.of<DoctorProvider>(context);

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
            return _buildDesktopLayout();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final patientId = Provider.of<PatientProvider>(context, listen: false).patient?.id;
          if (patientId != null) {
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

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.blueGrey[50],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person, size: 100, color: Colors.blueGrey),
                SizedBox(height: 16),
                Text(
                  'Patient Details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: FutureBuilder<void>(
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
        ),
      ],
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