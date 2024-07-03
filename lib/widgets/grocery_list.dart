import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grocery/data/categories.dart';

import 'package:grocery/models/grocery.dart';

import 'package:grocery/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'flutter-prep-7abf9-default-rtdb.firebaseio.com', 'shopping-list.json');


   try {
     final response = await http.get(url);


    if (response.statusCode >= 400) {
      setState(() {
        _error = 'Failed to fetch data. Please try again later';
           });
      _isLoading = false;
    }

    if(response.body == 'null')
    {
      setState(() {
        _isLoading = false;
      });
      return;
    }
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere((catItem) => catItem.value.name == item.value['category'])
          .value;
      loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }
    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });
   } catch (error){
    setState(() {
      _error = 'Something went wrong';
      _isLoading = false;
    });

   }
   

    

  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => const NewItem()));

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }
  
  void _removeItem (GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
      setState(() {
     _groceryItems.remove(item);
               });
        final url = Uri.https(
        'flutter-prep-7abf9-default-rtdb.firebaseio.com', 'shopping-list/${item.id}.json');
        
     final response =  await http.delete(url);

     if (response.statusCode  >= 400){
        setState(() {
         _groceryItems.insert(index,item);
           });
     }    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [IconButton(onPressed: _addItem, icon: const Icon(Icons.add))],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Text(_error!),
                )
              : _groceryItems.isEmpty
                  ? const Center(
                      child: Text('You do not have any item'),
                    )
                  : ListView.builder(
                      itemCount: _groceryItems.length,
                      itemBuilder: (BuildContext context, index) {
                        final grocery = _groceryItems[index];
                        return Dismissible(
                          key: ValueKey(grocery.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                           _removeItem(grocery);
                          },
                          background: Container(
                            color: Colors.red,
                          ),
                          child: ListTile(
                            leading: Container(
                              width: 24,
                              height: 24,
                              color: grocery.category.color,
                            ),
                            title: Text(grocery.name),
                            trailing: Text('${grocery.quantity}'),
                          ),
                        );
                      },
                    ),
    );
  }
}
