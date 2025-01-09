import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../domain/sick_leave.dart';

class SickLeaveDialog extends StatelessWidget {
  final List<SickLeave> sickLeaves;

  const SickLeaveDialog({Key? key, required this.sickLeaves}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Sick Leave Details'),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: sickLeaves.length,
          itemBuilder: (context, index) {
            final sickLeave = sickLeaves[index];
            return ListTile(
              title: Text('Reason: ${sickLeave.reason}'),
              subtitle: Text(
                'From: ${DateFormat('yyyy-MM-dd').format(sickLeave.startDate)}\n'
                    'To: ${DateFormat('yyyy-MM-dd').format(sickLeave.endDate)}',
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
