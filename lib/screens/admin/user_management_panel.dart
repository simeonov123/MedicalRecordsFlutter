// lib/screens/admin/user_management_panel.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/doctor.dart';
import '../../provider/auth_provider.dart';
import '../../provider/user_provider.dart';
import '../../provider/doctor_provider.dart';
import '../../provider/patient_provider.dart';
import '../../domain/patient.dart';

class UserManagementPanel extends StatefulWidget {
  const UserManagementPanel({Key? key}) : super(key: key);

  @override
  _UserManagementPanelState createState() => _UserManagementPanelState();
}

class _UserManagementPanelState extends State<UserManagementPanel> {
  final Map<int, int?> _selectedDoctorByPatient = {};

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
      final patientProvider = Provider.of<PatientProvider>(context, listen: false);

      userProvider.fetchUsers();
      doctorProvider.fetchDoctors();
      patientProvider.fetchPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final doctorProvider = Provider.of<DoctorProvider>(context);
    final patientProvider = Provider.of<PatientProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final usersLoading = userProvider.isLoading || doctorProvider.isLoading || patientProvider.isLoading;
    final usersError = userProvider.error ?? doctorProvider.error ?? patientProvider.error;

    final patients = patientProvider.patients;
    final doctorCandidates = userProvider.users.where((u) => u.role == 'wannaBeDoctor').toList();
    final normalUsers = userProvider.users.where((u) => u.role != 'user').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              userProvider.fetchUsers();
              doctorProvider.fetchDoctors();
              patientProvider.fetchPatients();
            },
          ),
        ],
      ),
      body: usersLoading
          ? const Center(child: CircularProgressIndicator())
          : (usersError != null)
          ? Center(child: Text('Error: $usersError'))
          : ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Patients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...patients.map((patient) {
            final selectedDocId = _selectedDoctorByPatient[patient.id];
            final doctorExists = doctorProvider.doctors.any((doc) => doc.id == selectedDocId);

            if (!doctorExists) {
              _selectedDoctorByPatient[patient.id] = null;
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: ListTile(
                  title: Text('${patient.name} (EGN: ${patient.egn})'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Assign Primary Doctor:'),
                      DropdownButton<int>(
                        isExpanded: true,
                        value: _selectedDoctorByPatient[patient.id],
                        hint: const Text('Select Doctor'),
                        items: doctorProvider.doctors.map((doc) {
                          return DropdownMenuItem<int>(
                            value: doc.id,
                            child: Text(doc.name),
                          );
                        }).toList(),
                        onChanged: (newDoctorId) {
                          setState(() {
                            _selectedDoctorByPatient[patient.id] = newDoctorId;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: (_selectedDoctorByPatient[patient.id] == null)
                            ? null
                            : () async {
                          final success = await patientProvider.assignPrimaryDoctor(
                            patient.id,
                            _selectedDoctorByPatient[patient.id]!,
                          );
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Primary doctor assigned successfully')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to assign primary doctor')),
                            );
                          }
                        },
                        child: const Text('Assign Primary Doctor'),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Text('Health Insurance Paid: '),
                          Switch(
                            value: patient.healthInsurancePaid,
                            onChanged: (value) async {
                              final success = await patientProvider.updateHealthInsuranceStatus(patient.id, value);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Health insurance status updated successfully')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Failed to update health insurance status')),
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Doctor Candidates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...doctorCandidates.map((candidate) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: ListTile(
                  title: Text('${candidate.username} (${candidate.email})'),
                  subtitle: Text('Role: ${candidate.role}'),
                  trailing: ElevatedButton(
                    child: const Text('Approve Doctor'),
                    onPressed: () async {
                      final success = await userProvider.updateUserRole(candidate.id, 'doctor');
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Role updated successfully')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to update role')),
                        );
                      }
                    },
                  ),
                ),
              ),
            );
          }),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Other Users',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          ...normalUsers.map((user) {
            final canShowDropdown = <String>['admin', 'doctor', 'patient'].contains(user.role);

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: ListTile(
                  title: Text('${user.username} (${user.email})'),
                  subtitle: user.role == 'wannaBeDoctor'
                      ? const Text(
                    'Awaiting Approval',
                    style: TextStyle(
                      color: Colors.grey, // Style it beautifully
                      fontStyle: FontStyle.italic,
                    ),
                  )
                      : Text('Role: ${user.role}'),
                  leading: user.emailVerified
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : IconButton(
                    icon: const Icon(Icons.info_outline),
                    tooltip: 'Verify Email',
                    onPressed: () async {
                      final verified = await userProvider.verifyUserEmail(user.id, true);
                      if (verified) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email verified successfully')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to verify email')),
                        );
                      }
                    },
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete),
                        tooltip: 'Delete User',
                        onPressed: () async {
                          final deleted = await userProvider.deleteUser(user.id);
                          if (deleted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('User deleted successfully')),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Failed to delete user')),
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      if (canShowDropdown)
                        if (user.role == 'wannaBeDoctor')
                          const Text(
                            'Awaiting Approval',
                            style: TextStyle(
                              color: Colors.grey, // Style it beautifully
                              fontStyle: FontStyle.italic,
                            ),
                          )
                        else
                          DropdownButton<String>(
                            value: user.role,
                            items: <String>['admin', 'doctor', 'patient'].map((String val) {
                              return DropdownMenuItem<String>(
                                value: val,
                                child: Text(val),
                              );
                            }).toList(),
                            onChanged: (String? newRole) async {
                              if (newRole != null && newRole != user.role) {
                                final success = await userProvider.updateUserRole(user.id, newRole);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Role updated successfully')),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Failed to update role')),
                                  );
                                }
                              }
                            },
                          ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}