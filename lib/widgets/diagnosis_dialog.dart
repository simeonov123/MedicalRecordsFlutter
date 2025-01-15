// lib/widgets/diagnosis_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../domain/diagnosis.dart';
import '../provider/appointment_provider.dart';
import '../provider/auth_provider.dart';
import 'edit_diagnosis_form.dart';
import 'role_based_widget.dart'; // We leave this import if you're using RoleBasedWidget elsewhere
import 'treatment_dialog.dart';
import 'treatment_form.dart';

class DiagnosisDialog extends StatelessWidget {
  final int appointmentId;
  final String doctorKeycloakUserId;

  const DiagnosisDialog({
    Key? key,
    required this.appointmentId,
    required this.doctorKeycloakUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserKeycloakId = authProvider.keycloakUserId;

    // We use a Consumer so that when the provider changes (create/delete/edit diagnosis),
    // this dialog rebuilds automatically with the latest data.
    return Consumer<AppointmentProvider>(
      builder: (context, appointmentProvider, _) {
        // 1) Find the appointment in the provider by ID
        final appointmentIndex = appointmentProvider.appointments
            .indexWhere((a) => a.id == appointmentId);

        // If appointment not found, show a simple dialog
        if (appointmentIndex == -1) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Appointment not found.'),
              ),
            ),
          );
        }

        final appointment = appointmentProvider.appointments[appointmentIndex];
        final diagnoses = appointment.diagnoses;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Diagnosis Details',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // 2) Show a list of diagnoses from the provider
                  Expanded(
                    child: diagnoses.isEmpty
                        ? const Center(child: Text('No diagnoses found.'))
                        : ListView.builder(
                      shrinkWrap: true,
                      itemCount: diagnoses.length,
                      itemBuilder: (context, index) {
                        final diagnosis = diagnoses[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Statement: ${diagnosis.statement}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Diagnosed Date: '
                                      '${DateFormat('yyyy-MM-dd').format(diagnosis.diagnosedDate)}',
                                ),
                                const SizedBox(height: 12),

                                // Action buttons (Add Treatment, Edit, Delete)
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (authProvider.roles.contains('admin') ||
                                        currentUserKeycloakId ==
                                            doctorKeycloakUserId)
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => TreatmentForm(
                                              diagnosisId: diagnosis.id,
                                              appointmentId: appointmentId,
                                            ),
                                          );
                                        },
                                        child:
                                        const Text('Add Treatment'),
                                      ),
                                    const SizedBox(width: 8),

                                    if (authProvider.roles.contains('admin') ||
                                        currentUserKeycloakId ==
                                            doctorKeycloakUserId)
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => EditDiagnosisForm(
                                              appointmentId: appointmentId,
                                              diagnosis: diagnosis,
                                              onUpdate: (updatedDiagnosis) {
                                                // No manual setState needed—
                                                // we rely on Provider to rebuild.
                                              },
                                            ),
                                          );
                                        },
                                        child: const Text('Edit'),
                                      ),
                                    const SizedBox(width: 8),

                                    if (authProvider.roles.contains('admin') ||
                                        currentUserKeycloakId ==
                                            doctorKeycloakUserId)
                                      ElevatedButton(
                                        onPressed: () async {
                                          bool success =
                                          await Provider.of<AppointmentProvider>(
                                              context,
                                              listen: false)
                                              .deleteDiagnosis(
                                              appointmentId,
                                              diagnosis.id);

                                          if (!success) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Failed to delete diagnosis'),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Diagnosis deleted successfully'),
                                              ),
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Delete'),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // If there are treatments, a button to open the TreatmentDialog
                                if (diagnosis.treatments.isNotEmpty)
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: TextButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => TreatmentDialog(
                                            appointmentId: appointmentId,
                                            doctorKeycloakUserId:
                                            doctorKeycloakUserId,
                                            diagnosisId: diagnosis.id,
                                          ),
                                        );
                                      },
                                      child: const Text('View Treatments'),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
