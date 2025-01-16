// lib/widgets/diagnosis_leaderboards_widget.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/statistics_provider.dart';
import '../service/statistics_service.dart'; // for DiagnosisDetailsDto if needed

class DiagnosisLeaderboardsWidget extends StatefulWidget {
  const DiagnosisLeaderboardsWidget({Key? key}) : super(key: key);

  @override
  State<DiagnosisLeaderboardsWidget> createState() => _DiagnosisLeaderboardsWidgetState();
}

class _DiagnosisLeaderboardsWidgetState extends State<DiagnosisLeaderboardsWidget> {
  @override
  void initState() {
    super.initState();
    // Optionally fetch data if empty
    final statsProvider = Provider.of<StatisticsProvider>(context, listen: false);
    if (statsProvider.diagnosisLeaderboard.isEmpty) {
      statsProvider.fetchDiagnosisLeaderboard();
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
                    'Diagnosis Leaderboard (Top 10)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Refresh leaderboard',
                    onPressed: () {
                      statsProvider.fetchDiagnosisLeaderboard();
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),

              Expanded(
                child: statsProvider.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : (statsProvider.diagnosisLeaderboard.isEmpty
                    ? const Center(child: Text('No data found.'))
                    : ListView.builder(
                  itemCount: statsProvider.diagnosisLeaderboard.length,
                  itemBuilder: (context, index) {
                    final item = statsProvider.diagnosisLeaderboard[index];
                    final rank = index + 1;

                    return ListTile(
                      leading: Text('$rank.'),
                      title: Text(item.statement),
                      trailing: IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          _showDetailsDialog(context, item);
                        },
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

  void _showDetailsDialog(BuildContext context, DiagnosisDetailsDto item) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Diagnosis Details: ${item.statement}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _row('Count:', '${item.count}'),
              _row('Doctor First:', item.doctorNameOfFirstDiagnosis ?? 'N/A'),
              _row('Pct of all Diagnoses:', '${item.percentageOfAllDiagnoses}%'),
              _row('Pct of all Patients:', '${item.percentageOfAllPatients}%'),
              _row(
                'First Diagnosed:',
                item.dateOfFirstDiagnosis?.toString().split('.')[0] ?? 'N/A',
              ),
              _row(
                'Last Diagnosed:',
                item.dateOfLastDiagnosis?.toString().split('.')[0] ?? 'N/A',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        const SizedBox(width: 8),
        Expanded(child: Text(value)),
      ],
    );
  }
}
