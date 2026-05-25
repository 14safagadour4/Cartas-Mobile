import 'package:flutter/material.dart';

class ShopProduct {
  final String id;
  final String name;
  final String brand;
  final String description;
  final String composition;
  final List<String> benefits;
  final double price;
  final String imagePath;
  final List<String> detailImages;
  final String speedozaUri;
  final String categoryId;
  final bool inStock;
  final int maxQuantity;

  const ShopProduct({
    required this.id,
    required this.name,
    this.brand = 'Cartas Nature',
    required this.description,
    required this.composition,
    this.benefits = const [],
    required this.price,
    required this.imagePath,
    this.detailImages = const [],
    required this.speedozaUri,
    required this.categoryId,
    this.inStock = true,
    this.maxQuantity = 5,
  });
}
