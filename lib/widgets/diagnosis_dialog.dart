import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../domain/diagnosis.dart';
import '../provider/appointment_provider.dart';
import '../provider/auth_provider.dart';
import 'edit_diagnosis_form.dart';
import 'role_based_widget.dart';
import 'treatment_dialog.dart';
import 'treatment_form.dart';

class DiagnosisDialog extends StatefulWidget {
  final List<Diagnosis> diagnoses;
  final int appointmentId;
  final String doctorKeycloakUserId;

  const DiagnosisDialog({
    Key? key,
    required this.diagnoses,
    required this.appointmentId,
    required this.doctorKeycloakUserId,
  }) : super(key: key);

  @override
  _DiagnosisDialogState createState() => _DiagnosisDialogState();
}

class _DiagnosisDialogState extends State<DiagnosisDialog> {
  List<Diagnosis> _diagnoses = [];

  @override
  void initState() {
    super.initState();
    _diagnoses = widget.diagnoses;
  }

  void _updateDiagnosis(Diagnosis updatedDiagnosis) {
    setState(() {
      int index = _diagnoses.indexWhere((diagnosis) => diagnosis.id == updatedDiagnosis.id);
      if (index != -1) {
        _diagnoses[index] = updatedDiagnosis;
      }
    });
  }

  void _onDeleteDiagnosis(int diagnosisId) {
    setState(() {
      int index = _diagnoses.indexWhere((diagnosis) => diagnosis.id == diagnosisId);
      if (index != -1) {
        _diagnoses.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
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
                'Diagnosis Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _diagnoses.length,
                  itemBuilder: (context, index) {
                    final diagnosis = _diagnoses[index];
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
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Diagnosed Date: ${DateFormat('yyyy-MM-dd').format(diagnosis.diagnosedDate)}',
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (authProvider.roles.contains('admin') ||
                                    currentUserKeycloakId == widget.doctorKeycloakUserId)
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => TreatmentForm(
                                          diagnosisId: diagnosis.id,
                                          appointmentId: widget.appointmentId,
                                        ),
                                      );
                                    },
                                    child: const Text('Add Treatment'),
                                  ),
                                const SizedBox(width: 8),
                                if (authProvider.roles.contains('admin') ||
                                    currentUserKeycloakId == widget.doctorKeycloakUserId)
                                  ElevatedButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (_) => EditDiagnosisForm(
                                          appointmentId: widget.appointmentId,
                                          diagnosis: diagnosis,
                                          onUpdate: _updateDiagnosis,
                                        ),
                                      );
                                    },
                                    child: const Text('Edit'),
                                  ),
                                const SizedBox(width: 8),
                                if (authProvider.roles.contains('admin') ||
                                    currentUserKeycloakId == widget.doctorKeycloakUserId)
                                  ElevatedButton(
                                    onPressed: () async {
                                      bool success = await Provider.of<AppointmentProvider>(context, listen: false)
                                          .deleteDiagnosis(widget.appointmentId, diagnosis.id);
                                      if (success) {
                                        _onDeleteDiagnosis(diagnosis.id);
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Failed to delete diagnosis')),
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
                            if (diagnosis.treatments.isNotEmpty)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (_) => TreatmentDialog(
                                        treatments: diagnosis.treatments,
                                        appointmentId: widget.appointmentId,
                                        doctorKeycloakUserId: widget.doctorKeycloakUserId, diagnosisId: diagnosis.id,
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
  }
}
