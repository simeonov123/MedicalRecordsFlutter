// lib/widgets/appointment_list_widget.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../provider/appointment_provider.dart';
import '../provider/auth_provider.dart';
import 'sick_leave_form.dart';
import 'diagnosis_form.dart';
import 'sickLeave_dialog.dart';
import 'diagnosis_dialog.dart';
import 'edit_appointment_form.dart';
import 'role_based_widget.dart';

class AppointmentListWidget extends StatefulWidget {
  final bool fromDoctorOrAdmin;
  final int? patientId;

  const AppointmentListWidget({
    Key? key,
    required this.fromDoctorOrAdmin,
    this.patientId,
  }) : super(key: key);

  @override
  State<AppointmentListWidget> createState() => _AppointmentListWidgetState();
}

class _AppointmentListWidgetState extends State<AppointmentListWidget>
    with SingleTickerProviderStateMixin {
  late Future<void> _fetchFuture;

  // AnimationController and CurvedAnimation for the fade-in
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1) Set up our fade-in AnimationController
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700), // adjust as desired
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    // 2) Trigger the initial fetch
    final appointmentProvider =
    Provider.of<AppointmentProvider>(context, listen: false);

    if (widget.fromDoctorOrAdmin && widget.patientId != null) {
      _fetchFuture =
          appointmentProvider.fetchAllAppointmentsForPatient(widget.patientId!);
    } else {
      _fetchFuture = appointmentProvider.fetchAppointmentsForUser();
    }

    // We don’t call _controller.forward() yet; we’ll do it once the Future completes
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserKeycloakId = authProvider.keycloakUserId;

    return FutureBuilder<void>(
      future: _fetchFuture,
      builder: (context, snapshot) {
        // While waiting, show a spinner
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          // Show error
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // If we’re here, the Future is done:
        // -> forward the fade-in animation if not already done
        if (_controller.status == AnimationStatus.dismissed) {
          _controller.forward();
        }

        // 3) Return the fade transition for the entire list content
        return FadeTransition(
            opacity: _fadeAnimation,
            child: Consumer<AppointmentProvider>(
            builder: (context, appointmentProvider, child) {
          if (appointmentProvider.appointments.isEmpty) {
            return const Center(child: Text('No appointments found.'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isLargeScreen = constraints.maxWidth > 600;
              return ListView.builder(
                itemCount: appointmentProvider.appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointmentProvider.appointments[index];
                  final createdDate = DateFormat('yyyy-MM-dd – kk:mm')
                      .format(appointment.createdAt);
                  final appointmentDateTime = DateFormat('yyyy-MM-dd – kk:mm')
                      .format(appointment.appointmentDateTime);
                  final updatedDate = appointment.updatedAt != null
                      ? DateFormat('yyyy-MM-dd – kk:mm')
                      .format(appointment.updatedAt!)
                      : 'N/A';

                  final isCurrentUserDoctor =
                      currentUserKeycloakId == appointment.doctor.keycloakUserId;

                  return Center(
                    child: Container(
                      width: isLargeScreen ? 850 : double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 8.0,
                        horizontal: isLargeScreen ? 0 : 16.0,
                      ),
                      child: Card(
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Appointment ID: ${appointment.id}',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Divider(color: Colors.grey.shade400),
                              const SizedBox(height: 8),
                              Text('Doctor: ${appointment.doctor.name}'),
                              appointment.doctor.specialties.isNotEmpty
                                  ? Text(
                                  'Specialties: ${appointment.doctor.specialties}')
                                  : const Text('Specialties: N/A'),
                              Text('Appointment date and time: $appointmentDateTime'),
                              Text('Created At: $createdDate'),
                              Text('Updated At: $updatedDate'),
                              const SizedBox(height: 16),
                              Divider(color: Colors.grey.shade400),
                              const SizedBox(height: 16),

                                RoleBasedWidget(
                                  allowedRoles: ['admin', 'doctor'],
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Patient Information',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium!
                                            .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text('Name: ${appointment.patient.name}'),
                                      Text('EGN: ${appointment.patient.egn}'),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),

                                if (isCurrentUserDoctor || authProvider.roles.contains('admin'))
                                  RoleBasedWidget(
                                    allowedRoles: ['admin', 'doctor'],
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => SickLeaveForm(
                                                appointmentId: appointment.id,
                                                existingSickLeaves:
                                                appointment.sickLeaves,
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Add Sick Leave',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blue,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => DiagnosisForm(
                                                appointmentId: appointment.id,
                                                existingDiagnoses:
                                                appointment.diagnoses,
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Add Diagnosis',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 16),

                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    if (appointment.sickLeaves.isNotEmpty)
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => SickLeaveDialog(
                                                appointmentId: appointment.id,
                                                doctorKeycloakUserId: appointment
                                                    .doctor.keycloakUserId,
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'View Sick Leave Details',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    const SizedBox(width: 10),
                                    if (appointment.diagnoses.isNotEmpty)
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.blueAccent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => DiagnosisDialog(
                                                appointmentId: appointment.id,
                                                doctorKeycloakUserId: appointment
                                                    .doctor.keycloakUserId,
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'View Diagnosis Details',
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),

                              if (isCurrentUserDoctor ||
                                  authProvider.roles.contains('admin'))
                                RoleBasedWidget(
                                  allowedRoles: ['admin', 'doctor'],
                                  child: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (_) => EditAppointmentForm(
                                              appointment: appointment,
                                              onUpdate: (updatedAppointment) {
                                                Provider.of<AppointmentProvider>(
                                                  context,
                                                  listen: false,
                                                ).updateLocalAppointment(
                                                  updatedAppointment,
                                                );
                                              },
                                            ),
                                          );
                                        },
                                        child: const Text('Edit'),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          bool success =
                                          await Provider.of<AppointmentProvider>(
                                            context,
                                            listen: false,
                                          ).deleteAppointment(appointment.id);

                                          if (success) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Appointment deleted successfully',
                                                ),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Failed to delete appointment',
                                                ),
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
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
            },
            ),
        );
      },
    );
  }
}