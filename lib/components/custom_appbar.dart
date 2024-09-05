import 'package:flutter/material.dart';

class CustomAppbar extends StatelessWidget {
  final Widget child;
  final bool? noContent;
  final Widget? noContentChild;
  double height;
  CustomAppbar({super.key, required this.child, this.noContent, this.noContentChild, this.height = 170});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: height),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOut,
      builder: (BuildContext context, double value, Widget? child) => Container(
        height: value,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30),
          ),
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color.fromARGB(255, 62, 66, 64)
              : Theme.of(context).colorScheme.primary,
        ),
        child: noContent == true ? noContentChild : this.child,
      ),
    );
  }
}
