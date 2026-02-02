import 'package:flutter/material.dart';
import '../home/packs_screen.dart';

class PacksListScreen extends StatelessWidget {
  const PacksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Learning Packs')),
      body: const SafeArea(child: PacksScreen()),
    );
  }
}
