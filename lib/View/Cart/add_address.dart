import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Model/Address.dart';
import '../../Services/Firebase_Service.dart';

class AddAddressPage extends StatefulWidget {
  final Address? address;

  AddAddressPage({this.address});

  @override
  _AddAddressPageState createState() => _AddAddressPageState();
}

class _AddAddressPageState extends State<AddAddressPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.address != null) {
      _nameController.text = widget.address!.name;
      _phoneController.text = widget.address!.phoneNumber;
      _addressController.text = widget.address!.fullAddress;
      _noteController.text = widget.address!.note;
    }

    _nameController.addListener(_updateState);
    _phoneController.addListener(_updateState);
    _addressController.addListener(_updateState);
    _noteController.addListener(_updateState);
  }

  void _updateState() {
    setState(() {});
  }

  InputDecoration _inputDecoration(String label, TextEditingController controller, int maxLength) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.orange),
      counterText: '${controller.text.length}/$maxLength',
      counterStyle: TextStyle(color: Colors.orange),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange, width: 2.0),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.orange, width: 1.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm địa chỉ mới'), backgroundColor: Colors.orange),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                maxLength: 20,
                decoration: _inputDecoration('Tên người nhận', _nameController, 20),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên';
                  }
                  if (RegExp(r'[0-9]|[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                    return 'Tên không được chứa số và kí tự đặc biệt';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _phoneController,
                maxLength: 10,
                decoration: _inputDecoration('Số điện thoại', _phoneController, 10),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (!RegExp(r'^0\d{9}$').hasMatch(value)) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
                keyboardType: TextInputType.phone,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _addressController,
                maxLength: 70,
                decoration: _inputDecoration('Địa chỉ đầy đủ', _addressController, 70),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập địa chỉ';
                  }
                  return null;
                },
                maxLines: 2,
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: _noteController,
                maxLength: 100,
                decoration: _inputDecoration('Ghi chú (tùy chọn)', _noteController, 100),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.orange),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            padding: MaterialStateProperty.all(const EdgeInsets.symmetric(vertical: 15)),
          ),
          child: const Text('Lưu địa chỉ'),
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              Address newAddress = Address(
                id: widget.address?.id ?? '',
                name: _nameController.text,
                phoneNumber: _phoneController.text,
                fullAddress: _addressController.text,
                note: _noteController.text,
              );

              if (widget.address == null) {
                await FirebaseService().addAddressToFirestore(newAddress);
              } else {
                await FirebaseService().updateAddressInFirestore(widget.address!.id, newAddress);
              }

              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}
