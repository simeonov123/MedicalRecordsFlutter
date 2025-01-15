// lib/widgets/sickLeave_dialog.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../domain/sick_leave.dart';
import '../provider/appointment_provider.dart';
import '../provider/auth_provider.dart';
import 'edit_sick_leave_form.dart';
import 'role_based_widget.dart';

class SickLeaveDialog extends StatelessWidget {
  final int appointmentId;
  final String doctorKeycloakUserId;

  const SickLeaveDialog({
    Key? key,
    required this.appointmentId,
    required this.doctorKeycloakUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserKeycloakId = authProvider.keycloakUserId;

    return Consumer<AppointmentProvider>(
      builder: (context, appointmentProvider, _) {
        // 1) Locate the appointment in the provider
        final aptIndex = appointmentProvider.appointments
            .indexWhere((apt) => apt.id == appointmentId);

        if (aptIndex == -1) {
          // Appointment not found or not loaded
          return AlertDialog(
            title: const Text('Sick Leave Details'),
            content: const Text('Appointment not found.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          );
        }

        final appointment = appointmentProvider.appointments[aptIndex];
        final sickLeaves = appointment.sickLeaves;

        return AlertDialog(
          title: const Text('Sick Leave Details'),
          content: SizedBox(
            width: double.maxFinite,
            child: sickLeaves.isEmpty
                ? const Center(child: Text('No sick leaves found.'))
                : ListView.builder(
              shrinkWrap: true,
              itemCount: sickLeaves.length,
              itemBuilder: (context, index) {
                final sickLeave = sickLeaves[index];
                return ListTile(
                  title: Text('Reason: ${sickLeave.reason}'),
                  subtitle: Text(
                    'Today\'s Date: '
                        '${DateFormat('yyyy-MM-dd').format(sickLeave.todayDate)}\n'
                        'From: ${DateFormat('yyyy-MM-dd').format(sickLeave.startDate)}\n'
                        'To: ${DateFormat('yyyy-MM-dd').format(sickLeave.endDate)}',
                  ),
                  trailing: RoleBasedWidget(
                    allowedRoles: ['admin', 'doctor'],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (authProvider.roles.contains('admin') ||
                            currentUserKeycloakId == doctorKeycloakUserId)
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => EditSickLeaveForm(
                                  appointmentId: appointmentId,
                                  sickLeave: sickLeave,
                                  onUpdate: (updated) {
                                    // No manual setState needed.
                                    // We'll rely on the provider rebuild.
                                  },
                                ),
                              );
                            },
                            child: const Text('Edit'),
                          ),
                        const SizedBox(width: 8),
                        if (authProvider.roles.contains('admin') ||
                            currentUserKeycloakId == doctorKeycloakUserId)
                          ElevatedButton(
                            onPressed: () async {
                              final success =
                              await Provider.of<AppointmentProvider>(
                                context,
                                listen: false,
                              ).deleteSickLeave(
                                appointmentId,
                                sickLeave.id,
                              );
                              if (!success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Failed to delete sick leave'),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Sick leave deleted successfully'),
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
      },
    );
  }
}
