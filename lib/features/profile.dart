import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/theme.dart';
import '../state/app_state.dart';
import '../ui/components.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PageFrame(
      title: 'Profile',
      tab: 4,
      actions: [
        IconButton(
          tooltip: 'Notifications',
          onPressed: () => go(context, '510'),
          icon: const Icon(
            Icons.notifications_none_rounded,
            color: CoodyColors.primary,
          ),
        ),
      ],
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          Surface(
            child: Column(
              children: [
                const FoodImage(33, width: 80, height: 80, radius: 20),
                gap(18),
                label(s.name, size: 20, weight: FontWeight.w500),
                gap(4),
                label('@linhnguyen', size: 12, color: CoodyColors.muted),
              ],
            ),
          ),
          gap(15),
          Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('General'),
                gap(12),
                _row(
                  context,
                  Icons.person_outline_rounded,
                  'Account information',
                  'Change your Account information',
                  '502',
                ),
                _row(
                  context,
                  Icons.lock_outline_rounded,
                  'Password',
                  'Change your Password',
                  '503',
                ),
                _row(
                  context,
                  Icons.credit_card_rounded,
                  'Payment Methods',
                  'Add your Credit & Debit cards',
                  s.cards.isEmpty ? '504' : '505',
                ),
                _row(
                  context,
                  Icons.location_on_outlined,
                  'Delivery Locations',
                  'Change your Delivery Locations',
                  '508',
                ),
                _row(
                  context,
                  Icons.card_giftcard_rounded,
                  'Invite your friends',
                  'Get \$15 for each invitation!',
                  '509',
                ),
              ],
            ),
          ),
          gap(15),
          Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('Notifications'),
                gap(16),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: label('Notifications'),
                  subtitle: label(
                    'You will receive daily updates',
                    size: 12,
                    color: CoodyColors.muted,
                  ),
                  value: s.notifications,
                  activeThumbColor: CoodyColors.primary,
                  onChanged: (v) {
                    s.notifications = v;
                    s.commit();
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: label('Promotional Notifications', size: 13),
                  subtitle: label(
                    'Get notified about promotions',
                    size: 12,
                    color: CoodyColors.muted,
                  ),
                  value: s.promotions,
                  activeThumbColor: CoodyColors.primary,
                  onChanged: (v) {
                    s.promotions = v;
                    s.commit();
                  },
                ),
              ],
            ),
          ),
          gap(15),
          Surface(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('More'),
                gap(12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.star_outline_rounded,
                    color: CoodyColors.muted,
                  ),
                  title: label('Rate Us'),
                  subtitle: label(
                    'Tell us about your experience',
                    size: 12,
                    color: CoodyColors.muted,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => go(context, '403'),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.help_outline_rounded,
                    color: CoodyColors.muted,
                  ),
                  title: label('FAQ'),
                  subtitle: label(
                    'Frequently Asked Questions',
                    size: 12,
                    color: CoodyColors.muted,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => showDialog<void>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('How Coody works'),
                      content: const Text(
                        'Choose a restaurant, add your favorite food and confirm your order.\n\nThis is an offline UI demo. Payments, delivery tracking and sign-in are simulated.\n\nUse COODY40 for a demo food discount and 1234 for verification.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(c),
                          child: const Text('Got it'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          gap(15),
          PrimaryButton('Logout', () {
            s.signedIn = false;
            s.commit();
            go(context, '104', replace: true);
          }),
          gap(24),
        ],
      ),
    );
  }

  Widget _row(
    BuildContext c,
    IconData icon,
    String title,
    String subtitle,
    String route,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: CoodyColors.muted, size: 22),
      title: label(title, weight: FontWeight.w500),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: label(subtitle, size: 12, color: CoodyColors.muted),
      ),
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFFB3BAC5),
      ),
      onTap: () => go(c, route),
    ),
  );
}

