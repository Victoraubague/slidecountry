import 'package:flutter/material.dart';

class SlidePage extends StatelessWidget {
  const SlidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('⚡️ Page Éclair'),
      ),
      body: const Center(
        child: Text(
          'Ceci est la page avec un éclair ⚡️',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
