import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final TextEditingController? controller; // Added controller parameter

  const CustomTextField({
    Key? key,
    required this.label,
    this.obscureText = false,
    this.validator,
    this.onSaved,
    this.controller, // Accept controller
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller, // Attach the controller
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        obscureText: obscureText,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }
}
