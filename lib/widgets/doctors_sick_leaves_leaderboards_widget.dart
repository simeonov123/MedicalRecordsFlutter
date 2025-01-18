import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/statistics_provider.dart';

class DoctorsSickLeavesLeaderboardsWidget extends StatefulWidget {
  const DoctorsSickLeavesLeaderboardsWidget({Key? key}) : super(key: key);

  @override
  State<DoctorsSickLeavesLeaderboardsWidget> createState() => _DoctorsSickLeavesLeaderboardsWidgetState();
}

class _DoctorsSickLeavesLeaderboardsWidgetState extends State<DoctorsSickLeavesLeaderboardsWidget> {
  @override
  void initState() {
    super.initState();
    final statsProvider = Provider.of<StatisticsProvider>(context, listen: false);
    if (statsProvider.doctorsSickLeavesLeaderboard.isEmpty) {
      statsProvider.fetchDoctorsSickLeavesLeaderboard();
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
                    'Doctors Sick Leaves Leaderboard',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh leaderboard',
                    onPressed: () {
                      statsProvider.fetchDoctorsSickLeavesLeaderboard();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: statsProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (statsProvider.doctorsSickLeavesLeaderboard.isEmpty
                    ? const Center(child: Text('No data found.'))
                    : ListView.builder(
                  itemCount: statsProvider.doctorsSickLeavesLeaderboard.length,
                  itemBuilder: (context, index) {
                    final item = statsProvider.doctorsSickLeavesLeaderboard[index];
                    final rank = index + 1;

                    return ListTile(
                      leading: Text('$rank.'),
                      title: Text(item.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Specialties: ${item.specialties}'),
                          Text('Primary Care: ${item.primaryCare ? "Yes" : "No"}'),
                          Text('Sick Leaves: ${item.sickLeavesCount}'),
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