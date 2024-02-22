import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../Model/Voucher.dart';
import '../../Services/Firebase_Service.dart';

class AddVoucherScreen extends StatefulWidget {
  const AddVoucherScreen({Key? key}) : super(key: key);

  @override
  _AddVoucherScreenState createState() => _AddVoucherScreenState();
}

class _AddVoucherScreenState extends State<AddVoucherScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _voucherNameController = TextEditingController();
  final TextEditingController _displayNameController = TextEditingController();
  final TextEditingController _discountPercentageController = TextEditingController();
  final TextEditingController _maxDiscountController = TextEditingController();
  final TextEditingController _minOrderValueController = TextEditingController();
  final TextEditingController _maxUsesController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();

  bool _isHidden = false;
  bool _isLoading = false;

  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
    _setInitialVoucherId();
    _setDefaultDates();
  }

  bool _isButtonEnabled() {
    return !_isLoading;
  }

  Color _getButtonColor() {
    return _isButtonEnabled() ? Colors.orange : Colors.grey;
  }

  @override
  void dispose() {
    _idController.dispose();
    _voucherNameController.dispose();
    _displayNameController.dispose();
    _discountPercentageController.dispose();
    _maxDiscountController.dispose();
    _minOrderValueController.dispose();
    _maxUsesController.dispose();
    _startDateController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  void _setInitialVoucherId() async {
    try {
      int? maxId = await _firebaseService.getMaxIdVoucher();
      if (maxId == null) {
        print('No maxId found in Firebase');
        maxId = 0;
      }
      print('Received maxId from Firebase: $maxId');
      setState(() {
        _idController.text = (maxId! + 1).toString();
      });
    } catch (e) {
      print('Error when getting maxId: $e');
    }
  }

  void _setDefaultDates() {
    _startDateController.text = DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now());
    DateTime expiryDate = DateTime.now().add(const Duration(days: 30));
    _expiryDateController.text = DateFormat('dd/MM/yyyy HH:mm').format(expiryDate);
  }

  Future<void> _pickStartDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)), // có thể chọn 30 ngày trước ngày hiện tại
      lastDate: DateTime(2101), // time tối đa là 1/1/ năm 2101
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await _selectTime();

      if (pickedTime != null) {
        pickedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        setState(() {
          _startDateController.text = DateFormat('dd/MM/yyyy HH:mm').format(pickedDate!);
        });
      }
    }
  }


  Future<void> _pickExpiryDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null) {
      TimeOfDay? pickedTime = await _selectTime();

      if (pickedTime != null) {
        pickedDate = DateTime(pickedDate.year, pickedDate.month, pickedDate.day, pickedTime.hour, pickedTime.minute);
        setState(() {
          _expiryDateController.text = DateFormat('dd/MM/yyyy HH:mm').format(pickedDate!);
        });
      }
    }
  }

  Future<TimeOfDay?> _selectTime() async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  
  Future<void> _addVoucher() async {
    if (_isLoading) {
      return; // Return if already processing
    }

    try {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });

        // Kiểm tra xem ID và tên có tồn tại không để thay đổi
        Map<String, bool> existsMap = await _firebaseService.doesVoucherExist(
          voucherId: _idController.text.trim().toLowerCase(),
          voucherName: _voucherNameController.text.trim().toLowerCase(),
        );

        if (existsMap['idExists']!) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('ID Voucher đã tồn tại!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }

        if (existsMap['nameExists']!) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tên Voucher đã tồn tại!'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }

        Voucher newVoucher = Voucher(
          id: _idController.text.trim(),
          voucherName: _voucherNameController.text.trim().toUpperCase(),
          displayName: _displayNameController.text.trim(),
          discountPercentage: double.parse(_discountPercentageController.text.trim()),
          maxDiscount: double.parse(_maxDiscountController.text.trim()),
          minOrderValue: double.parse(_minOrderValueController.text.trim()),
          maxUses: int.parse(_maxUsesController.text.trim()),
          currentUses: 0,
          startDate: DateFormat('dd/MM/yyyy HH:mm').parse(_startDateController.text.trim()),
          expiryDate: DateFormat('dd/MM/yyyy HH:mm').parse(_expiryDateController.text.trim()),
          isHidden: _isHidden,
        );

        await _firebaseService.setVoucher(newVoucher);

        // Thông báo thành công:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Thêm Voucher thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        Navigator.pop(context, newVoucher);
      }
    } catch (e) {
      print("Error adding voucher: $e");
      // Xử lý hoặc hiển thị thông báo lỗi nếu cần.
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm Voucher mới'),
        backgroundColor: Colors.orange,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Card(
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'ID Voucher',
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Vui lòng nhập ID Voucher';
                    if (int.tryParse(value) == null) return 'ID chỉ nên chứa các số';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _voucherNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên Voucher (không dấu)',
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Vui lòng nhập tên Voucher';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                  ],
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: _displayNameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên hiển thị',
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Vui lòng nhập tên hiển thị';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _discountPercentageController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Phần trăm giảm giá',
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Vui lòng nhập phần trăm giảm giá';
                    double discountPercentage = double.parse(value);
                    if (discountPercentage < 0 || discountPercentage > 100) return 'Phần trăm giảm giá phải nằm trong khoảng từ 0 đến 100';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maxDiscountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Giảm tối đa',
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Vui lòng nhập giảm tối đa';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _minOrderValueController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Giá trị đơn hàng tối thiểu',
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Vui lòng nhập giá trị đơn hàng tối thiểu';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _maxUsesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Số lần sử dụng tối đa',
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Vui lòng nhập số lần sử dụng tối đa';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  onTap: _pickStartDate,
                  decoration: const InputDecoration(
                    labelText: 'Ngày bắt đầu',
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Vui lòng chọn ngày bắt đầu';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _expiryDateController,
                  readOnly: true,
                  onTap: _pickExpiryDate,
                  decoration: const InputDecoration(
                    labelText: 'Ngày kết thúc',
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Vui lòng chọn ngày kết thúc';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text("Ẩn Voucher",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  value: _isHidden,
                  onChanged: (bool value) {
                    setState(() {
                      _isHidden = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isButtonEnabled() ? _addVoucher : null,
                    style: ElevatedButton.styleFrom(backgroundColor: _getButtonColor()),
                    child: _isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text('Thêm Voucher'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
