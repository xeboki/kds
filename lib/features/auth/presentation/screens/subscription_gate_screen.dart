import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/kds_theme.dart';
import '../providers/auth_providers.dart';

/// Shown when the authenticated session has a free plan or inactive subscription.
/// Staff are logged in but the KDS feature is blocked until the merchant upgrades.
class SubscriptionGateScreen extends ConsumerWidget {
  const SubscriptionGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kitchen = context.kitchen;
    final colors = context.appColors;
    final session = ref.watch(sessionProvider);
    final planLabel = session?.subscriptionPlan.isNotEmpty == true
        ? session!.subscriptionPlan
        : 'Free Plan';

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        actions: [
          TextButton.icon(
            onPressed: () async {
              await ref.read(sessionProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            icon: Icon(Icons.logout, size: 16, color: colors.onDisabled),
            label: Text('Sign out',
                style: TextStyle(color: colors.onDisabled, fontSize: 13)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Lock icon
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: kitchen.ageRed.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: kitchen.ageRed.withValues(alpha: 0.35), width: 1.5),
                ),
                child: Icon(Icons.lock_outline_rounded,
                    size: 40, color: kitchen.ageRed),
              ),
              const SizedBox(height: 24),

              // Headline
              Text(
                'Paid Subscription Required',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: colors.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),

              // Body
              Text(
                'The Xeboki KDS requires an active paid plan.\n'
                'Free accounts cannot access kitchen display features.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: colors.textPrimary.withValues(alpha: 0.55), fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 20),

              // Current plan chip
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline,
                        size: 14, color: colors.onDisabled),
                    const SizedBox(width: 6),
                    Text(
                      'Current plan: $planLabel',
                      style: TextStyle(
                          color: colors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Upgrade button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton.icon(
                  onPressed: () {
                    // The KDS is a standalone tablet app — direct staff to the
                    // Manager dashboard to upgrade. Show a dialog with instructions.
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        backgroundColor: colors.surface,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        title: Text('Upgrade Your Plan',
                            style: TextStyle(
                                color: colors.textPrimary,
                                fontWeight: FontWeight.w700)),
                        content: Text(
                          'To upgrade, sign in to the Xeboki Manager app or '
                          'visit xeboki.com/xe-pos on any browser.\n\n'
                          'Once your plan is upgraded, sign out and sign back in '
                          'to activate the KDS.',
                          style:
                              TextStyle(color: colors.textSecondary, height: 1.5),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: Text('Got it',
                                style: TextStyle(color: colors.primary)),
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.rocket_launch_outlined, size: 18),
                  label: const Text('Upgrade Plan',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                  style: FilledButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
