import 'package:flutter/material.dart';

import 'character_list_screen.dart';
import 'favorites_screen.dart';

class CharacterTabsScreen extends StatefulWidget {
  const CharacterTabsScreen({super.key});

  @override
  State<CharacterTabsScreen> createState() => _CharacterTabsScreenState();
}

class _CharacterTabsScreenState extends State<CharacterTabsScreen> {
  int _selectedIndex = 0;

  final _screens = const [
    CharacterListScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}
