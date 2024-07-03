import 'package:grocery/models/category.dart';

class GroceryItem {
  String id;
  String name;
  int quantity;
  Category category;
  GroceryItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.category,
  });
}
