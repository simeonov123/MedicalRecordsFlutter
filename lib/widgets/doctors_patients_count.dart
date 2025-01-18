// lib/widgets/doctors_patients_count.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/statistics_provider.dart';
import '../service/statistics_service.dart';

class DoctorsPatientsCountWidget extends StatefulWidget {
  const DoctorsPatientsCountWidget({Key? key}) : super(key: key);

  @override
  State<DoctorsPatientsCountWidget> createState() => _DoctorsPatientsCountWidgetState();
}

class _DoctorsPatientsCountWidgetState extends State<DoctorsPatientsCountWidget> {
  @override
  void initState() {
    super.initState();
    final statsProvider = Provider.of<StatisticsProvider>(context, listen: false);
    if (statsProvider.doctorsPatientCount.isEmpty) {
      statsProvider.fetchDoctorsWithPatientCount();
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
              // Title + Refresh button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Doctors with Patient Count',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    onPressed: () {
                      statsProvider.fetchDoctorsWithPatientCount();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: statsProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (statsProvider.doctorsPatientCount.isEmpty
                    ? const Center(child: Text('No data found.'))
                    : ListView.builder(
                  itemCount: statsProvider.doctorsPatientCount.length,
                  itemBuilder: (context, index) {
                    final item = statsProvider.doctorsPatientCount[index];
                    return ListTile(
                      title: Text(item.doctorName),
                      trailing: Text('${item.count} patients'),
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