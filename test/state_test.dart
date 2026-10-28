import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:coody_food/data/catalog.dart';
import 'package:coody_food/features/browse.dart';
import 'package:coody_food/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppState state;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    state = AppState(await SharedPreferences.getInstance());
  });
  test(
    'Options merge only when identical, quantity and voucher use integer cents',
    () {
      state.add(pizzaMenu.first, 1, cheese: true);
      state.add(pizzaMenu.first, 2, cheese: true);
      state.add(pizzaMenu.first, 1);
      expect(state.cart.length, 2);
      expect(state.count, 4);
      expect(state.subtotal, 598 * 3 + 499);
      state.voucher = 'COODY40';
      expect(state.discount, 917);
      expect(state.total, 1576);
      state.changeQuantity(state.cart.last, -1);
      expect(state.cart.length, 1);
      expect(state.selectRestaurant('starbucks'), false);
    },
  );
  test('Order snapshot survives cart reset and local restart', () async {
    state.note = 'No onions';
    state.add(pizzaMenu.first, 2, border: true);
    state.placeOrder();
    expect(state.cart, isEmpty);
    expect(state.activeTotal, 1596);
    expect(state.activeItems.first.border, true);
    final restored = AppState(state.preferences);
    await restored.load();
    expect(restored.activeOrder, true);
    expect(restored.activeTotal, 1596);
    expect(restored.activeNote, 'No onions');
    restored.reorder();
    expect(restored.count, 2);
    expect(restored.subtotal, 1396);
  });
  test('Search/filter ordering and empty results are deterministic', () {
    state.category = 'Pizza';
    expect(filteredRestaurants(state).single.id, 'dominos');
    state.maxFee = 100;
    expect(filteredRestaurants(state), isEmpty);
    state.category = 'All';
    state.maxFee = 1000;
    state.sort = 'Most Popular';
    expect(filteredRestaurants(state).first.id, 'dominos');
    expect(filteredRestaurants(state, 'not a restaurant'), isEmpty);
  });
  test('Empty checkout is rejected', () {
    expect(state.placeOrder, throwsStateError);
  });
  test('Delivery fee matches the selected restaurant and pickup', () {
    state.add(pizzaMenu.first, 1);
    expect(state.delivery, 200);
    state.takeaway = true;
    expect(state.delivery, 0);
    state.cart.clear();
    state.takeaway = false;
    state.selectRestaurant('starbucks');
    state.add(coffeeMenu.first, 1);
    expect(state.delivery, 0);
  });
}
