import 'package:flutter/material.dart';

import '../core/theme.dart';
import '../data/catalog.dart';
import '../models/food.dart';
import '../state/app_state.dart';
import '../ui/components.dart';

class RestaurantPage extends StatefulWidget {
  const RestaurantPage(this.screen, {super.key});
  final int screen;
  @override
  State<RestaurantPage> createState() => _RestaurantPageState();
}

class _RestaurantPageState extends State<RestaurantPage> {
  bool reviews = false;
  String menuCategory = 'All';
  @override
  void initState() {
    super.initState();
    reviews = widget.screen == 215;
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    final r = widget.screen == 213 || widget.screen == 215
        ? restaurants[0]
        : restaurantById(s.selectedRestaurant);
    final menu = menuFor(r.id);
    final selection = menu
        .where((f) => menuCategory == 'All' || f.category == menuCategory)
        .toList();
    return PageFrame(
      bottom: s.count > 0
          ? PrimaryButton(
              'View Order (${s.count})  ·  ${money(s.total)}',
              () => go(context, '217'),
            )
          : null,
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1.78,
                child: FoodImage(r.image, radius: 0),
              ),
              Positioned(
                left: 20,
                top: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    tooltip: 'Back',
                    onPressed: () => back(context),
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: CoodyColors.ink,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                top: 16,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    tooltip: 'Save restaurant',
                    onPressed: () => s.favorite(r.id),
                    icon: Icon(
                      s.favorites.contains(r.id)
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: CoodyColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: label(
                              r.name,
                              size: 22,
                              weight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_user_rounded,
                            size: 18,
                            color: CoodyColors.green,
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        s.takeaway = !s.takeaway;
                        s.commit();
                      },
                      child: Text(
                        s.takeaway ? 'Delivery' : 'Take Away',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                label(
                  'Open  ·  Hanoi, Vietnam',
                  size: 12,
                  color: CoodyColors.muted,
                ),
                const Divider(),
                Wrap(
                  spacing: 14,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    RatingPill(r.rating),
                    label(
                      '${r.distance} km',
                      size: 12,
                      color: CoodyColors.muted,
                    ),
                    label(
                      s.takeaway
                          ? 'Pickup in 15 mins'
                          : r.deliveryCents == 0
                          ? 'Free shipping'
                          : 'Delivery ${money(r.deliveryCents)}',
                      size: 12,
                      color: CoodyColors.muted,
                    ),
                  ],
                ),
                gap(18),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () {
                    s.voucher = 'COODY40';
                    s.commit();
                    toast(context, 'COODY40 applied: 40% off your food.');
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: CoodyColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_offer_outlined,
                          color: CoodyColors.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: label('40% off with COODY40', size: 12),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          size: 18,
                          color: CoodyColors.muted,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => reviews = false),
                    child: Text(
                      'Menu',
                      style: TextStyle(
                        color: !reviews
                            ? CoodyColors.primary
                            : CoodyColors.muted,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => reviews = true),
                    child: Text(
                      'Review',
                      style: TextStyle(
                        color: reviews
                            ? CoodyColors.primary
                            : CoodyColors.muted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (reviews)
            const ReviewsContent()
          else
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(30, 20, 30, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SectionTitle('Popular Items'),
                  gap(16),
                  SizedBox(
                    height: 224,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: menu.take(3).length,
                      separatorBuilder: (_, _) => const SizedBox(width: 16),
                      itemBuilder: (c, i) {
                        final f = menu[i];
                        return SizedBox(
                          width: 122,
                          child: InkWell(
                            onTap: () {
                              if (s.selectedRestaurant != r.id &&
                                  !s.selectRestaurant(r.id)) {
                                toast(
                                  context,
                                  'Finish or clear your current order first.',
                                );
                                return;
                              }
                              go(context, '216', arguments: f.id);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                FoodImage(
                                  f.image,
                                  width: 122,
                                  height: 122,
                                  fit: BoxFit.contain,
                                ),
                                gap(8),
                                label(
                                  f.name,
                                  size: 13,
                                  weight: FontWeight.w500,
                                  lines: 2,
                                ),
                                gap(6),
                                label(
                                  money(f.cents),
                                  size: 13,
                                  color: CoodyColors.primary,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: 44,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: ['All', ...menu.map((f) => f.category).toSet()]
                          .map(
                            (c) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(c),
                                selected: menuCategory == c,
                                onSelected: (_) =>
                                    setState(() => menuCategory = c),
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  gap(24),
                  for (final f in selection)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: InkWell(
                        onTap: () {
                          if (s.selectedRestaurant != r.id &&
                              !s.selectRestaurant(r.id)) {
                            toast(
                              context,
                              'Finish or clear your current order first.',
                            );
                            return;
                          }
                          go(context, '216', arguments: f.id);
                        },
                        child: Row(
                          children: [
                            FoodImage(
                              f.image,
                              width: 64,
                              height: 64,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  label(
                                    f.name,
                                    size: 14,
                                    weight: FontWeight.w500,
                                    lines: 2,
                                  ),
                                  gap(4),
                                  label(
                                    money(f.cents),
                                    color: CoodyColors.muted,
                                    size: 12,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.add_circle_rounded,
                              color: CoodyColors.primary,
                              size: 22,
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
}

class ReviewsContent extends StatelessWidget {
  const ReviewsContent({super.key});
  @override
  Widget build(BuildContext context) => Container(
    color: Colors.white,
    padding: const EdgeInsets.all(30),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Surface(
          color: CoodyColors.peach,
          child: Column(
            children: [
              label(
                '4.5',
                size: 40,
                weight: FontWeight.w700,
                color: CoodyColors.primary,
              ),
              label('★★★★★', size: 22, color: CoodyColors.primary),
              gap(6),
              label('Based on 120 reviews', size: 12, color: CoodyColors.muted),
              gap(20),
              for (var i = 5; i > 0; i--)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    children: [
                      label('$i', size: 12),
                      const SizedBox(width: 10),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: i == 5
                              ? .72
                              : i == 4
                              ? .2
                              : .04,
                          color: CoodyColors.primary,
                          backgroundColor: Colors.white,
                          minHeight: 5,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(width: 10),
                      label(
                        i == 5
                            ? '86'
                            : i == 4
                            ? '24'
                            : '3',
                        size: 11,
                        color: CoodyColors.muted,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        gap(26),
        const SectionTitle('People Reviews'),
        gap(20),
        for (final (i, n, d, t) in [
          (
            28,
            'Julia Johnson',
            'Today, 10:24',
            'Fresh ingredients and delicious food. Everything arrived on time!',
          ),
          (
            29,
            'Thomas Noah',
            'Today, 09:15',
            'Really enjoyed the coffee. Friendly service and carefully packed.',
          ),
          (
            33,
            'Phuc Anh',
            'Yesterday',
            'A lovely treat. I will definitely order again.',
          ),
        ]) ...[
          Row(
            children: [
              FoodImage(i, width: 40, height: 40, radius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label(n, weight: FontWeight.w500),
                    label('★★★★★', color: CoodyColors.primary, size: 13),
                  ],
                ),
              ),
              label(d, size: 10, color: CoodyColors.muted),
            ],
          ),
          gap(12),
          label(t, size: 13, color: CoodyColors.muted),
          gap(18),
          if (i == 33)
            Row(
              children: [
                for (final image in [30, 31, 32])
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FoodImage(image, height: 80),
                    ),
                  ),
              ],
            ),
          const Divider(),
        ],
      ],
    ),
  );
}

class ItemPage extends StatefulWidget {
  const ItemPage({super.key, this.foodId = 'beef'});
  final String foodId;
  @override
  State<ItemPage> createState() => _ItemPageState();
}

class _ItemPageState extends State<ItemPage> {
  int quantity = 1;
  bool cheese = false, border = false;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context), f = foodById(widget.foodId);
    final price = (f.cents + (cheese ? 99 : 0) + (border ? 199 : 0)) * quantity;
    return Stack(
      children: [
        RestaurantPage(coffeeMenu.contains(f) ? 213 : 214),
        Positioned.fill(
          child: ColoredBox(color: Colors.black.withValues(alpha: .3)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: CoodyColors.background,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SafeArea(
              top: false,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * .72,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Center(
                              child: Container(
                                width: 40,
                                height: 5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDFE1E6),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close item',
                            onPressed: () => back(context),
                            icon: const Icon(Icons.close_rounded, size: 20),
                          ),
                        ],
                      ),
                      Surface(
                        child: Row(
                          children: [
                            FoodImage(
                              f.image,
                              width: 82,
                              height: 82,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  label(
                                    f.name,
                                    weight: FontWeight.w500,
                                    lines: 2,
                                  ),
                                  gap(6),
                                  label(
                                    money(f.cents),
                                    color: CoodyColors.primary,
                                  ),
                                  QuantityControl(
                                    quantity,
                                    () => setState(
                                      () => quantity = quantity > 1
                                          ? quantity - 1
                                          : 1,
                                    ),
                                    () => setState(() => quantity++),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      gap(12),
                      if (f.category == 'Pizza')
                        Surface(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              label('Topping', weight: FontWeight.w500),
                              const Divider(),
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: label('Add the Cheese'),
                                subtitle: label(
                                  money(99),
                                  size: 12,
                                  color: CoodyColors.muted,
                                ),
                                value: cheese,
                                onChanged: (v) => setState(() => cheese = v!),
                                activeColor: CoodyColors.primary,
                              ),
                              CheckboxListTile(
                                contentPadding: EdgeInsets.zero,
                                title: label('Cheese Border'),
                                subtitle: label(
                                  money(199),
                                  size: 12,
                                  color: CoodyColors.muted,
                                ),
                                value: border,
                                onChanged: (v) => setState(() => border = v!),
                                activeColor: CoodyColors.primary,
                              ),
                            ],
                          ),
                        ),
                      gap(20),
                      PrimaryButton('Add to Order (${money(price)})', () {
                        s.add(f, quantity, cheese: cheese, border: border);
                        back(context);
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Stack(
      children: [
        const RestaurantPage(214),
        Positioned.fill(
          child: ColoredBox(color: Colors.black.withValues(alpha: .3)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: SafeArea(
              top: false,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * .72,
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(30),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: label(
                              'Your Order',
                              size: 20,
                              weight: FontWeight.w700,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Close order',
                            onPressed: () => back(context),
                            icon: const Icon(Icons.close_rounded),
                          ),
                        ],
                      ),
                      gap(12),
                      if (s.cart.isEmpty) ...[
                        gap(24),
                        const EmojiTile('🍽️'),
                        gap(16),
                        label('Your order is empty'),
                        gap(24),
                        PrimaryButton(
                          'Browse restaurants',
                          () => go(context, '201', replace: true),
                        ),
                      ] else ...[
                        for (final l in s.cart) CartItem(l),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            label('Subtotal'),
                            label(money(s.subtotal), weight: FontWeight.w700),
                          ],
                        ),
                        gap(24),
                        PrimaryButton(
                          'Go to Checkout',
                          () => go(context, '218'),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CartItem extends StatelessWidget {
  const CartItem(this.line, {super.key});
  final CartLine line;
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context), f = foodById(line.foodId);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          FoodImage(f.image, width: 62, height: 62, fit: BoxFit.contain),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label(f.name, weight: FontWeight.w500, lines: 2),
                if (line.cheese || line.border)
                  label(
                    [
                      if (line.cheese) 'Extra cheese',
                      if (line.border) 'Cheese border',
                    ].join(', '),
                    size: 11,
                    color: CoodyColors.muted,
                  ),
                gap(5),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  children: [
                    label(
                      money(s.unitPrice(line) * line.quantity),
                      color: CoodyColors.primary,
                    ),
                    QuantityControl(
                      line.quantity,
                      () => s.changeQuantity(line, -1),
                      () => s.changeQuantity(line, 1),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});
  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final voucher = TextEditingController();
  @override
  void dispose() {
    voucher.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PageFrame(
      title: 'Confirm Order',
      bottom: PrimaryButton(
        s.cart.isEmpty
            ? 'Browse restaurants'
            : 'Submit Order  ·  ${money(s.total)}',
        () {
          if (s.cart.isEmpty) {
            go(context, '201', replace: true);
            return;
          }
          s.placeOrder();
          go(context, '221');
        },
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Delivery to'),
                gap(18),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const EmojiTile('📍', size: 44),
                  title: label(
                    s.takeaway
                        ? 'Pickup at ${restaurantById(s.selectedRestaurant).name}'
                        : s.address,
                    weight: FontWeight.w500,
                  ),
                  subtitle: label(
                    s.takeaway
                        ? 'Ready in 15 minutes'
                        : 'Delivery in 20–30 minutes',
                    size: 12,
                    color: CoodyColors.muted,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => go(context, '508'),
                ),
              ],
            ),
          ),
          gap(15),
          Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  restaurantById(s.selectedRestaurant).name,
                  action: 'Add more',
                  onAction: () => go(
                    context,
                    s.selectedRestaurant == 'starbucks' ? '213' : '214',
                  ),
                ),
                gap(10),
                if (s.cart.isEmpty)
                  label('Your order is empty. Add something delicious.')
                else
                  ...s.cart.map((l) => CartItem(l)),
                const Divider(),
                _total('Subtotal', s.subtotal),
                _total('Delivery', s.delivery),
                _total('Voucher', -s.discount),
                const Divider(),
                _total('Total', s.total, bold: true),
              ],
            ),
          ),
          gap(15),
          Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Add Voucher'),
                gap(12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: voucher,
                        decoration: const InputDecoration(hintText: 'COODY40'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        if (voucher.text.trim().toUpperCase() != 'COODY40') {
                          toast(context, 'Try demo code COODY40 for 40% off.');
                          return;
                        }
                        s.voucher = 'COODY40';
                        s.commit();
                      },
                      child: const Text('Apply'),
                    ),
                  ],
                ),
                if (s.discount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: label(
                      'COODY40 applied · 40% off food',
                      size: 12,
                      color: CoodyColors.green,
                    ),
                  ),
                gap(20),
                TextFormField(
                  initialValue: s.note,
                  onChanged: (value) => s.note = value,
                  maxLength: 100,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Note for the restaurant',
                  ),
                ),
              ],
            ),
          ),
          gap(15),
          Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionTitle(
                  'Payment Method',
                  action: 'Change',
                  onAction: () => go(context, '219'),
                ),
                gap(16),
                Row(
                  children: [
                    Icon(
                      s.payment == 'Cash'
                          ? Icons.payments_outlined
                          : Icons.account_balance_wallet_outlined,
                      color: CoodyColors.primary,
                    ),
                    const SizedBox(width: 12),
                    label(s.payment, weight: FontWeight.w500),
                    const Spacer(),
                    const Icon(
                      Icons.check_circle_rounded,
                      color: CoodyColors.primary,
                      size: 20,
                    ),
                  ],
                ),
                gap(12),
                label(
                  'Demo checkout · no payment is collected',
                  size: 11,
                  color: CoodyColors.muted,
                ),
              ],
            ),
          ),
          gap(16),
        ],
      ),
    );
  }

  Widget _total(String title, int amount, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 9),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        label(
          title,
          color: bold ? CoodyColors.ink : CoodyColors.muted,
          weight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
        label(
          money(amount),
          color: bold ? CoodyColors.primary : CoodyColors.ink,
          weight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
      ],
    ),
  );
}

class PaymentChoicePage extends StatelessWidget {
  const PaymentChoicePage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return Stack(
      children: [
        const CheckoutPage(),
        Positioned.fill(
          child: ColoredBox(color: Colors.black.withValues(alpha: .3)),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: label(
                            'Add your payment methods',
                            size: 18,
                            weight: FontWeight.w700,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Close payment methods',
                          onPressed: () => back(context),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                    gap(20),
                    for (final p in ['CaPay Wallet', 'Cash', ...s.cards])
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          p == 'Cash'
                              ? Icons.payments_outlined
                              : Icons.account_balance_wallet_outlined,
                          color: CoodyColors.primary,
                        ),
                        title: label(p),
                        trailing: Icon(
                          s.payment == p
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: s.payment == p
                              ? CoodyColors.primary
                              : CoodyColors.muted,
                        ),
                        onTap: () {
                          s.payment = p;
                          s.commit();
                          back(context);
                        },
                      ),
                    gap(12),
                    PrimaryButton('Add a new card', () => go(context, '507')),
                    TextButton(
                      onPressed: () => go(context, '220'),
                      child: const Text('Scan Your Card'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ScanCardPage extends StatelessWidget {
  const ScanCardPage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Scan Your Card',
    white: true,
    bottom: PrimaryButton('Enter card manually', () => go(context, '507')),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(35),
      child: Column(
        children: [
          gap(52),
          const EmojiTile('💳', size: 100),
          gap(32),
          label('Scan Your Card', size: 26, weight: FontWeight.w700),
          gap(12),
          const Text(
            'Place your card within the frame.\nThis demo uses manual card entry.',
            textAlign: TextAlign.center,
            style: TextStyle(color: CoodyColors.muted, height: 1.7),
          ),
          gap(40),
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: CoodyColors.background,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFB3BAC5), width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.credit_card_rounded,
                size: 64,
                color: Color(0xFFB3BAC5),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class OrderSuccessPage extends StatelessWidget {
  const OrderSuccessPage({super.key});
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const CheckoutPage(),
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
                  const EmojiTile('🍱'),
                  gap(26),
                  label(
                    'You ordered successfully',
                    size: 20,
                    weight: FontWeight.w700,
                  ),
                  gap(12),
                  const Text(
                    'Your order is confirmed and will be delivered within 20 minutes. Enjoy your food!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: CoodyColors.muted, height: 1.7),
                  ),
                  gap(24),
                  PrimaryButton(
                    'Track Order',
                    () => go(context, '401', replace: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
