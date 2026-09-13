import 'package:flutter/material.dart';

void main() => runApp(const PeaceBreakApp());

class PeaceBreakApp extends StatelessWidget {
  const PeaceBreakApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Peace Break',
      home: Scaffold(body: Center(child: Text('Peace Break'))),
    );
  }
}
