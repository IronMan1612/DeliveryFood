import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Model/Address.dart';
import '../../Services/Firebase_Service.dart';
import 'add_address.dart';
class AddressScreen extends ChangeNotifier {
  Address? _selectedAddress;
  List<Address> _addresses = [];


  Address? get selectedAddress => _selectedAddress;
  List<Address> get addresses => _addresses;

  set selectedAddress(Address? address) {
    _selectedAddress = address;
    notifyListeners();
  }

  set addresses(List<Address> addressesList) {
    _addresses = addressesList;
    if (_selectedAddress == null && _addresses.isNotEmpty) {
      _selectedAddress = _addresses.first;
    }
    notifyListeners();
  }
}


class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  late Future<List<Address>> loadAddressesFuture;
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    loadAddressesFuture = _firebaseService.loadAddressesFromFirestore();
  }

  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.green[400],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, Address address) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Center(
            child: Text(
              'Xoá địa chỉ',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
            ),
          ),
          content: const Text(
              'Bạn có muốn xoá địa chỉ này không?',
              textAlign: TextAlign.center,
            ),

          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    child: const Text('Huỷ', style: TextStyle(color: Colors.black)),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(false);
                    },
                  ),
                ),
                Expanded(
                  child: TextButton(
                    child: const Text('OK', style: TextStyle(color: Colors.orange)),
                    onPressed: () {
                      Navigator.of(dialogContext).pop(true);
                    },
                  ),
                ),
              ],
            )
          ],
        );
      },
    );

    if (confirmed == true) {
      await _firebaseService.deleteAddressFromFirestore(address.id);
      showSnackBar(context, 'Xoá địa chỉ thành công');
      setState(() {
        loadAddressesFuture = _firebaseService.loadAddressesFromFirestore();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Quản lý địa chỉ"),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder<List<Address>>(
        future: loadAddressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Lỗi khi tải địa chỉ'));
          } else {
            List<Address> addresses = snapshot.data!;
            Future.microtask(() {
              Provider.of<AddressScreen>(context, listen: false).addresses = addresses;   // xây dựng lại widget
            });

            return ListView.builder(
              itemCount: addresses.length,
              itemBuilder: (context, index) {
                Address address = addresses[index];
                return Card(
                  margin: const EdgeInsets.all(10.0),
                  elevation: 5.0,
                  child: ListTile(
                    title: Text(address.fullAddress),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Tên: ${address.name}"),
                        Text("SĐT: ${address.phoneNumber}"),
                        Text("Ghi chú: ${address.note}"),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AddAddressPage(address: address)),
                            ).then((_) {
                              setState(() {
                                loadAddressesFuture = _firebaseService.loadAddressesFromFirestore();
                              });
                              showSnackBar(context, 'Cập nhật địa chỉ thành công');
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _confirmDelete(context, address);
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Provider.of<AddressScreen>(context, listen: false).selectedAddress = address;
                      Navigator.pop(context, address);
                    },
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.orange,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            elevation: 0,
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddAddressPage(),
              ),
            ).then((_) {
              setState(() {
                loadAddressesFuture = _firebaseService.loadAddressesFromFirestore();
              });
            });
          },
          child: const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              "Thêm địa chỉ mới",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
