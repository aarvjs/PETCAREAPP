import 'package:flutter/material.dart';
import '../models/product_model.dart';

class CartLineItem {
  final ProductItem product;
  final String? selectedVariant;
  int quantity;

  CartLineItem({
    required this.product,
    this.selectedVariant,
    this.quantity = 1,
  });

  String get effectivePriceString {
    if (selectedVariant != null &&
        product.variantPrices != null &&
        product.variantPrices!.containsKey(selectedVariant)) {
      return product.variantPrices![selectedVariant]!;
    }
    return product.price;
  }

  double get unitPriceNumber {
    final raw = effectivePriceString.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(raw) ?? 0.0;
  }

  double get totalPrice => unitPriceNumber * quantity;
}

class CartService extends ChangeNotifier {
  CartService._();
  static final CartService instance = CartService._();

  final List<CartLineItem> _items = [];

  List<CartLineItem> get items => List.unmodifiable(_items);

  int get totalItemCount {
    return _items.fold(0, (sum, item) => sum + item.quantity);
  }

  double get subtotal {
    return _items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  double get deliveryFee {
    if (_items.isEmpty) return 0.0;
    return subtotal >= 499.0 ? 0.0 : 49.0;
  }

  double get total => subtotal + deliveryFee;

  void addToCart(ProductItem product, {String? variant, int quantity = 1}) {
    final index = _items.indexWhere(
      (item) => item.product.id == product.id && item.selectedVariant == variant,
    );
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartLineItem(
        product: product,
        selectedVariant: variant,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  void decrementQuantity(String productId, {String? variant}) {
    final index = _items.indexWhere(
      (item) => item.product.id == productId && item.selectedVariant == variant,
    );
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void removeFromCart(String productId, {String? variant}) {
    _items.removeWhere(
      (item) => item.product.id == productId && item.selectedVariant == variant,
    );
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
