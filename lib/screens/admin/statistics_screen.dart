import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/statistics_provider.dart';
import '../../widgets/diagnosis_search_widget.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  late Future<void> _fetchFuture;

  @override
  void initState() {
    super.initState();
    final statsProvider = Provider.of<StatisticsProvider>(context, listen: false);
    if (statsProvider.totalAppointments == 0) {
      _fetchFuture = statsProvider.fetchStatistics();
    } else {
      _fetchFuture = Future.value();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistics'),
      ),
      body: FutureBuilder<void>(
        future: _fetchFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Once loaded, rely on Provider data:
          return Consumer<StatisticsProvider>(
            builder: (context, stats, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  // Decide how many columns in the grid based on available width
                  final isWideScreen = constraints.maxWidth > 800;
                  // e.g. 2 columns if wide, 1 column if narrow
                  final crossAxisCount = isWideScreen ? 2 : 1;

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    padding: const EdgeInsets.all(16),
                    children: [
                      // 1) A box for "Total Appointments"
                      Container(
                        decoration: _boxDecorationStyle(),
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Total Appointments',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${stats.totalAppointments}',
                              style: const TextStyle(fontSize: 24),
                            ),
                            const Spacer(),
                            const Text(
                              'This shows the total number of appointments in the system.',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),

                      // 2) A box for the DiagnosisSearchWidget
                      Container(
                        decoration: _boxDecorationStyle(),
                        // We'll give it some constraints so the list is scrollable
                        child: const DiagnosisSearchWidget(),
                      ),

                      // 3) Future boxes can go here
                      // Container(...) for another stat or chart, etc.
                      // For now, we only have 2 main items
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // A helper method for styling each grid box
  BoxDecoration _boxDecorationStyle() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.2),
          spreadRadius: 2,
          blurRadius: 6,
          offset: const Offset(0, 3),
        ),
      ],
    );
  }
}
