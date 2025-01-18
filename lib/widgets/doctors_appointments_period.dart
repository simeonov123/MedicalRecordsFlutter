// lib/widgets/doctors_appointments_period.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../provider/statistics_provider.dart';

class DoctorsAppointmentsPeriod extends StatefulWidget {
  const DoctorsAppointmentsPeriod({Key? key}) : super(key: key);

  @override
  State<DoctorsAppointmentsPeriod> createState() => _DoctorsAppointmentsPeriodState();
}

class _DoctorsAppointmentsPeriodState extends State<DoctorsAppointmentsPeriod> {
  DateTime? _startDate;
  DateTime? _endDate;

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != (isStartDate ? _startDate : _endDate)) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _submit() {
    if (_startDate != null && _endDate != null) {
      final statsProvider = Provider.of<StatisticsProvider>(context, listen: false);
      statsProvider.fetchDoctorsThatHaveAppointmentsInAPeriod(_startDate!, _endDate!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both start and end dates.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsProvider>(
      builder: (context, statsProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Title + Submit button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Doctors Appointments Period',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Submit'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Date pickers
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectDate(context, true),
                      child: Text(_startDate == null
                          ? 'Select Start Date'
                          : DateFormat('yyyy-MM-dd').format(_startDate!)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextButton(
                      onPressed: () => _selectDate(context, false),
                      child: Text(_endDate == null
                          ? 'Select End Date'
                          : DateFormat('yyyy-MM-dd').format(_endDate!)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // List of doctors
              Expanded(
                child: statsProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (statsProvider.doctorsThatHaveAppointmentsInPeriod.isEmpty
                    ? const Center(child: Text('No data found.'))
                    : ListView.builder(
                  itemCount: statsProvider.doctorsThatHaveAppointmentsInPeriod.length,
                  itemBuilder: (context, index) {
                    final item = statsProvider.doctorsThatHaveAppointmentsInPeriod[index];
                    return ListTile(
                      title: Text(item.doctorName),
                      onTap: () {
                        if (_startDate != null && _endDate != null) {
                          Navigator.pushNamed(
                            context,
                            '/patient/appointments/doctors',
                            arguments: {
                              'doctorId': item.doctorId,
                              'startDate': _startDate,
                              'endDate': _endDate,
                            },
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Please select both start and end dates.'),
                            ),
                          );
                        }
                      },
                    );
                  },
                )),
              ),
            ],
          ),
        );
      },
    );
  }
}