import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/theme.dart';
import '../state/app_state.dart';
import '../ui/components.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage(this.screen, {super.key});
  final int screen;
  @override
  Widget build(BuildContext context) {
    final index = screen - 101;
    const titles = [
      'Diverse and fresh food.',
      'Free delivery on all orders',
      '+15K Restaurants',
    ];
    const descriptions = [
      'With the best local ingredients, we have created fresh, delicious food and drinks.',
      'Free shipping on the first order when using CaPay payment method.',
      'Easily find your favorite food and make deliveries in a fast time.',
    ];
    return PageFrame(
      white: true,
      body: LayoutBuilder(
        builder: (context, size) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: size.maxHeight),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(35, 12, 35, 32),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => go(context, '104'),
                      child: const Text('Skip'),
                    ),
                  ),
                  gap(30),
                  SvgPicture.asset(
                    'assets/images/onboarding_$screen.svg',
                    height: (size.maxHeight * .38).clamp(200, 305),
                  ),
                  gap(56),
                  Text(
                    titles[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  gap(14),
                  Text(
                    descriptions[index],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: CoodyColors.muted,
                      height: 1.7,
                    ),
                  ),
                  gap(36),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      3,
                      (i) => Container(
                        width: i == index ? 16 : 8,
                        height: 5,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: i == index
                              ? CoodyColors.primary
                              : CoodyColors.background,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  gap(54),
                  PrimaryButton(
                    'Get started',
                    () => go(context, screen == 103 ? '104' : '${screen + 1}'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FoodHeader extends StatelessWidget {
  const FoodHeader({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 150,
    child: Stack(
      children: [
        const Positioned(left: -20, top: 10, child: EmojiTile('🍖', size: 70)),
        const Positioned(left: 82, top: -24, child: EmojiTile('🍣', size: 58)),
        const Positioned(right: 64, top: 45, child: EmojiTile('🥪', size: 70)),
        const Positioned(left: 66, top: 77, child: EmojiTile('🍔', size: 48)),
        const Positioned(
          right: -26,
          top: -18,
          child: EmojiTile('🍔', size: 76),
        ),
      ],
    ),
  );
}

class AuthPage extends StatefulWidget {
  const AuthPage(this.screen, {super.key});
  final int screen;
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirm = TextEditingController();
  final name = TextEditingController();
  final phone = TextEditingController();
  final code = TextEditingController();
  bool obscure = true;
  int get id => widget.screen;
  bool get register => id == 112 || id == 113;
  bool get reset => id == 110 || id == 111;
  bool get verify => id == 107 || id == 109;
  bool get login => id == 104 || id == 105;
  @override
  void initState() {
    super.initState();
    if ([105, 108, 111, 113].contains(id)) {
      email.text = 'hello.carrotlabs@gmail.com';
    }
    if ([105, 111, 113].contains(id)) password.text = 'Coody1234';
    if (id == 111) confirm.text = 'Coody1234';
    if (id == 113) name.text = 'Carrot Labs';
    if (id == 106) phone.text = '399 345 678';
  }

  @override
  void dispose() {
    for (final c in [email, password, confirm, name, phone, code]) {
      c.dispose();
    }
    super.dispose();
  }

  String? validEmail(String? v) =>
      RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v ?? '')
      ? null
      : 'Enter a valid email address';
  String? validPassword(String? v) =>
      (v?.length ?? 0) >= 8 ? null : 'Use at least 8 characters';

  Widget field(
    String hint,
    TextEditingController controller, {
    bool secret = false,
    String? Function(String?)? validator,
    TextInputType? keyboard,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      obscureText: secret && obscure,
      keyboardType: keyboard,
      validator:
          validator ??
          (v) =>
              v == null || v.trim().isEmpty ? 'This field is required' : null,
      decoration: InputDecoration(
        hintText: hint,
        suffixIcon: secret
            ? IconButton(
                tooltip: obscure ? 'Show password' : 'Hide password',
                onPressed: () => setState(() => obscure = !obscure),
                icon: Icon(
                  obscure
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 19,
                  color: CoodyColors.muted,
                ),
              )
            : null,
      ),
    ),
  );

  void submit() {
    if (!form.currentState!.validate()) return;
    final state = AppScope.of(context);
    if (verify) {
      if (code.text != '1234') {
        toast(context, 'Use demo verification code 1234.');
        return;
      }
      go(context, id == 109 ? '110' : '114');
      return;
    }
    if (id == 106) {
      state.phone = '+84 ${phone.text}';
      state.commit();
      go(context, '107');
      return;
    }
    if (id == 108) {
      state.email = email.text.trim();
      go(context, '109');
      return;
    }
    if (reset) {
      toast(context, 'Demo password reset complete. Sign in to continue.');
      go(context, '104', replace: true);
      return;
    }
    state.email = email.text.trim();
    if (register) state.name = name.text.trim();
    state.signedIn = true;
    state.commit();
    go(context, register ? '114' : '201', replace: true);
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final title = register
        ? 'Hello! Create Account'
        : reset
        ? 'Reset your password'
        : id == 106
        ? 'Get started with Coody'
        : id == 107
        ? 'Verify phone number'
        : id == 108
        ? 'Password Recovery'
        : id == 109
        ? 'Verify your identity'
        : 'Welcome Back';
    final subtitle = register
        ? 'Create an account and enjoy your favorite food.'
        : reset
        ? 'At least 8 characters, with uppercase and lowercase letters'
        : id == 106
        ? 'Enter your phone number to use Coody 😉'
        : verify
        ? 'We have just sent a code to ${id == 107 ? state.phone : state.email}.'
        : id == 108
        ? 'Enter your email to recover your password'
        : 'Hello there, sign in to continue!';
    return PageFrame(
      white: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          children: [
            const FoodHeader(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 35),
              child: Form(
                key: form,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 24,
                      ),
                    ),
                    gap(10),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: CoodyColors.muted,
                        fontSize: 13,
                        height: 1.6,
                      ),
                    ),
                    if (login)
                      TextButton(
                        onPressed: () => go(context, '112'),
                        child: const Text('Or Create new account.'),
                      )
                    else
                      gap(28),
                    if (register) field('Your name', name),
                    if (login || register || id == 108)
                      field(
                        'Username or Email',
                        email,
                        validator: validEmail,
                        keyboard: TextInputType.emailAddress,
                      ),
                    if (login || register)
                      field(
                        'Password',
                        password,
                        secret: true,
                        validator: validPassword,
                      ),
                    if (reset) ...[
                      field(
                        'New Password',
                        password,
                        secret: true,
                        validator: validPassword,
                      ),
                      field(
                        'Confirm Password',
                        confirm,
                        secret: true,
                        validator: (v) => v != password.text
                            ? 'Passwords do not match'
                            : validPassword(v),
                      ),
                    ],
                    if (id == 106)
                      field(
                        '+84   Phone number',
                        phone,
                        keyboard: TextInputType.phone,
                        validator: (v) =>
                            (v ?? '').replaceAll(RegExp(r'\D'), '').length >= 8
                            ? null
                            : 'Enter a valid phone number',
                      ),
                    if (verify) ...[
                      TextFormField(
                        controller: code,
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 28, letterSpacing: 24),
                        decoration: const InputDecoration(
                          hintText: '– – – –',
                          counterText: '',
                        ),
                        validator: (v) =>
                            v?.length == 4 ? null : 'Enter the 4-digit code',
                      ),
                      gap(10),
                      label(
                        'Demo code: 1234',
                        size: 12,
                        color: CoodyColors.muted,
                      ),
                      gap(18),
                    ],
                    PrimaryButton(
                      reset
                          ? 'Update'
                          : login
                          ? 'Sign in'
                          : register
                          ? 'Create account'
                          : id == 108
                          ? 'Recover password'
                          : 'Next',
                      submit,
                    ),
                    if (login) ...[
                      TextButton(
                        onPressed: () => go(context, '108'),
                        child: const Text('Forgot Password?'),
                      ),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: label(
                              'OR',
                              color: CoodyColors.muted,
                              size: 12,
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      _social(
                        'Connect with Facebook',
                        Icons.facebook_rounded,
                        const Color(0xFF1877F2),
                      ),
                      gap(10),
                      _social(
                        'Connect with Google',
                        Icons.g_mobiledata_rounded,
                        const Color(0xFF4285F4),
                      ),
                      TextButton(
                        onPressed: () => go(context, '106'),
                        child: const Text('Continue with phone number'),
                      ),
                      TextButton(
                        onPressed: () => go(context, '201', replace: true),
                        child: label(
                          'Explore as a guest',
                          color: CoodyColors.muted,
                        ),
                      ),
                    ],
                    if (verify)
                      TextButton(
                        onPressed: () =>
                            toast(context, 'Demo verification code: 1234'),
                        child: const Text('Send again'),
                      ),
                    if (register) ...[
                      gap(14),
                      const Text(
                        'By creating an account, you agree to our\nTerms and Conditions',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: CoodyColors.muted,
                        ),
                      ),
                      TextButton(
                        onPressed: () => go(context, '104'),
                        child: const Text('Already have an account? Sign in'),
                      ),
                    ],
                    if (!login && !register)
                      TextButton(
                        onPressed: () => back(context),
                        child: const Text('Back'),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _social(String text, IconData icon, Color color) => TextButton.icon(
    style: TextButton.styleFrom(
      backgroundColor: CoodyColors.background,
      foregroundColor: CoodyColors.ink,
      minimumSize: const Size(0, 44),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    onPressed: () => toast(
      context,
      'Social sign-in needs a connected provider. You can explore as a guest.',
    ),
    icon: Icon(icon, color: color),
    label: Text(text),
  );
}

class AddressPage extends StatefulWidget {
  const AddressPage(this.screen, {super.key});
  final int screen;
  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final input = TextEditingController();
  @override
  void initState() {
    super.initState();
    if (widget.screen != 114) input.text = 'Hanoi, Vietnam';
  }

  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  void choose(String value) {
    final state = AppScope.of(context);
    state.address = value;
    state.commit();
    if (widget.screen == 508) {
      back(context);
    } else {
      go(context, '201', replace: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    const places = [
      'Hoan Kiem, Hanoi',
      'University of Business and Technology',
      'National University',
      'Backpacker Hostels - Downtown',
    ];
    return PageFrame(
      title: widget.screen == 508 ? 'Enter Locations' : null,
      white: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(35),
        child: Column(
          children: [
            gap(widget.screen == 508 ? 16 : 50),
            EmojiTile(widget.screen == 508 ? '📍' : '🌏', size: 96),
            gap(30),
            Text(
              widget.screen == 508
                  ? 'Enter Delivery Locations'
                  : 'Find restaurants near you',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
            ),
            gap(16),
            const Text(
              'Please enter your location or choose a delivery address to find restaurants near you.',
              textAlign: TextAlign.center,
              style: TextStyle(color: CoodyColors.muted, height: 1.7),
            ),
            gap(30),
            SearchBox(
              controller: input,
              hint: 'Enter a new address',
              onChanged: (_) => setState(() {}),
            ),
            gap(18),
            if (input.text.isEmpty)
              TextButton.icon(
                onPressed: () => choose('Hoan Kiem, Hanoi'),
                icon: const Icon(Icons.near_me_outlined),
                label: const Text('Use demo location'),
              ),
            if (input.text.isNotEmpty) ...[
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.location_on_rounded,
                  color: CoodyColors.primary,
                ),
                title: label(input.text, weight: FontWeight.w500),
                subtitle: const Text('Use this address'),
                onTap: () => choose(input.text.trim()),
              ),
              for (final p in places)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: Color(0xFFB3BAC5),
                  ),
                  title: label(p, lines: 1),
                  subtitle: label(
                    'Vietnam',
                    size: 12,
                    color: CoodyColors.muted,
                  ),
                  onTap: () => choose(p),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
