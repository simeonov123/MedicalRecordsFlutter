import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/doctor.dart';
import '../../provider/patient_provider.dart';
import '../../provider/doctor_provider.dart';
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
    _fetchDataFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    await Future.wait([
      patientProvider.fetchPatients(),
      doctorProvider.fetchDoctors(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final patientProvider = Provider.of<PatientProvider>(context);
    final doctorProvider = Provider.of<DoctorProvider>(context);

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
            final patients = patientProvider.patients;

            if (patients.isEmpty) {
              return const Center(
                child: Text('No patients available.'),
              );
            }

            return LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.of(context).size.width;
                final isWideScreen = screenWidth > 600;

                // Calculate column count dynamically
                final columnCount = isWideScreen
                    ? (screenWidth ~/ 300).clamp(2, 4) // Min 2, Max 4
                    : 1;

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1200, // Maximum width for grid layout
                    ),
                    child: GridView.builder(
                      padding: const EdgeInsets.all(16.0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columnCount,
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                        childAspectRatio: isWideScreen ? 1.5   : 2.3, // Adjust card ratio
                      ),
                      itemCount: patients.length,
                      itemBuilder: (context, index) {
                        final patient = patients[index];
                        final doctor = doctorProvider.doctors.firstWhere(
                              (d) => d.id == patient.primaryDoctorId,
                          orElse: () => Doctor(
                            id: 0,
                            keycloakUserId: '',
                            name: 'N/A',
                            specialties: 'N/A',
                            primaryCare: false,
                          ),
                        );

                        return PatientDataWidget(
                          patient: patient,
                          primaryDoctorName: doctor.name,
                          primaryDoctorSpecialties: doctor.specialties,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              '/patient/appointments',
                              arguments: patient.id,
                            );
                          },
                        );
                      },
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
