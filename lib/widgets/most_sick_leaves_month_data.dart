// lib/widgets/most_sick_leaves_month_data.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/statistics_provider.dart';

class MostSickLeavesMonthDataWidget extends StatefulWidget {
  const MostSickLeavesMonthDataWidget({Key? key}) : super(key: key);

  @override
  State<MostSickLeavesMonthDataWidget> createState() => _MostSickLeavesMonthDataWidgetState();
}

class _MostSickLeavesMonthDataWidgetState extends State<MostSickLeavesMonthDataWidget> {
  @override
  void initState() {
    super.initState();
    final statsProvider = Provider.of<StatisticsProvider>(context, listen: false);
    if (statsProvider.mostSickLeavesMonthData.isEmpty) {
      statsProvider.fetchMostSickLeavesMonthData();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Most Sick Leaves Month Data',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh data',
                    onPressed: () {
                      statsProvider.fetchMostSickLeavesMonthData();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: statsProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (statsProvider.mostSickLeavesMonthData.isEmpty
                    ? const Center(child: Text('No data found.'))
                    : ListView.builder(
                  itemCount: statsProvider.mostSickLeavesMonthData.length,
                  itemBuilder: (context, index) {
                    final item = statsProvider.mostSickLeavesMonthData[index];
                    return ListTile(
                      title: Text(item.monthName),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Sick Leaves: ${item.sickLeavesCount}'),
                          Text('Appointments: ${item.appointmentsThatMonthCount}'),
                          Text('Unique Patients: ${item.uniquePatientsCount}'),
                          Text('Most Common Diagnosis: ${item.mostCommonDiagnosisThatMonth}'),
                        ],
                      ),
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