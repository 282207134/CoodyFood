import '../models/food.dart';

const restaurants = [
  Restaurant('starbucks', 'Starbucks', 2, 'Coffee', 4.5, 1.5),
  Restaurant('mcdonalds', 'McDonald’s', 3, 'Burgers', 4.3, 0.2, open: false),
  Restaurant('dominos', 'Domino’s', 1, 'Pizza', 4.8, 2.6, deliveryCents: 200),
  Restaurant(
    'lotteria',
    'Lotteria',
    0,
    'Burgers',
    4.0,
    3.0,
    deliveryCents: 200,
  ),
  Restaurant('kfc', 'KFC', 11, 'Chicken', 4.6, 1.2, deliveryCents: 100),
];

const pizzaMenu = [
  Food('beef', 'Prime Beef - Pizza Beautiful', 'Pizza', 15, 499),
  Food('sea', 'Pizzamin Sea - Come Together', 'Pizza', 14, 399),
  Food('tropical', 'Tropical Paradise', 'Pizza', 25, 599),
  Food('cheese', 'Cheese Mania', 'Pizza', 26, 499),
  Food('hawaiian', 'Hawaiian Delight', 'Pizza', 27, 599),
];
const coffeeMenu = [
  Food('mocha', 'Mocha Cookie Crumble', 'Frappuccino', 19, 499),
  Food('coldbrew', 'Starbucks® Cold Brew', 'Cold Coffees', 18, 599),
  Food('chocolate', 'Hot Chocolate', 'Hot Drinks', 17, 399),
  Food('latte', 'Caffè Latte', 'Hot Coffees', 20, 399),
  Food('americano', 'Caffè Americano', 'Hot Coffees', 21, 299),
  Food('espresso', 'Espresso Con Panna', 'Hot Coffees', 22, 299),
  Food('cream', 'Double Chocolate Cream', 'Frappuccino', 23, 499),
  Food('iced', 'Caramel Ribbon Crunch', 'Frappuccino', 24, 499),
];
const fastFoodMenu = [
  Food('chicken', 'Crispy Chicken Meal', 'Chicken', 37, 699),
  Food('burger', 'Classic Burger', 'Burgers', 6, 399),
];
List<Food> menuFor(String restaurant) => switch (restaurant) {
  'starbucks' => coffeeMenu,
  'kfc' || 'lotteria' || 'mcdonalds' => fastFoodMenu,
  _ => pizzaMenu,
};
String restaurantForFood(Food food) => coffeeMenu.contains(food)
    ? 'starbucks'
    : fastFoodMenu.contains(food)
    ? 'kfc'
    : 'dominos';
const foods = [...pizzaMenu, ...coffeeMenu, ...fastFoodMenu];
Food foodById(String id) => foods.firstWhere((f) => f.id == id);
Restaurant restaurantById(String id) =>
    restaurants.firstWhere((r) => r.id == id);
