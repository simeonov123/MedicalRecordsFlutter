// lib/screens/doctor/doctor_list_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/doctor_provider.dart';
import '../../widgets/doctor_data_widget.dart';

// lib/screens/doctor/doctor_list_screen.dart

import '../../widgets/doctor_data_widget.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({Key? key}) : super(key: key);

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  late Future<void> _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = _fetchDoctors();
  }

  Future<void> _fetchDoctors() async {
    final doctorProvider = Provider.of<DoctorProvider>(context, listen: false);
    await doctorProvider.fetchDoctors();
  }

  @override
  Widget build(BuildContext context) {
    final doctorProvider = Provider.of<DoctorProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor List'),
      ),
      body: FutureBuilder<void>(
        future: _fetchDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: doctorProvider.doctors.length,
              itemBuilder: (context, index) {
                final doctor = doctorProvider.doctors[index];
                return DoctorDataWidget(doctor: doctor);
              },
            );
          }
        },
      ),
    );
  }
}
