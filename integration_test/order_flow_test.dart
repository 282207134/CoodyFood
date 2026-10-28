import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coody_food/app.dart';
import 'package:coody_food/state/app_state.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android: customize food, submit, track, deliver and rate', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState(await SharedPreferences.getInstance());
    await tester.pumpWidget(CoodyApp(state: state, initialScreen: '214'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Prime Beef - Pizza Beautiful').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add the Cheese'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to Order (\$ 5.98)'));
    await tester.pumpAndSettle();
    expect(state.subtotal, 598);
    await tester.tap(find.textContaining('View Order').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Go to Checkout'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Submit Order'));
    await tester.pumpAndSettle();
    expect(state.activeOrder, true);
    expect(state.activeTotal, 798);
    expect(state.cart, isEmpty);
    await tester.tap(find.text('Track Order'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Mark as delivered'),
      250,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark as delivered'));
    await tester.pumpAndSettle();
    expect(state.activeOrder, false);
    await tester.tap(find.text('Rate').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Submit'));
    await tester.pumpAndSettle();
    expect(find.text('Your feedback was sent'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
