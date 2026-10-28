import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/catalog.dart';
import '../models/food.dart';

class AppState extends ChangeNotifier {
  AppState(this.preferences);
  final SharedPreferences preferences;
  bool signedIn = false, notifications = true, promotions = false;
  String name = 'Linh Nguyen', email = 'hello.carrotlabs@gmail.com';
  String phone = '(+84) 399 345 678', address = 'Hanoi, Vietnam';
  String selectedRestaurant = 'dominos', payment = 'Cash', category = 'All';
  String sort = 'Recommended', voucher = '';
  bool takeaway = false;
  String note = '', activeNote = '';
  int priceLevel = 5, maxFee = 1000, completedOrders = 0, orderNumber = 1001;
  bool activeOrder = false;
  int activeTotal = 0;
  String activeRestaurant = 'dominos';
  List<CartLine> activeItems = [];
  final Set<String> favorites = {};
  final List<CartLine> cart = [];
  final List<String> cards = [];
  final List<String> recentSearches = ['Pizza', 'Starbucks', 'Burgers'];

  Future<void> load() async {
    final raw = preferences.getString('coody');
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      signedIn = j['signedIn'] == true;
      name = j['name'] ?? name;
      email = j['email'] ?? email;
      phone = j['phone'] ?? phone;
      address = j['address'] ?? address;
      payment = j['payment'] ?? 'Cash';
      takeaway = j['takeaway'] ?? false;
      activeNote = j['activeNote'] ?? '';
      notifications = j['notifications'] ?? true;
      promotions = j['promotions'] ?? false;
      favorites.addAll(List<String>.from(j['favorites'] ?? []));
      cards.addAll(List<String>.from(j['cards'] ?? []));
      selectedRestaurant = j['restaurant'] ?? 'dominos';
      cart.addAll((j['cart'] as List? ?? []).map((x) => CartLine.fromJson(x)));
      activeOrder = j['activeOrder'] == true;
      activeTotal = j['activeTotal'] ?? 0;
      activeRestaurant = j['activeRestaurant'] ?? 'dominos';
      activeItems = (j['activeItems'] as List? ?? [])
          .map((x) => CartLine.fromJson(x))
          .toList();
      completedOrders = j['completedOrders'] ?? 0;
      orderNumber = j['orderNumber'] ?? 1001;
    } catch (_) {
      // A damaged local demo snapshot must not prevent the app from opening.
      cart.clear();
    }
  }

  void commit() {
    notifyListeners();
    preferences.setString(
      'coody',
      jsonEncode({
        'signedIn': signedIn,
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'payment': payment,
        'takeaway': takeaway,
        'activeNote': activeNote,
        'notifications': notifications,
        'promotions': promotions,
        'favorites': favorites.toList(),
        'cards': cards,
        'restaurant': selectedRestaurant,
        'cart': cart.map((x) => x.toJson()).toList(),
        'activeOrder': activeOrder,
        'activeTotal': activeTotal,
        'activeRestaurant': activeRestaurant,
        'activeItems': activeItems.map((x) => x.toJson()).toList(),
        'completedOrders': completedOrders,
        'orderNumber': orderNumber,
      }),
    );
  }

  int unitPrice(CartLine l) =>
      foodById(l.foodId).cents + (l.cheese ? 99 : 0) + (l.border ? 199 : 0);
  int get count => cart.fold(0, (n, l) => n + l.quantity);
  int get subtotal => cart.fold(0, (n, l) => n + unitPrice(l) * l.quantity);
  int get discount => voucher == 'COODY40' ? (subtotal * .4).round() : 0;
  int get delivery => cart.isEmpty || takeaway
      ? 0
      : restaurantById(selectedRestaurant).deliveryCents;
  int get total => subtotal + delivery - discount;

  void add(
    Food food,
    int quantity, {
    bool cheese = false,
    bool border = false,
  }) {
    if (quantity < 1) return;
    final candidate = CartLine(
      food.id,
      quantity,
      cheese: cheese,
      border: border,
    );
    final index = cart.indexWhere((l) => l.key == candidate.key);
    if (index < 0) {
      cart.add(candidate);
    } else {
      cart[index].quantity += quantity;
    }
    commit();
  }

  void changeQuantity(CartLine line, int delta) {
    line.quantity += delta;
    cart.removeWhere((l) => l.quantity <= 0);
    commit();
  }

  bool selectRestaurant(String id) {
    if (id != selectedRestaurant && cart.isNotEmpty) return false;
    selectedRestaurant = id;
    commit();
    return true;
  }

  void favorite(String id) {
    if (!favorites.add(id)) favorites.remove(id);
    commit();
  }

  void placeOrder() {
    if (cart.isEmpty) throw StateError('Your order is empty');
    activeTotal = total;
    activeRestaurant = selectedRestaurant;
    activeNote = note;
    activeItems = cart.map((x) => CartLine.fromJson(x.toJson())).toList();
    activeOrder = true;
    orderNumber++;
    cart.clear();
    voucher = '';
    note = '';
    commit();
  }

  void reorder({String? restaurantId}) {
    selectedRestaurant = restaurantId ?? activeRestaurant;
    cart.clear();
    cart.addAll(
      activeItems.isEmpty || selectedRestaurant != activeRestaurant
          ? menuFor(selectedRestaurant).take(2).map((f) => CartLine(f.id, 1))
          : activeItems.map((x) => CartLine.fromJson(x.toJson())),
    );
    commit();
  }
}

class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);
  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