class AccountPage extends StatefulWidget {
  const AccountPage({super.key, this.password = false});
  final bool password;
  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final form = GlobalKey<FormState>();
  final controllers = List.generate(3, (_) => TextEditingController());
  bool loaded = false, hide = true;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!loaded) {
      final s = AppScope.of(context);
      if (!widget.password) {
        controllers[0].text = s.name;
        controllers[1].text = s.email;
        controllers[2].text = s.phone;
      }
      loaded = true;
    }
  }

  @override
  void dispose() {
    for (final c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titles = widget.password
        ? ['Password', 'New Password', 'Confirm Password']
        : ['Full Name', 'Email Address', 'Phone Number'];
    return PageFrame(
      title: widget.password ? 'Change Password' : 'Account information',
      white: true,
      bottom: PrimaryButton('Change settings', () {
        if (!form.currentState!.validate()) return;
        if (widget.password) {
          toast(context, 'Password updated for this demo session.');
          back(context);
          return;
        }
        final s = AppScope.of(context);
        s.name = controllers[0].text.trim();
        s.email = controllers[1].text.trim();
        s.phone = controllers[2].text.trim();
        s.commit();
        toast(context, 'Account information saved');
        back(context);
      }),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(35),
        child: Form(
          key: form,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              gap(18),
              for (var i = 0; i < 3; i++) ...[
                label(titles[i], size: 12, color: CoodyColors.muted),
                gap(8),
                TextFormField(
                  controller: controllers[i],
                  obscureText: widget.password && hide,
                  keyboardType: widget.password
                      ? TextInputType.visiblePassword
                      : i == 1
                      ? TextInputType.emailAddress
                      : i == 2
                      ? TextInputType.phone
                      : TextInputType.name,
                  decoration: InputDecoration(
                    hintText: titles[i],
                    suffixIcon: widget.password
                        ? IconButton(
                            tooltip: 'Show password',
                            onPressed: () => setState(() => hide = !hide),
                            icon: const Icon(
                              Icons.visibility_outlined,
                              size: 18,
                              color: CoodyColors.muted,
                            ),
                          )
                        : null,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'This field is required';
                    }
                    if (widget.password) {
                      if (v.length < 8) return 'Use at least 8 characters';
                      if (i == 2 && v != controllers[1].text) {
                        return 'Passwords do not match';
                      }
                    } else {
                      if (i == 1 &&
                          !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v)) {
                        return 'Enter a valid email address';
                      }
                      if (i == 2 &&
                          v.replaceAll(RegExp(r'\D'), '').length < 8) {
                        return 'Enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ),
                gap(26),
              ],
              if (widget.password)
                label(
                  'Demo only. Your password is never stored.',
                  size: 12,
                  color: CoodyColors.muted,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentMethodsPage extends StatelessWidget {
  const PaymentMethodsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context);
    return PageFrame(
      title: 'Payment Methods',
      white: true,
      bottom: PrimaryButton('Add Cards', () => go(context, '506')),
      body: s.cards.isEmpty
          ? Padding(
              padding: const EdgeInsets.all(35),
              child: Column(
                children: [
                  gap(60),
                  const EmojiTile('💳', color: Color(0xFFFFFAE6)),
                  gap(24),
                  label(
                    'Don’t have any card',
                    size: 24,
                    weight: FontWeight.w700,
                  ),
                  gap(14),
                  const Text(
                    'It looks like you do not have a credit or debit card yet. Please add your cards easily 😊',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: CoodyColors.muted, height: 1.7),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(35),
              children: [
                label('Credit Cards', size: 18, weight: FontWeight.w500),
                gap(24),
                for (final card in s.cards)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: InkWell(
                      onTap: () {
                        s.payment = card;
                        s.commit();
                      },
                      child: Surface(
                        color: CoodyColors.background,
                        child: Row(
                          children: [
                            const FoodImage(
                              43,
                              width: 40,
                              height: 40,
                              radius: 8,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  label(card, weight: FontWeight.w500),
                                  gap(5),
                                  label(
                                    s.payment == card
                                        ? 'Default Payment'
                                        : 'Tap to set default',
                                    size: 12,
                                    color: CoodyColors.muted,
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              s.payment == card
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_off,
                              size: 20,
                              color: s.payment == card
                                  ? CoodyColors.primary
                                  : CoodyColors.muted,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class CardTypesPage extends StatelessWidget {
  const CardTypesPage({super.key});
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      const PaymentMethodsPage(),
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
                          'Choose a payment method',
                          size: 18,
                          weight: FontWeight.w700,
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close card types',
                        onPressed: () => back(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                  gap(16),
                  for (final (img, title, subtitle) in [
                    (38, 'Visa', 'Enter information on the card'),
                    (43, 'MasterCard', 'Enter information on the card'),
                    (39, 'PayPal', 'Enter email PayPal'),
                  ])
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: FoodImage(img, width: 42, height: 36, radius: 6),
                      title: label(title, weight: FontWeight.w500),
                      subtitle: label(
                        subtitle,
                        size: 12,
                        color: CoodyColors.muted,
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        if (title == 'PayPal') {
                          toast(
                            context,
                            'PayPal requires a connected payment service. Try a demo card.',
                          );
                        } else {
                          go(context, '507');
                        }
                      },
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

class AddCardPage extends StatefulWidget {
  const AddCardPage({super.key});
  @override
  State<AddCardPage> createState() => _AddCardPageState();
}

class _AddCardPageState extends State<AddCardPage> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(text: 'NGUYEN VAN LINH'),
      number = TextEditingController(),
      expiry = TextEditingController(),
      cvc = TextEditingController();
  bool defaultCard = true;
  @override
  void dispose() {
    for (final c in [name, number, expiry, cvc]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Add Card',
    white: true,
    bottom: PrimaryButton('Add Card', () {
      if (!form.currentState!.validate()) return;
      final digits = number.text.replaceAll(RegExp(r'\D'), '');
      final card =
          '${digits.startsWith('4') ? 'Visa' : 'MasterCard'} •••• ${digits.substring(digits.length - 4)}';
      final s = AppScope.of(context);
      if (!s.cards.contains(card)) s.cards.add(card);
      if (defaultCard) s.payment = card;
      s.commit();
      go(context, '505');
    }),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(35),
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            gap(20),
            const Center(
              child: EmojiTile('💳', size: 80, color: Color(0xFFFFFAE6)),
            ),
            gap(30),
            TextFormField(
              controller: name,
              decoration: const InputDecoration(hintText: 'Name on card'),
              validator: (v) => v == null || v.trim().length < 2
                  ? 'Enter a cardholder name'
                  : null,
            ),
            gap(16),
            TextFormField(
              controller: number,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(19),
              ],
              decoration: const InputDecoration(
                hintText: 'Card number',
                suffixIcon: Icon(
                  Icons.credit_card_rounded,
                  color: CoodyColors.muted,
                ),
              ),
              validator: (v) => RegExp(r'^\d{16,19}$').hasMatch(v ?? '')
                  ? null
                  : 'Enter a 16–19 digit demo card number',
            ),
            gap(16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: expiry,
                    keyboardType: TextInputType.datetime,
                    decoration: const InputDecoration(hintText: 'MM/YY'),
                    validator: (v) {
                      if (!RegExp(r'^(0[1-9]|1[0-2])/\d{2}$')
                          .hasMatch(v ?? '')) {
                        return 'Use MM/YY';
                      }
                      final p = v!.split('/');
                      final now = DateTime.now();
                      final end = DateTime(
                        2000 + int.parse(p[1]),
                        int.parse(p[0]) + 1,
                        0,
                      );
                      return end.isBefore(now) ? 'Card expired' : null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: cvc,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: const InputDecoration(hintText: 'CVC'),
                    validator: (v) => RegExp(r'^\d{3,4}$').hasMatch(v ?? '')
                        ? null
                        : '3–4 digits',
                  ),
                ),
              ],
            ),
            gap(18),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: label('Set Default Payment'),
              value: defaultCard,
              activeThumbColor: CoodyColors.primary,
              onChanged: (v) => setState(() => defaultCard = v),
            ),
            gap(24),
            label(
              'Use demo number 4111111111111111. Only the card brand and last four digits are saved locally.',
              size: 12,
              color: CoodyColors.muted,
            ),
          ],
        ),
      ),
    ),
  );
}

class ReferralPage extends StatelessWidget {
  const ReferralPage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Refer & Earn',
    white: true,
    bottom: PrimaryButton('Copy promo code', () async {
      await Clipboard.setData(const ClipboardData(text: 'COODY15'));
      if (context.mounted) toast(context, 'Promo code copied');
    }),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(35),
      child: Column(
        children: [
          gap(70),
          const EmojiTile('🎁', size: 100),
          gap(30),
          label('Refer a friend', size: 26, weight: FontWeight.w700),
          gap(16),
          const Text(
            'Share your promo code with a friend and you both get \$15.',
            textAlign: TextAlign.center,
            style: TextStyle(color: CoodyColors.muted, height: 1.7),
          ),
          gap(32),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: CoodyColors.peach,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: label(
                'COODY15',
                size: 26,
                weight: FontWeight.w700,
                color: CoodyColors.primary,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Notification',
    tab: 3,
    body: ListView(
      padding: const EdgeInsets.all(30),
      children: [
        const SectionTitle('New Notification'),
        gap(26),
        _notification(
          context,
          1,
          'Domino’s - Buy 1 get 1 free',
          'Buy 1 get 1 free for small sizes when you order via Coody!',
          'a few seconds ago',
          '214',
        ),
        _notification(
          context,
          2,
          'Completed - Starbucks',
          'Your order at Starbucks Hanoi has been delivered. Thank you for using Coody.',
          '5 mins ago',
          '402',
        ),
        gap(12),
        const SectionTitle('Earlier Notification'),
        gap(26),
        _notification(
          context,
          3,
          'McDonald’s - Sale 40% today',
          'Enter discount code COODY40 for 40% off your food order.',
          '2 hours ago',
          '201',
        ),
        _notification(
          context,
          0,
          'Lotteria - Buy 1 get 1 free',
          'Your favorite food is waiting. Discover today’s offers.',
          'Yesterday',
          '204',
        ),
      ],
    ),
  );
  Widget _notification(
    BuildContext c,
    int image,
    String title,
    String body,
    String time,
    String route,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 28),
    child: InkWell(
      onTap: () => go(c, route),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FoodImage(image, width: 48, height: 48, radius: 12),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                label(title, weight: FontWeight.w500),
                gap(7),
                label(body, size: 13, color: CoodyColors.muted),
                gap(9),
                label(time, size: 11, color: const Color(0xFFB3BAC5)),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
