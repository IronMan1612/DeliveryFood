import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../Model/Voucher.dart';
import '../../Services/Firebase_Service.dart';

class EditVoucher extends StatefulWidget {
  final Voucher voucher;

  const EditVoucher({Key? key, required this.voucher}) : super(key: key);

  @override
  _EditVoucherState createState() => _EditVoucherState();
}

class _EditVoucherState extends State<EditVoucher> {
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
    _populateControllers();
  }

  void _populateControllers() {
    _idController.text = widget.voucher.id;
    _voucherNameController.text = widget.voucher.voucherName;
    _displayNameController.text = widget.voucher.displayName;
    _discountPercentageController.text = widget.voucher.discountPercentage.toString();
    _maxDiscountController.text = widget.voucher.maxDiscount.toString();
    _minOrderValueController.text = widget.voucher.minOrderValue.toString();
    _maxUsesController.text = widget.voucher.maxUses.toString();
    _startDateController.text = DateFormat('dd/MM/yyyy HH:mm').format(widget.voucher.startDate);
    _expiryDateController.text = DateFormat('dd/MM/yyyy HH:mm').format(widget.voucher.expiryDate);
    _isHidden = widget.voucher.isHidden;
  }

  bool _isButtonEnabled() {
    return !_isLoading;
  }

  Color _getButtonColor() {
    return _isButtonEnabled() ? Colors.orange : Colors.grey;
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



  Future<void> _editVoucher() async {
    if (_isLoading) {
      return; // Return if already processing
    }

    try {
      if (_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = true;
        });

        // Check if there are any changes
        bool hasChanges =
            _idController.text.trim() != widget.voucher.id||
            _voucherNameController.text.trim() != widget.voucher.voucherName ||
                _displayNameController.text.trim() != widget.voucher.displayName ||
                double.parse(_discountPercentageController.text.trim()) != widget.voucher.discountPercentage ||
                double.parse(_maxDiscountController.text.trim()) != widget.voucher.maxDiscount ||
                double.parse(_minOrderValueController.text.trim()) != widget.voucher.minOrderValue ||
                int.parse(_maxUsesController.text.trim()) != widget.voucher.maxUses ||
                _startDateController.text.trim() !=
                    DateFormat('dd/MM/yyyy HH:mm').format(widget.voucher.startDate) ||
                _expiryDateController.text.trim() !=
                    DateFormat('dd/MM/yyyy HH:mm').format(widget.voucher.expiryDate) ||
                _isHidden != widget.voucher.isHidden;

        if (!hasChanges) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Không có thay đổi để lưu!'),
              backgroundColor: Colors.blue,
              duration: Duration(seconds: 1),
            ),
          );
          return;
        }

        Voucher editVoucher = Voucher(
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

        await _firebaseService.setVoucher(editVoucher);

        // Thông báo thành công:
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật Voucher thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        Navigator.pop(context, editVoucher); // Pass true to indicate success
      }
    } catch (e) {
      print("Error editing voucher: $e");
      // Handle or display error message as needed.
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
        title: const Text('Chỉnh sửa Voucher'),
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
                  controller: TextEditingController(text: widget.voucher.currentUses.toString()),
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Số lần đã sử dụng',
                    labelStyle: TextStyle(color: Colors.red), // Màu của label
                    hintStyle: TextStyle(color: Colors.red), // Màu của hint text khi trống
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red), // Màu của border khi enabled
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red), // Màu của border khi focused
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.disabled,
                  enabled: false,
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
                    onPressed: _isButtonEnabled() ? _editVoucher : null,
                    style: ElevatedButton.styleFrom(backgroundColor: _getButtonColor()),
                    child: _isLoading
                        ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Text('Cập nhật Voucher'),
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
