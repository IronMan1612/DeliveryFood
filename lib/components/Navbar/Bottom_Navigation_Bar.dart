import 'package:flutter/material.dart';
import 'package:DeliveryFood/View/HomeScreen/Home_Screen.dart';
import '../../View/Cart/cart_screen.dart';
import '../../View/Order/order_list_screen.dart';
import '../../View/Profile/Profile_Screen.dart';
import '../../View/Voucher/Voucher_List_Screen.dart';

const List<Widget> _pages = <Widget>[
  HomeScreen(),
  CartScreen(),
  OrderListScreen(),
  VoucherList(),
  ProfileScreen(),
];

class NavBar extends StatefulWidget {
  final int initialPage;

  const NavBar({Key? key, this.initialPage = 0}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialPage;
  }

  void _onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: _pages.elementAt(selectedIndex),
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
                        icon: Icon(Icons.home_rounded), label: "Home"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.shopping_cart), label: "Giỏ hàng"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.rate_review_outlined), label: "Đơn hàng"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.local_offer), label: "Voucher"),
                    BottomNavigationBarItem(
                        icon: Icon(Icons.person), label: "Tôi"),
                  ],
                  currentIndex: selectedIndex,
                  elevation: 0,
                  selectedItemColor: Colors.white,
                  unselectedItemColor: Colors.white.withOpacity(0.4),
                  onTap: _onItemTapped,
                ))));
  }
}
