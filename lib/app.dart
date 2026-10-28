import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'features/auth.dart';
import 'features/browse.dart';
import 'features/orders.dart';
import 'features/profile.dart';
import 'features/restaurant.dart';
import 'state/app_state.dart';

const screenIds = [
  '101',
  '102',
  '103',
  '104',
  '105',
  '106',
  '107',
  '108',
  '109',
  '110',
  '111',
  '112',
  '113',
  '114',
  '115',
  '201',
  '202',
  '203',
  '204',
  '205',
  '206',
  '207',
  '208',
  '209',
  '210',
  '211',
  '212',
  '213',
  '214',
  '215',
  '216',
  '217',
  '218',
  '219',
  '220',
  '221',
  '301',
  '302',
  '401',
  '402',
  '403',
  '404',
  '404-item',
  '405',
  '501',
  '502',
  '503',
  '504',
  '505',
  '506',
  '507',
  '508',
  '509',
  '510',
];

class CoodyApp extends StatelessWidget {
  const CoodyApp({super.key, required this.state, this.initialScreen});
  final AppState state;
  final String? initialScreen;
  @override
  Widget build(BuildContext context) {
    const configured = String.fromEnvironment('INITIAL_SCREEN');
    final first =
        initialScreen ??
        (configured.isNotEmpty
            ? configured
            : state.signedIn
            ? '201'
            : '101');
    return AppScope(
      state: state,
      child: MaterialApp(
        title: 'Coody',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        builder: (context, child) => ColoredBox(
          color: CoodyColors.background,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: child!,
            ),
          ),
        ),
        initialRoute: '/$first',
        onGenerateInitialRoutes: (route) => [
          _route(RouteSettings(name: route)),
        ],
        onGenerateRoute: _route,
      ),
    );
  }

  Route<dynamic> _route(RouteSettings settings) {
    final id = (settings.name ?? '/201').replaceFirst('/', '');
    final number = int.tryParse(id) ?? 0;
    final Widget page;
    if (number >= 101 && number <= 103) {
      page = OnboardingPage(number);
    } else if (number >= 104 && number <= 113) {
      page = AuthPage(number);
    } else if (number == 114 || number == 115 || number == 508) {
      page = AddressPage(number);
    } else if ([201, 202, 203, 206].contains(number)) {
      page = HomePage(variant: number);
    } else if (number == 204 || number == 205) {
      page = PartnersPage(number == 205);
    } else if (number >= 207 && number <= 210) {
      page = FiltersPage(number);
    } else if (number == 211 || number == 212) {
      page = SearchPage(number);
    } else if (number >= 213 && number <= 215) {
      page = RestaurantPage(number);
    } else if (number == 216) {
      page = ItemPage(
        foodId: settings.arguments is String
            ? settings.arguments as String
            : 'beef',
      );
    } else if (number == 217) {
      page = const CartPage();
    } else if (number == 218) {
      page = const CheckoutPage();
    } else if (number == 219) {
      page = const PaymentChoicePage();
    } else if (number == 220) {
      page = const ScanCardPage();
    } else if (number == 221) {
      page = const OrderSuccessPage();
    } else if (number == 301) {
      page = const DiscoverPage();
    } else if (number == 302) {
      page = const DiscoverDetailPage();
    } else if (number == 401 || number == 402) {
      page = OrdersPage(history: number == 402);
    } else if (number == 403 || number == 404 || id == '404-item') {
      page = RatingPage(id);
    } else if (number == 405) {
      page = const FeedbackSuccessPage();
    } else if (number == 501) {
      page = const ProfilePage();
    } else if (number == 502 || number == 503) {
      page = AccountPage(password: number == 503);
    } else if (number == 504 || number == 505) {
      page = const PaymentMethodsPage();
    } else if (number == 506) {
      page = const CardTypesPage();
    } else if (number == 507) {
      page = const AddCardPage();
    } else if (number == 509) {
      page = const ReferralPage();
    } else if (number == 510) {
      page = const NotificationsPage();
    } else {
      page = const HomePage();
    }
    return MaterialPageRoute(settings: settings, builder: (_) => page);
  }
}
