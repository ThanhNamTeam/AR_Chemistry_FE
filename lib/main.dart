import 'package:flutter/material.dart';

void main() {
  runApp(const ARChemistryApp());
}

class ARChemistryApp extends StatelessWidget {
  const ARChemistryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AR Chemistry Lab',
      theme: ThemeData(primarySwatch: Colors.deepPurple, useMaterial3: true),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;


  static const List<Widget> _pages = [
    Center(child: Text('Chemistry Library - Thư viện thẻ')),
    Center(child: Text('AR Scanner - Quét thẻ bài')),
    Center(child: Text('My Inventory - Túi đồ cá nhân')),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AR Chem-Lab')),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Inventory',
          ),
        ],
      ),
    );
  }
}
