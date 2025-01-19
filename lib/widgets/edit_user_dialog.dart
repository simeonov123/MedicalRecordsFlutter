// lib/widgets/edit_user_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/doctor.dart';
import '../domain/patient.dart';
import '../domain/user.dart';
import '../provider/user_provider.dart';
import '../provider/doctor_provider.dart';
import '../provider/patient_provider.dart';

class EditUserDialog extends StatefulWidget {
  final User user;

  const EditUserDialog({Key? key, required this.user}) : super(key: key);

  @override
  State<EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<EditUserDialog> {
  late TextEditingController _egnController;
  late TextEditingController _emailController;
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _usernameController;
  bool _emailVerified = false;

  late TextEditingController _specialtiesController;
  bool _primaryCare = false;

  bool _healthInsurancePaid = false;
  late TextEditingController _primaryDoctorIdController;

  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeFields();
  }

  void _initializeFields() {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);

    _egnController = TextEditingController(text: widget.user.egn);
    _emailController = TextEditingController(text: widget.user.email);
    _firstNameController = TextEditingController(text: widget.user.firstName ?? '');
    _lastNameController = TextEditingController(text: widget.user.lastName ?? '');
    _usernameController = TextEditingController(text: widget.user.username);
    _emailVerified = widget.user.emailVerified;

    if (widget.user.role == 'doctor') {
      final doc = doctorProvider.doctors.firstWhere(
            (d) => d.keycloakUserId == widget.user.keycloakUserId,
        orElse: () => Doctor(id: 0, keycloakUserId: '', name: '', specialties: '', primaryCare: false),
      );
      _specialtiesController = TextEditingController(text: doc.specialties == 'N/A' ? '' : doc.specialties);
      _primaryCare = doc.primaryCare;
    } else {
      _specialtiesController = TextEditingController(text: '');
    }

    if (widget.user.role == 'patient') {
      final pat = patientProvider.patients.firstWhere(
            (p) => p.keycloakUserId == widget.user.keycloakUserId,
        orElse: () => Patient(id: 0, name: '', egn: '', healthInsurancePaid: false, primaryDoctorId: 0, keycloakUserId: ''),
      );
      _healthInsurancePaid = pat.healthInsurancePaid;
      _primaryDoctorIdController = TextEditingController(
        text: pat.primaryDoctorId != 0 ? pat.primaryDoctorId.toString() : '',
      );
    } else {
      _primaryDoctorIdController = TextEditingController(text: '');
    }
  }

  @override
  void dispose() {
    _egnController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _specialtiesController.dispose();
    _primaryDoctorIdController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    final patientProvider = Provider.of<PatientProvider>(context, listen: false);

    final successUser = await userProvider.updateLocalUser(
      userId: widget.user.id,
      egn: _egnController.text,
      email: _emailController.text,
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      emailVerified: _emailVerified,
    );

    if (!successUser) {
      setState(() {
        _error = 'Failed to update user details';
      });
      return;
    }

    if (widget.user.role == 'doctor') {
      final updatedDoc = Doctor(
        id: 0,
        keycloakUserId: widget.user.keycloakUserId!,
        name: '',
        specialties: _specialtiesController.text,
        primaryCare: _primaryCare,
      );

      final successDoctor = await doctorProvider.updateDoctorByKeycloakId(updatedDoc);
      if (!successDoctor) {
        setState(() {
          _error = 'Failed to update doctor details';
        });
        return;
      }
    } else if (widget.user.role == 'patient') {
      final primaryDoctorId = _primaryDoctorIdController.text.isNotEmpty
          ? int.parse(_primaryDoctorIdController.text)
          : 0;

      final updatedPat = Patient(
        id: 0,
        name: '',
        egn: '',
        healthInsurancePaid: _healthInsurancePaid,
        primaryDoctorId: primaryDoctorId,
        keycloakUserId: widget.user.keycloakUserId!,
      );

      final successPatient = await patientProvider.updatePatient(updatedPat);
      if (!successPatient) {
        setState(() {
          _error = 'Failed to update patient details';
        });
        return;
      }
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit User: ${widget.user.username}'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_error != null)
              Text(
                _error!,
                style: const TextStyle(color: Colors.red),
              ),
            TextFormField(
              controller: _egnController,
              decoration: const InputDecoration(labelText: 'EGN'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'First Name'),
            ),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Last Name'),
            ),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(labelText: 'Username'),
            ),
            SwitchListTile(
              title: const Text('Email Verified'),
              value: _emailVerified,
              onChanged: (value) {
                setState(() {
                  _emailVerified = value;
                });
              },
            ),
            const Divider(),
            if (widget.user.role == 'doctor') ...[
              TextFormField(
                controller: _specialtiesController,
                decoration: const InputDecoration(labelText: 'Specialties'),
              ),
              SwitchListTile(
                title: const Text('Primary Care'),
                value: _primaryCare,
                onChanged: (value) {
                  setState(() {
                    _primaryCare = value;
                  });
                },
              ),
            ],
            if (widget.user.role == 'patient') ...[
              TextFormField(
                controller: _primaryDoctorIdController,
                decoration: const InputDecoration(labelText: 'Primary Doctor ID'),
                keyboardType: TextInputType.number,
              ),
              SwitchListTile(
                title: const Text('Health Insurance Paid'),
                value: _healthInsurancePaid,
                onChanged: (value) {
                  setState(() {
                    _healthInsurancePaid = value;
                  });
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          child: const Text('Save'),
        ),
      ],
    );
  }
}