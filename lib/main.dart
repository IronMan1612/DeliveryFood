import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lap9/View/Cart/address_screen.dart';
import 'package:lap9/components/Navbar/Bottom_Navigation_Bar.dart';
import 'package:provider/provider.dart';
import 'Controller/Auth_model.dart';
import 'Services/Firebase_Service.dart';
import 'View/HomeScreen/add_to_Cart.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.web);
  } else if (Platform.isAndroid) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  } else if (Platform.isIOS) {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.ios);
  } // Bạn có thể thêm các nền tảng khác nếu cần
  final prefs = await SharedPreferences.getInstance();
  final isDataUploaded = prefs.getBool('isDataUploaded') ?? false;

  if (!isDataUploaded) {
    await FirebaseService().uploadFoodsData();
    await FirebaseService().uploadCategoriesData();
    await FirebaseService().uploadBannersData();
    await FirebaseService().uploadInitialVouchers();
    prefs.setBool('isDataUploaded', true);
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthModel()),
        ChangeNotifierProvider(create: (context) => Cart()),
        ChangeNotifierProvider(create: (context) => AddressScreen()),
      ],
      child: const MaterialApp(
        title: 'Food Delivery',
        debugShowCheckedModeBanner: false,
        home: NavBar(),
        //home: SignIn(),
      ),
    );
  }
}
