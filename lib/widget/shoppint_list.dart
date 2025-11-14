import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shoppinglistapp/data/categories.dart';
import 'package:shoppinglistapp/models/grocery_item.dart';
import 'package:shoppinglistapp/widget/new_item.dart';
import 'package:http/http.dart' as http;

class ShoppingList extends StatefulWidget {
  const ShoppingList({super.key});

  @override
  State<ShoppingList> createState() => _ShoppingListState();
}

class _ShoppingListState extends State<ShoppingList> {
  List<GroceryItem> _groceryItems = [];

  void _loadData() async {
    final url = Uri.https(
      'shopping-list-62922-default-rtdb.firebaseio.com',
      'shopping-List.json',
    );
    final response = await http.get(url);
    final Map<String,dynamic> listdata = json.decode(response.body);

    final List<GroceryItem> _loadedItem = [];

    for (final item in listdata.entries) {
      final category =
          categories.entries
              .firstWhere(
                (carItem) => carItem.value.title == item.value['category'],
          )
              .value;
      _loadedItem.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryItems = _loadedItem;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _addItem() async {
 final newItem = await Navigator.push<GroceryItem>(
      context,
      MaterialPageRoute(
        builder: (context) => NewItem(existingItem: _groceryItems),
      ),
    );
 if(newItem == null)
   {
     return;
   }
    setState(() {
     _groceryItems.add(newItem);
    });
  }

  void _editItem(int index) async {
    final existingItem = _groceryItems[index];

    final updatedItem = await Navigator.push<GroceryItem>(
      context,
      MaterialPageRoute(
        builder: (context) => NewItem(existingItem: existingItem),
      ),
    );

    if (updatedItem == null) {
      return;
    }

    setState(() {
      _groceryItems[index] = updatedItem;
    });
  }

  void _dismissibleItem(GroceryItem item) {
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Center(child: Text('No Item Added Yet'));
    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder:
            (context, index) => Dismissible(
              key: ValueKey(_groceryItems[index].id),
              onDismissed: (direction) {
                setState(() {
                  _dismissibleItem(_groceryItems[index]);
                });
              },
              child: ListTile(
                leading: Container(
                  height: 20,
                  width: 20,
                  color: _groceryItems[index].category.color,
                ),
                title: Text(_groceryItems[index].name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _groceryItems[index].quantity.toString(),
                      style: TextStyle(fontSize: 16),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blueAccent),
                      onPressed: () => _editItem(index),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _groceryItems.removeAt(index);
                        });
                      },
                      icon: Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
            ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: SafeArea(child: const Text('Your Grocery')),
        actions: [IconButton(onPressed: _addItem, icon: Icon(Icons.add))],
      ),
      body: content,
    );
  }
}
