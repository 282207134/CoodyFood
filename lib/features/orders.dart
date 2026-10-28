import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/catalog.dart';
import '../models/food.dart';
import '../state/app_state.dart';
import '../ui/components.dart';
import 'restaurant.dart';

class MapView extends StatelessWidget {
  const MapView({super.key, this.tracking = false, this.onRestaurant});
  final bool tracking;
  final ValueChanged<String>? onRestaurant;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (c, size) => Stack(
      fit: StackFit.expand,
      children: [
        const FoodImage(35, radius: 0),
        if (tracking) CustomPaint(painter: _RoutePainter()),
        Positioned(
          left: size.maxWidth * .3,
          top: size.maxHeight * .25,
          child: IconButton(
            tooltip: 'Starbucks',
            onPressed: () => onRestaurant?.call('starbucks'),
            icon: const Icon(
              Icons.location_on_rounded,
              color: CoodyColors.primary,
              size: 34,
            ),
          ),
        ),
        Positioned(
          left: size.maxWidth * .64,
          top: size.maxHeight * .62,
          child: IconButton(
            tooltip: tracking ? 'Delivery location' : 'Domino’s',
            onPressed: () => onRestaurant?.call('dominos'),
            icon: Icon(
              tracking ? Icons.home_rounded : Icons.location_on_rounded,
              color: tracking ? const Color(0xFF6554C0) : CoodyColors.primary,
              size: 32,
            ),
          ),
        ),
        if (tracking)
          Positioned(
            left: size.maxWidth * .5,
            top: size.maxHeight * .46,
            child: const EmojiTile('🛵', size: 34),
          ),
      ],
    ),
  );
}

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * .36, size.height * .36)
      ..lineTo(size.width * .42, size.height * .36)
      ..lineTo(size.width * .42, size.height * .48)
      ..lineTo(size.width * .56, size.height * .48)
      ..lineTo(size.width * .56, size.height * .66)
      ..lineTo(size.width * .7, size.height * .66);
    canvas.drawPath(
      path,
      Paint()
        ..color = CoodyColors.primary
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DiscoverPage extends StatefulWidget {
  const DiscoverPage({super.key});
  @override
  State<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends State<DiscoverPage> {
  String selected = 'starbucks', query = '';
  @override
  Widget build(BuildContext context) => PageFrame(
    tab: 1,
    body: Column(
      children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(35, 16, 35, 22),
          child: SearchBox(
            hint: 'Search a Location',
            onChanged: (q) => setState(() => query = q),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: MapView(
                  onRestaurant: (id) => setState(() => selected = id),
                ),
              ),
              Positioned(
                left: 20,
                top: 18,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: label(
                    'Nearby in Hanoi',
                    size: 12,
                    color: CoodyColors.muted,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: restaurants
                        .where(
                          (r) =>
                              [
                                selected,
                                selected == 'starbucks'
                                    ? 'dominos'
                                    : 'starbucks',
                              ].contains(r.id) &&
                              '${r.name} Hanoi'.toLowerCase().contains(
                                query.toLowerCase(),
                              ),
                        )
                        .map(
                          (r) => Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Surface(
                              child: InkWell(
                                onTap: () {
                                  final s = AppScope.of(context);
                                  if (!s.selectRestaurant(r.id)) {
                                    toast(
                                      context,
                                      'Finish your current order before changing restaurants.',
                                    );
                                    return;
                                  }
                                  go(context, '302', arguments: r.id);
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on_rounded,
                                          color: CoodyColors.primary,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: label(
                                            r.name,
                                            size: 20,
                                            weight: FontWeight.w500,
                                          ),
                                        ),
                                        RatingPill(r.rating),
                                      ],
                                    ),
                                    gap(14),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 30),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          label(
                                            'Mon – Sun  (8 AM – 10 PM)',
                                            size: 12,
                                            color: CoodyColors.muted,
                                          ),
                                          gap(8),
                                          label(
                                            '${r.distance} km  ·  ${r.deliveryCents == 0 ? 'Free shipping' : '${money(r.deliveryCents)} delivery'}',
                                            size: 12,
                                            color: CoodyColors.muted,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class DiscoverDetailPage extends StatelessWidget {
  const DiscoverDetailPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context), r = restaurantById(s.selectedRestaurant);
    return PageFrame(
      title: r.name,
      bottom: PrimaryButton(
        'Order from ${r.name}',
        () => go(context, r.id == 'starbucks' ? '213' : '214'),
      ),
      body: ListView(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  child: label(
                    'Open  ·  Hanoi, Vietnam',
                    size: 12,
                    color: CoodyColors.green,
                  ),
                ),
                RatingPill(r.rating),
              ],
            ),
          ),
          const ReviewsContent(),
        ],
      ),
    );
  }
}

class OrdersPage extends StatelessWidget {
  const OrdersPage({super.key, this.history = false});
  final bool history;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PageFrame(
      tab: 2,
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(35, 16, 35, 0),
            child: Column(
              children: [
                SearchBox(onTap: () => go(context, '211')),
                gap(12),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => go(context, '401', replace: true),
                        child: Text(
                          'Ongoing',
                          style: TextStyle(
                            color: history
                                ? CoodyColors.muted
                                : CoodyColors.primary,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => go(context, '402', replace: true),
                        child: Text(
                          'History',
                          style: TextStyle(
                            color: history
                                ? CoodyColors.primary
                                : CoodyColors.muted,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: history
                ? _history(context, s)
                : !s.activeOrder
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(35),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const EmojiTile('🛍️'),
                          gap(24),
                          label(
                            'No ongoing orders',
                            size: 22,
                            weight: FontWeight.w700,
                          ),
                          gap(12),
                          const Text(
                            'Your next delicious meal is just a few taps away.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: CoodyColors.muted),
                          ),
                          gap(24),
                          PrimaryButton(
                            'Find something delicious',
                            () => go(context, '201', replace: true),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      const SizedBox(
                        height: 210,
                        child: MapView(tracking: true),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15),
                        child: Surface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const EmojiTile('🍱', size: 44),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        label(
                                          'Your food is on its way',
                                          weight: FontWeight.w500,
                                        ),
                                        label(
                                          'Coming within 15 mins',
                                          size: 12,
                                          color: CoodyColors.muted,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        label(
                                          restaurantById(s.activeRestaurant)
                                              .name,
                                          weight: FontWeight.w500,
                                        ),
                                        gap(4),
                                        label(
                                          '${money(s.activeTotal)} · ${s.activeItems.fold<int>(0, (n, x) => n + x.quantity)} items',
                                          size: 12,
                                          color: CoodyColors.muted,
                                        ),
                                      ],
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => showDialog<void>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        title: Text('Order #${s.orderNumber}'),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            for (final l in s.activeItems)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  bottom: 12,
                                                ),
                                                child: label(
                                                  '${l.quantity} × ${foodById(l.foodId).name}',
                                                ),
                                              ),
                                            label(
                                              'Total: ${money(s.activeTotal)}',
                                            ),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(c),
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      ),
                                    ),
                                    child: const Text(
                                      'Detail Order',
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              for (final (i, t, time) in [
                                (0, 'Order', '07:45'),
                                (1, 'Confirming', '07:55'),
                                (2, 'Delivery', '08:01'),
                                (3, 'Pickup', ''),
                                (4, 'Done', ''),
                              ])
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        i < 3
                                            ? Icons.check_circle_rounded
                                            : Icons
                                                  .radio_button_unchecked_rounded,
                                        size: 22,
                                        color: i < 3
                                            ? CoodyColors.primary
                                            : const Color(0xFFDFE1E6),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: label(
                                          t,
                                          color: i < 3
                                              ? CoodyColors.ink
                                              : CoodyColors.muted,
                                        ),
                                      ),
                                      label(
                                        time,
                                        size: 12,
                                        color: CoodyColors.muted,
                                      ),
                                    ],
                                  ),
                                ),
                              gap(20),
                              PrimaryButton('Mark as delivered', () {
                                s.activeOrder = false;
                                s.completedOrders++;
                                s.commit();
                                go(context, '402', replace: true);
                              }),
                              gap(8),
                              label(
                                'Demo delivery timeline',
                                size: 11,
                                color: CoodyColors.muted,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _history(BuildContext context, AppState s) => ListView(
    padding: const EdgeInsets.all(15),
    children: [
      for (final (r, amount) in [
        (restaurants[0], 998),
        (restaurants[2], s.activeTotal == 0 ? 898 : s.activeTotal),
        (restaurants[4], 1298),
      ])
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: label('Food', weight: FontWeight.w500)),
                    label('Completed', size: 12, color: CoodyColors.green),
                  ],
                ),
                gap(18),
                Row(
                  children: [
                    FoodImage(r.image, width: 78, height: 78),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          label(r.name, size: 20, weight: FontWeight.w500),
                          gap(5),
                          label(
                            'Hanoi, Vietnam',
                            size: 12,
                            color: CoodyColors.muted,
                          ),
                          gap(7),
                          label(
                            '${money(amount)}  ·  2 items',
                            size: 13,
                            color: CoodyColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                gap(18),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: CoodyColors.background,
                          foregroundColor: CoodyColors.ink,
                        ),
                        onPressed: () => go(context, '403'),
                        child: const Text('Rate'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          s.reorder(restaurantId: r.id);
                          go(context, '218');
                        },
                        child: const Text('Re-Order'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    ],
  );
}

class RatingPage extends StatefulWidget {
  const RatingPage(this.screen, {super.key});
  final String screen;
  @override
  State<RatingPage> createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int stars = 5;
  final Set<String> tags = {'Friendly'};
  final Map<String, bool> liked = {'beef': true, 'sea': true};
  @override
  Widget build(BuildContext context) {
    final item = widget.screen == '404-item', driver = widget.screen == '403';
    return PageFrame(
      title: item
          ? 'Rate Item'
          : driver
          ? 'Rate Driver'
          : 'Rate Shop',
      white: true,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(item ? 'Submit' : 'Next', () {
            if (item) {
              final s = AppScope.of(context);
              s.completedOrders++;
              s.commit();
              go(context, '405');
            } else {
              go(context, driver ? '404' : '404-item');
            }
          }),
          if (!driver)
            TextButton(
              onPressed: () => back(context),
              child: const Text('Previous'),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(35),
        children: [
          Center(
            child: driver
                ? const FoodImage(33, width: 80, height: 80, radius: 20)
                : item
                ? const EmojiTile('👍')
                : const FoodImage(2, width: 80, height: 80, radius: 20),
          ),
          gap(24),
          Center(
            child: label(
              item
                  ? 'How do you feel about our food?'
                  : driver
                  ? 'Nguyen Van Linh'
                  : 'Starbucks',
              size: 20,
              weight: FontWeight.w500,
            ),
          ),
          gap(10),
          if (!item) ...[
            Center(
              child: label(
                driver ? 'Delivery Driver' : 'Hanoi, Vietnam',
                size: 12,
                color: CoodyColors.muted,
              ),
            ),
            gap(12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                5,
                (i) => IconButton(
                  tooltip: '${i + 1} stars',
                  onPressed: () => setState(() => stars = i + 1),
                  icon: Icon(
                    i < stars ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: CoodyColors.primary,
                    size: 30,
                  ),
                ),
              ),
            ),
            gap(28),
            for (final t
                in driver
                    ? [
                        'Friendly',
                        'On time',
                        'Clean & neat',
                        'Professional',
                        'Helpful',
                      ]
                    : [
                        'Delicious',
                        'Fast delivery',
                        'Good packaging',
                        'Fresh ingredients',
                        'Friendly service',
                      ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: label(t),
                trailing: Icon(
                  tags.contains(t)
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked,
                  color: tags.contains(t)
                      ? CoodyColors.primary
                      : const Color(0xFFDFE1E6),
                  size: 22,
                ),
                onTap: () => setState(() {
                  if (!tags.add(t)) tags.remove(t);
                }),
              ),
          ] else ...[
            gap(30),
            for (final f in pizzaMenu.take(2))
              Padding(
                padding: const EdgeInsets.only(bottom: 28),
                child: Row(
                  children: [
                    FoodImage(
                      f.image,
                      width: 58,
                      height: 58,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: label(f.name, size: 13, lines: 2)),
                    IconButton(
                      tooltip: 'Like ${f.name}',
                      onPressed: () => setState(() => liked[f.id] = true),
                      icon: Icon(
                        Icons.thumb_up_alt_rounded,
                        color: liked[f.id] == true
                            ? CoodyColors.primary
                            : const Color(0xFFDFE1E6),
                        size: 22,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Dislike ${f.name}',
                      onPressed: () => setState(() => liked[f.id] = false),
                      icon: Icon(
                        Icons.thumb_down_alt_rounded,
                        color: liked[f.id] == false
                            ? CoodyColors.primary
                            : const Color(0xFFDFE1E6),
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class FeedbackSuccessPage extends StatelessWidget {
  const FeedbackSuccessPage({super.key});
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const RatingPage('404-item'),
      Positioned.fill(
        child: ColoredBox(color: Colors.black.withValues(alpha: .35)),
      ),
      Center(
        child: Padding(
          padding: const EdgeInsets.all(35),
          child: Material(
            color: Colors.transparent,
            child: Surface(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const EmojiTile('👍'),
                  gap(24),
                  label(
                    'Your feedback was sent',
                    size: 20,
                    weight: FontWeight.w700,
                  ),
                  gap(12),
                  const Text(
                    'Thanks for your feedback on our service.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: CoodyColors.muted, height: 1.7),
                  ),
                  gap(24),
                  PrimaryButton('Ok', () => go(context, '402', replace: true)),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
