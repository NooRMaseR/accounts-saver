import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final Function() onPressed;
  final Widget buttonLabel;
  final Widget? icon;
  const CustomElevatedButton(
      {super.key,
      this.icon,
      required this.buttonLabel,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.secondary)
      ),
      onPressed: onPressed,
      label: buttonLabel,
      icon: icon,
    );
  }
}
