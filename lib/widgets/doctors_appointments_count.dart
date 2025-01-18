// lib/widgets/doctors_appointments_count.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/statistics_provider.dart';
import '../service/statistics_service.dart';

class DoctorsAppointmentsCountWidget extends StatefulWidget {
  const DoctorsAppointmentsCountWidget({Key? key}) : super(key: key);

  @override
  State<DoctorsAppointmentsCountWidget> createState() => _DoctorsAppointmentsCountWidgetState();
}

class _DoctorsAppointmentsCountWidgetState extends State<DoctorsAppointmentsCountWidget> {
  @override
  void initState() {
    super.initState();
    final statsProvider = Provider.of<StatisticsProvider>(context, listen: false);
    if (statsProvider.doctorsAppointmentCount.isEmpty) {
      statsProvider.fetchDoctorsWithAppointmentsCount();
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
                    'Doctors with Appointments Count',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh',
                    onPressed: () {
                      statsProvider.fetchDoctorsWithAppointmentsCount();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: statsProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (statsProvider.doctorsAppointmentCount.isEmpty
                    ? const Center(child: Text('No data found.'))
                    : ListView.builder(
                  itemCount: statsProvider.doctorsAppointmentCount.length,
                  itemBuilder: (context, index) {
                    final item = statsProvider.doctorsAppointmentCount[index];
                    return ListTile(
                      title: Text(item.doctorName),
                      trailing: Text('${item.count} appointments'),
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