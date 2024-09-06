import 'package:flutter/material.dart';

class LikePage extends StatelessWidget {
  const LikePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('❤️ Page Cœur'),
      ),
      body: const Center(
        child: Text(
          'Ceci est la page avec un cœur ❤️',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
