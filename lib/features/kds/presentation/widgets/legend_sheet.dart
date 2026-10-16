import 'package:flutter/material.dart';

import '../../../../core/theme/kds_theme.dart';
import '../../domain/line_meanings.dart';
import '../../domain/models/kitchen_order.dart';

/// What everything on the board means.
///
/// A kitchen screen is read by whoever is on shift, including someone on
/// their first night, and almost all of its state is carried by a coloured
/// dot, a strike-through or a three-letter badge. None of that is labelled
/// anywhere, and a cook cannot look it up mid-service.
///
/// The timer rungs are the screen's **own** configured minutes rather than
/// the defaults, so the legend cannot drift from what the board is doing.
void showLegendSheet(
  BuildContext context, {
  required int urgentMins,
  required int veryUrgentMins,
}) {
  final colors = context.appColors;
  final kitchen = context.kitchen;
  final criticalMins = veryUrgentMins + (veryUrgentMins - urgentMins);

  showModalBottomSheet(
    context: context,
    backgroundColor: colors.surface,
    isScrollControlled: true,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, controller) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: ListView(
          controller: controller,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, size: 20, color: colors.primary),
                const SizedBox(width: 8),
                Text('What the board is telling you',
                    style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700)),
                const Spacer(),
                IconButton(
                  tooltip: 'Close',
                  icon: Icon(Icons.close, color: colors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),

            _Heading('The dot beside a line'),
            _Row(
                dot: kitchen.statusPending,
                text: statusMeaning(KitchenItemStatus.pending)),
            _Row(
                dot: kitchen.statusPreparing,
                text: statusMeaning(KitchenItemStatus.preparing)),
            _Row(
                dot: kitchen.statusReady,
                example: 'Lamb Chops',
                text: statusMeaning(KitchenItemStatus.completed)),
            _Row(
                dot: kitchen.ageAmber,
                badge: 'HELD',
                badgeColor: kitchen.ageAmber,
                text: statusMeaning(KitchenItemStatus.held)),

            const SizedBox(height: 18),
            _Heading('Badges'),
            _Row(
                badge: "86'd",
                badgeColor: kitchen.ageRed,
                text: eightySixMeaning),
            _Row(
                badge: 'VOID',
                badgeColor: kitchen.ageRed,
                text: voidMeaning),
            _Row(
                badge: 'NEW',
                badgeColor: kitchen.statusReady,
                text: newlyAddedMeaning),
            _Row(
                badge: 'MOD',
                badgeColor: kitchen.ageAmber,
                text: modifiedMeaning),

            const SizedBox(height: 18),
            _Heading('The timer on each ticket'),
            _Row(
                swatch: kitchen.ageOk,
                text: 'Under $urgentMins minutes — on time'),
            _Row(
                swatch: kitchen.ageAmber,
                text: '$urgentMins minutes and over — getting on'),
            _Row(
                swatch: kitchen.ageRed,
                text: '$veryUrgentMins minutes and over — late'),
            _Row(
                swatch: kitchen.ageUrgent,
                text: '$criticalMins minutes and over — badly late'),
            _Row(
                swatch: colors.info,
                icon: Icons.schedule,
                text: 'Counting down, as "in 2:15:00" — this one was asked '
                    'for a later time and is not due yet'),

            const SizedBox(height: 18),
            _Heading('On the ticket'),
            _Row(
                text: 'S1, S2 … — the seat each dish goes to',
                mono: 'S1'),
            _Row(
                text: 'COURSE 1, COURSE 2 … — fire a held course with FIRE',
                mono: 'FIRE'),
            _Row(
                text: 'More lines than the card can fit. Tap it to open the '
                    'whole ticket — nothing is ever hidden without saying so',
                mono: '+5 more'),
            _Row(
                text: 'Clears the ticket off the board. Recall it from the '
                    'arrow at the top if you bump one by mistake',
                mono: 'BUMP'),
            const SizedBox(height: 10),
          ],
        ),
      ),
    ),
  );
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text.toUpperCase(),
            style: TextStyle(
                color: context.appColors.textSecondary,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
      );
}

class _Row extends StatelessWidget {
  const _Row({
    required this.text,
    this.dot,
    this.swatch,
    this.badge,
    this.badgeColor,
    this.mono,
    this.icon,
    this.example,
  });

  final String text;
  final Color? dot;
  final Color? swatch;
  final String? badge;
  final Color? badgeColor;
  final String? mono;
  final IconData? icon;

  /// A struck-through sample of a line, shown beside the explanation.
  ///
  /// The strike used to be applied to the explanation itself, which crossed
  /// out the sentence telling you what crossing out means.
  final String? example;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A fixed-width gutter so every example lines up down the page.
          SizedBox(
            width: 84,
            child: Wrap(
              spacing: 5,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (dot != null)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 5),
                    decoration:
                        BoxDecoration(shape: BoxShape.circle, color: dot),
                  ),
                if (swatch != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: swatch!.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border:
                          Border.all(color: swatch!.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon ?? Icons.timer_outlined,
                            size: 11, color: swatch),
                        const SizedBox(width: 3),
                        Text('00:00',
                            style: TextStyle(
                                color: swatch,
                                fontSize: 10,
                                fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                if (badge != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: badgeColor!.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(badge!,
                        style: TextStyle(
                            color: badgeColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w700)),
                  ),
                if (example != null)
                  Text(example!,
                      style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: colors.textSecondary)),
                if (mono != null)
                  Text(mono!,
                      style: TextStyle(
                          color: colors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: colors.textSecondary,
                fontSize: 13,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
