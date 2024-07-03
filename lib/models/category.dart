import 'package:flutter/material.dart';

class Category {
  String name;
  Color color;
  Category(
    this.name,
    this.color,
  );
}

enum Categories {
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  sweets,
  spices,
  convenience,
  hygiene,
  other
}
