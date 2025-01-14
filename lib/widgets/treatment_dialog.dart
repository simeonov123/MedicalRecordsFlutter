import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../domain/treatment.dart';
import '../provider/appointment_provider.dart';
import '../provider/auth_provider.dart';
import 'prescription_dialog.dart';
import 'prescription_form.dart';
import 'edit_treatment_form.dart';

class TreatmentDialog extends StatelessWidget {
  final List<Treatment> treatments;
  final int appointmentId;
  final String doctorKeycloakUserId;
  final int diagnosisId;

  const TreatmentDialog({
    Key? key,
    required this.treatments,
    required this.appointmentId,
    required this.doctorKeycloakUserId, required this.diagnosisId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

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
                'Treatment Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: treatments.length,
                  itemBuilder: (context, index) {
                    final treatment = treatments[index];
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
                              'Treatment ID: ${treatment.id}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text('Description: ${treatment.description}'),
                            Text('Start: ${DateFormat('yyyy-MM-dd').format(treatment.startDate)}'),
                            Text('End: ${DateFormat('yyyy-MM-dd').format(treatment.endDate)}'),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (authProvider.roles.contains('doctor') &&
                                    authProvider.keycloakUserId == doctorKeycloakUserId)
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => PrescriptionForm(
                                          treatmentId: treatment.id,
                                          appointmentId: appointmentId,
                                        ),
                                      );
                                    },
                                    child: const Text('Add Prescription'),
                                  ),
                                const SizedBox(width: 8),
                                if (authProvider.roles.contains('doctor') &&
                                    authProvider.keycloakUserId == doctorKeycloakUserId)
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => EditTreatmentForm(
                                          appointmentId: appointmentId,
                                          treatment: treatment,
                                          onUpdate: (updatedTreatment) {
                                            treatments[index] = updatedTreatment;
                                          }, diagnosisId: diagnosisId,
                                        ),
                                      );
                                    },
                                    child: const Text('Edit Treatment'),
                                  ),
                                const SizedBox(width: 8),
                                if (authProvider.roles.contains('doctor') &&
                                    authProvider.keycloakUserId == doctorKeycloakUserId)
                                  ElevatedButton(
                                    onPressed: () async {
                                      bool success = await Provider.of<AppointmentProvider>(context, listen: false)
                                          .deleteTreatment(appointmentId, diagnosisId, treatment.id);
                                      if (success) {
                                        treatments.removeAt(index);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Treatment deleted successfully')),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Failed to delete treatment')),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Delete Treatment'),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            if (treatment.prescriptions.isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => PrescriptionDialog(
                                        prescriptions: treatment.prescriptions, appointmentId: appointmentId, treatmentId: treatment.id, doctorKeycloakUserId: doctorKeycloakUserId, diagnosisId: diagnosisId,
                                      ),
                                    );
                                  },
                                  child: const Text('View Prescriptions'),
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
  }
}
