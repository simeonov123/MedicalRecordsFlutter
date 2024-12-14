// lib/screens/admin/user_management_panel.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/user_provider.dart';
import '../../domain/user.dart';
import '../../widgets/custom_button.dart';

class UserManagementPanel extends StatefulWidget {
  const UserManagementPanel({Key? key}) : super(key: key);

  @override
  _UserManagementPanelState createState() => _UserManagementPanelState();
}

class _UserManagementPanelState extends State<UserManagementPanel> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.fetchUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authProvider.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: userProvider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : userProvider.error != null
            ? Center(child: Text('Error: ${userProvider.error}'))
            : ListView.builder(
          itemCount: userProvider.users.length,
          itemBuilder: (context, index) {
            User user = userProvider.users[index];
            return ListTile(
              title: Text(user.username),
              subtitle: Text('Email: ${user.email}'),
              trailing: DropdownButton<String>(
                value: user.role,
                items: <String>['admin', 'doctor', 'patient']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newRole) async {
                  if (newRole != null && newRole != user.role) {
                    bool success = await userProvider.updateUserRole(user.id, newRole);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Role updated successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to update role')),
                      );
                    }
                  }
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
