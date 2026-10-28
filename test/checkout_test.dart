import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coody_food/app.dart';
import 'package:coody_food/state/app_state.dart';

import 'layout_assets.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Guest can add options, adjust order, apply discount, and submit',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(375, 812);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final s = AppState(await SharedPreferences.getInstance());
      await tester.pumpWidget(
        DefaultAssetBundle(
          bundle: LayoutAssets(),
          child: CoodyApp(state: s, initialScreen: '214'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Prime Beef - Pizza Beautiful').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add the Cheese'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add to Order (\$ 5.98)'));
      await tester.pumpAndSettle();
      expect(s.count, 1);
      expect(s.subtotal, 598);
      await tester.tap(find.textContaining('View Order').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Go to Checkout'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Apply'),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(find.byType(TextField).first, 'COODY40');
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(s.discount, 239);
      expect(s.total, 559);
      await tester.tap(find.textContaining('Submit Order'));
      await tester.pumpAndSettle();
      expect(find.text('You ordered successfully'), findsOneWidget);
      expect(s.activeOrder, true);
      expect(s.cart, isEmpty);
      await tester.tap(find.text('Track Order'));
      await tester.pumpAndSettle();
      expect(find.text('Your food is on its way'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
