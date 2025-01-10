import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../domain/diagnosis.dart';
import '../provider/appointment_provider.dart';
import 'edit_diagnosis_form.dart';
import 'role_based_widget.dart';
import 'treatment_dialog.dart';

class DiagnosisDialog extends StatefulWidget {
  final List<Diagnosis> diagnoses;
  final int appointmentId;

  const DiagnosisDialog({Key? key, required this.diagnoses, required this.appointmentId}) : super(key: key);

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
    return AlertDialog(
      title: const Text('Diagnosis Details'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _diagnoses.length,
          itemBuilder: (context, index) {
            final diagnosis = _diagnoses[index];
            return ListTile(
              title: Text('Statement: ${diagnosis.statement}'),
              subtitle: Text(
                'Diagnosed Date: ${DateFormat('yyyy-MM-dd').format(diagnosis.diagnosedDate)}',
              ),
              trailing: RoleBasedWidget(
                allowedRoles: ['admin', 'doctor'],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
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
              ),
              onTap: diagnosis.treatments.isNotEmpty
                  ? () {
                showDialog(
                  context: context,
                  builder: (_) => TreatmentDialog(treatments: diagnosis.treatments),
                );
              }
                  : null,
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}