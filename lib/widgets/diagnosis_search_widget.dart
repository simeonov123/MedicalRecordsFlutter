import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../provider/statistics_provider.dart';

class DiagnosisSearchWidget extends StatefulWidget {
  const DiagnosisSearchWidget({Key? key}) : super(key: key);

  @override
  _DiagnosisSearchWidgetState createState() => _DiagnosisSearchWidgetState();
}

class _DiagnosisSearchWidgetState extends State<DiagnosisSearchWidget> {
  String? _selectedDiagnosis;

  @override
  void initState() {
    super.initState();
    final statsProvider = Provider.of<StatisticsProvider>(context, listen: false);
    if (statsProvider.uniqueDiagnoses.isEmpty) {
      statsProvider.fetchAllUniqueDiagnoses();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StatisticsProvider>(
      builder: (context, statisticsProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Search Patients by Diagnosis',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Diagnosis dropdown
              DropdownButton<String>(
                isExpanded: true,
                value: _selectedDiagnosis,
                hint: const Text('Select Diagnosis'),
                items: statisticsProvider.uniqueDiagnoses.map((diagnosis) {
                  return DropdownMenuItem<String>(
                    value: diagnosis,
                    child: Text(diagnosis),
                  );
                }).toList(),
                onChanged: (newDiagnosis) {
                  setState(() {
                    _selectedDiagnosis = newDiagnosis;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Query button
              ElevatedButton(
                onPressed: _selectedDiagnosis == null
                    ? null
                    : () {
                  statisticsProvider.fetchQueriedPatientsByDiagnosis(_selectedDiagnosis!);
                },
                child: const Text('Query'),
              ),
              const SizedBox(height: 16),

              // A fixed or max-size box for the patients list
              Expanded(
                child: Container(
                  // style or color if needed
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: statisticsProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : statisticsProvider.queriedPatients.isEmpty
                      ? const Center(child: Text('No data found'))
                      : ListView.builder(
                    itemCount: statisticsProvider.queriedPatients.length,
                    itemBuilder: (context, index) {
                      final patient = statisticsProvider.queriedPatients[index];
                      return InkWell(
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/patient/appointments',
                            arguments: patient.id,
                          );
                        },
                        child: ListTile(
                          title: Text(patient.name),
                          subtitle: Text('EGN: ${patient.egn}'),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
