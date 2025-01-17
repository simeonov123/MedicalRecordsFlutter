// lib/widgets/patients_by_doctor.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/statistics_provider.dart';
import '../provider/doctor_provider.dart';
import '../domain/doctor.dart';
import '../domain/patient.dart';

class PatientsByDoctor extends StatefulWidget {
  const PatientsByDoctor({Key? key}) : super(key: key);

  @override
  _PatientsByDoctorState createState() => _PatientsByDoctorState();
}

class _PatientsByDoctorState extends State<PatientsByDoctor> {
  late Future<void> _fetchFuture;
  Doctor? _selectedDoctor;

  @override
  void initState() {
    super.initState();
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    if (doctorProvider.doctors.isEmpty) {
      _fetchFuture = doctorProvider.fetchDoctors();
    } else {
      _fetchFuture = Future.value();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<StatisticsProvider, DoctorProvider>(
      builder: (context, statsProvider, doctorProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Search Patients by Doctor',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Doctor dropdown
              DropdownButton<Doctor>(
                isExpanded: true,
                value: _selectedDoctor,
                hint: const Text('Select Doctor'),
                items: doctorProvider.doctors.map((doctor) {
                  return DropdownMenuItem<Doctor>(
                    value: doctor,
                    child: Text(doctor.name),
                  );
                }).toList(),
                onChanged: (newDoctor) {
                  setState(() {
                    _selectedDoctor = newDoctor;
                    if (newDoctor != null) {
                      statsProvider.fetchPatientsByDoctorId(newDoctor.id);
                    }
                  });
                },
              ),
              const SizedBox(height: 16),

              // A fixed or max-size box for the patients list
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: statsProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : statsProvider.patientsByDoctor.isEmpty
                      ? const Center(child: Text('No data found'))
                      : ListView.builder(
                    itemCount: statsProvider.patientsByDoctor.length,
                    itemBuilder: (context, index) {
                      final patient = statsProvider.patientsByDoctor[index];
                      return ListTile(
                        title: Text(patient.name),
                        subtitle: Text('EGN: ${patient.egn}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.info_outline),
                          onPressed: () {
                            _showPatientInfoDialog(context, patient);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPatientInfoDialog(BuildContext context, Patient patient) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Patient Details: ${patient.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row('Name:', patient.name),
              _row('EGN:', patient.egn),
              _row('Health Insurance Paid:', patient.healthInsurancePaid ? 'Yes' : 'No'),
              // Add more fields as needed
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }
}