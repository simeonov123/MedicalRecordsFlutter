import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../domain/sick_leave.dart';
import '../provider/appointment_provider.dart';
import 'edit_sick_leave_form.dart';
import 'role_based_widget.dart';

class SickLeaveDialog extends StatefulWidget {
  final List<SickLeave> sickLeaves;
  final int appointmentId;

  const SickLeaveDialog({Key? key, required this.sickLeaves, required this.appointmentId}) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
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
                child: ElevatedButton(
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