class Restaurant {
  const Restaurant(
    this.id,
    this.name,
    this.image,
    this.category,
    this.rating,
    this.distance, {
    this.open = true,
    this.deliveryCents = 0,
  });
  final String id, name, category;
  final int image;
  final double rating, distance;
  final bool open;
  final int deliveryCents;
}

class Food {
  const Food(this.id, this.name, this.category, this.image, this.cents);
  final String id, name, category;
  final int image, cents;
}

class CartLine {
  CartLine(
    this.foodId,
    this.quantity, {
    this.cheese = false,
    this.border = false,
  });
  final String foodId;
  int quantity;
  final bool cheese, border;
  String get key => '$foodId-$cheese-$border';
  Map<String, dynamic> toJson() => {
    'foodId': foodId,
    'quantity': quantity,
    'cheese': cheese,
    'border': border,
  };
  factory CartLine.fromJson(Map<String, dynamic> json) => CartLine(
    json['foodId'] as String,
    json['quantity'] as int,
    cheese: json['cheese'] == true,
    border: json['border'] == true,
  );
}

String money(int cents) => '\$ ${(cents / 100).toStringAsFixed(2)}';
