import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import '../home/packs_screen.dart';

class PacksListScreen extends StatelessWidget {
  const PacksListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(L10n.of(context).packsListTitle)),
      body: const SafeArea(child: PacksScreen()),
    );
  }
}
