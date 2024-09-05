import 'package:flutter/material.dart';

class CustomTextfiled extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final TextInputType? keyboardType;
  const CustomTextfiled({super.key, this.controller, this.label, this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
        focusedBorder: OutlineInputBorder(
          borderSide:BorderSide(color: Theme.of(context).colorScheme.tertiary), 
          borderRadius: BorderRadius.circular(20)
        ),
      ),
    );
  }
}
