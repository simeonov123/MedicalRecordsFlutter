import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../provider/user_provider.dart';
import '../../domain/user.dart';

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

    // The recognized roles that we display in the dropdown
    final validRoles = <String>['admin', 'doctor', 'patient'];

    // 'user' role is the placeholder for doctor candidates
    List<User> doctorCandidates =
    userProvider.users.where((u) => u.role == 'user').toList();
    List<User> normalUsers =
    userProvider.users.where((u) => u.role != 'user').toList();

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
            : SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Candidates
              const Text(
                'Doctor Candidates',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: doctorCandidates.length,
                itemBuilder: (context, index) {
                  User user = doctorCandidates[index];
                  return ListTile(
                    title: Text('${user.username} (${user.email})'),
                    subtitle: Text('Role: ${user.role}'),
                    trailing: ElevatedButton(
                      child: const Text('Approve Doctor'),
                      onPressed: () async {
                        bool success = await userProvider.updateUserRole(user.id, 'doctor');
                        if (success) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Role updated successfully')),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to update role')),
                          );
                        }
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Other Users
              const Text(
                'Other Users',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: normalUsers.length,
                itemBuilder: (context, index) {
                  User user = normalUsers[index];
                  bool canShowDropdown = validRoles.contains(user.role);

                  return ListTile(
                    title: Text('${user.username} (${user.email})'),
                    subtitle: Text('Role: ${user.role}'),
                    leading: user.emailVerified
                        ? const Icon(Icons.check_circle, color: Colors.green)
                        : IconButton(
                      icon: const Icon(Icons.info_outline),
                      tooltip: 'Verify Email',
                      onPressed: () async {
                        bool verified = await userProvider.verifyUserEmail(user.id, true);
                        if (verified) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Email verified successfully')),
                          );
                        }
                      },
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete),
                          tooltip: 'Delete User',
                          onPressed: () async {
                            bool deleted = await userProvider.deleteUser(user.id);
                            if (deleted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User deleted successfully')),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to delete user')),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 8),
                        if (canShowDropdown)
                          DropdownButton<String>(
                            value: user.role,
                            items: validRoles.map((String value) {
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
                          )
                        else
                          Text('Role: ${user.role}'),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
