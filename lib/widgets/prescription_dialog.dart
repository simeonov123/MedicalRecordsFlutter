import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../domain/prescription.dart';
import '../provider/appointment_provider.dart';
import '../provider/auth_provider.dart';
import 'medication_dialog.dart';
import 'edit_prescription_form.dart';
import 'role_based_widget.dart';

class PrescriptionDialog extends StatelessWidget {
  final List<Prescription> prescriptions;
  final int appointmentId;
  final int treatmentId;
  final String doctorKeycloakUserId;

  const PrescriptionDialog({
    Key? key,
    required this.prescriptions,
    required this.appointmentId,
    required this.treatmentId,
    required this.doctorKeycloakUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUserKeycloakId = authProvider.keycloakUserId;

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
                'Prescription Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: prescriptions.length,
                  itemBuilder: (context, index) {
                    final prescription = prescriptions[index];
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
                              'Dosage: ${prescription.dosage}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('Duration: ${prescription.duration} days'),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (_) => MedicationDialog(
                                      medication: prescription.medication,
                                    ),
                                  );
                                },
                                child: const Text('Medication Info'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (authProvider.roles.contains('admin') ||
                                    (authProvider.roles.contains('doctor') &&
                                        currentUserKeycloakId == doctorKeycloakUserId))
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => EditPrescriptionForm(
                                          appointmentId: appointmentId,
                                          treatmentId: treatmentId,
                                          prescription: prescription,
                                          onUpdate: (updatedPrescription) {
                                            prescriptions[index] = updatedPrescription;
                                          },
                                        ),
                                      );
                                    },
                                    child: const Text('Edit'),
                                  ),
                                const SizedBox(width: 8),
                                if (authProvider.roles.contains('admin') ||
                                    (authProvider.roles.contains('doctor') &&
                                        currentUserKeycloakId == doctorKeycloakUserId))
                                  ElevatedButton(
                                    onPressed: () async {
                                      bool success = await Provider.of<AppointmentProvider>(context, listen: false)
                                          .deletePrescription(appointmentId, treatmentId, prescription.id);
                                      if (success) {
                                        prescriptions.removeAt(index);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Prescription deleted successfully')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Failed to delete prescription')),
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
  }
}