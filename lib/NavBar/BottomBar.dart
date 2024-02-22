import 'package:flutter/material.dart';

// Import các màn hình mà bạn đã tạo
import '../View/CategoryManagement/Category_Screen.dart';
import '../View/FoodManagement/Food_Screen.dart';
import '../View/Home/Home_Screen.dart';
import '../View/OrderManagement/Order_Management_Screen.dart';
import '../View/UserManagement/User_Screen.dart';
import '../View/VoucherManagement/Voucher_Management_Screen.dart';

class AdminNavBar extends StatefulWidget {
  const AdminNavBar({super.key});

  @override
  _AdminNavBarState createState() => _AdminNavBarState();
}

class _AdminNavBarState extends State<AdminNavBar> {
  int _selectedIndex = 0;

  static const List<Widget> _adminPages = <Widget>[
    OverViewScreen(),
    CategoryManagementScreen(),
    FoodManagementScreen(),
  //  UserManagementScreen(),
    OrderManagementScreen(),
    VoucherManagementScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _adminPages.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 2),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30.0),
            topRight: Radius.circular(30.0),
          ),
          child: BottomNavigationBar(
            backgroundColor: Colors.orange,
            showSelectedLabels: true,
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category),
                label: 'Danh mục',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.food_bank),
                label: 'Thức ăn',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart),
                label: 'Đơn hàng',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.card_giftcard),
                label: 'Voucher',
              ),
            ],
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.4),
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}
