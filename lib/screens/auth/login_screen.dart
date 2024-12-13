// lib/screens/auth/login_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../provider/auth_provider.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomTextField(
                  label: 'Username or Email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username or email';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _username = value!;
                  },
                ),
                CustomTextField(
                  label: 'Password',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _password = value!;
                  },
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                const SizedBox(height: 20),
                _isLoading
                    ? const CircularProgressIndicator()
                    : CustomButton(
                  label: 'Login',
                  onPressed: _login,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/signup');
                  },
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      bool success = await Provider.of<AuthProvider>(context, listen: false)
          .login(_username, _password);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        List<String> roles =
            Provider.of<AuthProvider>(context, listen: false).roles;

        if (roles.contains('admin')) {
          Navigator.pushReplacementNamed(context, '/admin/user-management');
        } else if (roles.contains('doctor')) {
          Navigator.pushReplacementNamed(context, '/doctor/dashboard');
        } else if (roles.contains('patient')) {
          Navigator.pushReplacementNamed(context, '/patient/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No role assigned. Contact admin.')),
          );
        }
      } else {
        setState(() {
          _errorMessage = 'Invalid username or password';
        });
      }
    }
  }
}
