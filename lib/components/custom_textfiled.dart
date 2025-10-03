import 'package:flutter/material.dart';

class CustomTextfiled extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final TextInputType? keyboardType;
  final TextInputAction? action;
  final void Function(String value)? onSubmit;
  const CustomTextfiled({
    super.key,
    this.controller,
    this.label,
    this.keyboardType,
    this.action = TextInputAction.next,
    this.onSubmit
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: action,
      onSubmitted: action == TextInputAction.done ? onSubmit : null,
      decoration: InputDecoration(
        labelText: label,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
