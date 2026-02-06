import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../state/app_state_scope.dart';

class PacksScreen extends StatelessWidget {
  const PacksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppStateScope.of(context);
    final packs = state.packs;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          'Learning Packs',
          style: Theme.of(context)
              .textTheme
              .headlineLarge
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Text(
          'Personalized packs based on homework.',
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: LearnyColors.slateMedium),
        ),
        const SizedBox(height: 16),
        ...packs.map(
          (pack) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: pack.color.withValues(alpha: 0.2),
                child: Icon(pack.icon, color: pack.color),
              ),
              title: Text(pack.title),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${pack.itemCount} items • ${pack.minutes} min'),
                  if (pack.conceptsTotal > 0) ...[
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: pack.progress,
                        minHeight: 6,
                        backgroundColor: LearnyColors.neutralSoft,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          pack.progress >= 0.8
                              ? LearnyColors.mintPrimary
                              : pack.progress >= 0.5
                                  ? LearnyColors.skyPrimary
                                  : LearnyColors.sunshine,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${(pack.progress * 100).round()}% mastery • ${pack.conceptsMastered}/${pack.conceptsTotal} concepts',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: LearnyColors.slateMedium,
                          ),
                    ),
                  ],
                ],
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                state.selectPack(pack.id);
                Navigator.pushNamed(context, AppRoutes.packDetail);
              },
            ),
          ),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.packSession),
          child: const Text('Start a Session'),
        ),
        const SizedBox(height: 8),
        OutlinedButton(
          onPressed: () => Navigator.pushNamed(context, AppRoutes.library),
          child: const Text('View Document Library'),
        ),
      ],
    );
  }
}
