import 'package:shared_preferences/shared_preferences.dart';
import 'package:coody_food/models/food.dart';
import 'package:coody_food/state/app_state.dart';

Future<AppState> previewState(String screen) async {
  final s = AppState(await SharedPreferences.getInstance());
  if (['217', '218', '219'].contains(screen)) {
    s.cart.addAll([CartLine('beef', 1), CartLine('sea', 1)]);
  }
  s.activeOrder = ['206', '401'].contains(screen);
  s.activeTotal = 1098;
  s.activeItems = [CartLine('beef', 1), CartLine('sea', 1)];
  if (['213', '215', '302'].contains(screen)) {
    s.selectedRestaurant = 'starbucks';
  }
  if (screen == '505') {
    s.cards.addAll(['Visa •••• 9999', 'MasterCard •••• 1234']);
    s.payment = s.cards.first;
  }
  return s;
}
