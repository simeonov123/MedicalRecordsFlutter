import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../domain/sick_leave.dart';
import '../provider/appointment_provider.dart';
import '../provider/auth_provider.dart';
import 'edit_sick_leave_form.dart';
import 'role_based_widget.dart';

class SickLeaveDialog extends StatefulWidget {
  final List<SickLeave> sickLeaves;
  final int appointmentId;
  final String doctorKeycloakUserId;

  const SickLeaveDialog({
    Key? key,
    required this.sickLeaves,
    required this.appointmentId,
    required this.doctorKeycloakUserId,
  }) : super(key: key);

  @override
  _SickLeaveDialogState createState() => _SickLeaveDialogState();
}

class _SickLeaveDialogState extends State<SickLeaveDialog> {
  List<SickLeave> _sickLeaves = [];

  @override
  void initState() {
    super.initState();
    _sickLeaves = widget.sickLeaves;
  }

  void _updateSickLeave(SickLeave updatedSickLeave) {
    setState(() {
      int index = _sickLeaves.indexWhere((sickLeave) => sickLeave.id == updatedSickLeave.id);
      if (index != -1) {
        _sickLeaves[index] = updatedSickLeave;
      }
    });
  }

  void _onDeleteSickLeave(int sickLeaveId) {
    setState(() {
      int index = _sickLeaves.indexWhere((sickLeave) => sickLeave.id == sickLeaveId);
      if (index != -1) {
        _sickLeaves.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserKeycloakId = authProvider.keycloakUserId;

    return AlertDialog(
      title: const Text('Sick Leave Details'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: _sickLeaves.length,
          itemBuilder: (context, index) {
            final sickLeave = _sickLeaves[index];
            return ListTile(
              title: Text('Reason: ${sickLeave.reason}'),
              subtitle: Text(
                'Today\'s date: ${DateFormat('yyyy-MM-dd').format(sickLeave.todayDate)}\n'
                    'From: ${DateFormat('yyyy-MM-dd').format(sickLeave.startDate)}\n'
                    'To: ${DateFormat('yyyy-MM-dd').format(sickLeave.endDate)}',
              ),
              trailing: RoleBasedWidget(
                allowedRoles: ['admin', 'doctor'],
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (authProvider.roles.contains('admin') || currentUserKeycloakId == widget.doctorKeycloakUserId)
                      ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => EditSickLeaveForm(
                              appointmentId: widget.appointmentId,
                              sickLeave: sickLeave,
                              onUpdate: _updateSickLeave,
                            ),
                          );
                        },
                        child: const Text('Edit'),
                      ),
                    const SizedBox(width: 8),
                    if (authProvider.roles.contains('admin') || currentUserKeycloakId == widget.doctorKeycloakUserId)
                      ElevatedButton(
                        onPressed: () async {
                          bool success = await Provider.of<AppointmentProvider>(context, listen: false)
                              .deleteSickLeave(widget.appointmentId, sickLeave.id);
                          if (success) {
                            _onDeleteSickLeave(sickLeave.id);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to delete sick leave')),
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