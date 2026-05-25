import 'package:flutter/material.dart';
import '../models/shop_product.dart';

class CartItem {
  final ShopProduct product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}

class CartProvider extends ChangeNotifier {
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.product.price * cartItem.quantity;
    });
    return total;
  }

  void addItem(ShopProduct product, int quantity) {
    if (_items.containsKey(product.id)) {
      // If item is already in cart, check max quantity
      if (_items[product.id]!.quantity + quantity <= product.maxQuantity) {
        _items.update(
          product.id,
          (existingCartItem) => CartItem(
            product: existingCartItem.product,
            quantity: existingCartItem.quantity + quantity,
          ),
        );
      } else {
         _items.update(
          product.id,
          (existingCartItem) => CartItem(
            product: existingCartItem.product,
            quantity: product.maxQuantity,
          ),
        );
      }
    } else {
      _items.putIfAbsent(
        product.id,
        () => CartItem(product: product, quantity: quantity),
      );
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int newQuantity) {
    if (!_items.containsKey(productId)) return;
    
    if (newQuantity <= 0) {
      removeItem(productId);
    } else if (newQuantity <= _items[productId]!.product.maxQuantity) {
      _items.update(
        productId,
        (existingCartItem) => CartItem(
          product: existingCartItem.product,
          quantity: newQuantity,
        ),
      );
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
