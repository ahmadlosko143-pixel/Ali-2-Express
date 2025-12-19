import 'product.dart';

/// CartItem model representing a product in the shopping cart
class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});

  // Get total price for this cart item
  double get totalPrice => product.price * quantity;

  // Convert from JSON
  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {'product': product.toJson(), 'quantity': quantity};
  }

  // Create a copy with modified fields
  CartItem copyWith({Product? product, int? quantity}) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
