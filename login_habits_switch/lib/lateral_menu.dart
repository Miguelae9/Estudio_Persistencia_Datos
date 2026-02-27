import 'package:flutter/material.dart';

class LateralMenu extends StatefulWidget {
  const LateralMenu({super.key});

  @override
  State<LateralMenu> createState() => _LateralMenuState();
}

class _LateralMenuState extends State<LateralMenu> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Ink(
          child: ListTile(
            title: Text("Home"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, "/home");
            },
          ),
        ),

        Ink(
          child: ListTile(
            title: Text("Habits"),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, "/habits");
            },
          ),
        ),
      ],
    );
  }
}