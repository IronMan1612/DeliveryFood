import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../Model/food_category.dart';
import '../../../Services/Firebase_Service.dart';
import 'dart:io';
import 'package:path/path.dart' as path;

class AddCategoryScreen extends StatefulWidget {
  const AddCategoryScreen({Key? key}) : super(key: key);

  @override
  _AddCategoryScreenState createState() => _AddCategoryScreenState();
}

class _AddCategoryScreenState extends State<AddCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  String? _imagePath;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
    _setInitialCategoryId();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  void _setInitialCategoryId() async {
    try {
      int? maxId = await _firebaseService.getMaxCategoryId();
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


  Future<String?> uploadImage(String imagePath) async {
    try {
      File imageFile = File(imagePath);
      String fileName = path.basename(imagePath);
      var snapshot = await FirebaseStorage.instance.ref()
          .child('categories/$fileName')
          .putFile(imageFile);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error in uploading image: $e");
      return null;
    }
  }


  _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm danh mục mới'),
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
                    labelText: 'ID danh mục',
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Vui lòng nhập ID danh mục';
                    if (int.tryParse(value) == null) return 'ID chỉ nên chứa các số';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên danh mục',
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty) return 'Vui lòng nhập tên danh mục';
                    return null;
                  },
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.add_photo_alternate, color: Colors.orange,),
                  label: Text(_imagePath == null ? "Chọn hình ảnh" : "Đã chọn hình ảnh" ,style: const TextStyle(color: Colors.orange),),

                ),
                if (_imagePath != null)
                  Column(
                    children: [
                      const SizedBox(height: 16),
                      Image.file(File(_imagePath!)),
                    ],
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _imagePath == null || _isLoading
                          ? Colors.grey
                          : Colors.orange, // Màu sẽ trở thành màu xám nếu chưa chọn hình ảnh hoặc đang tải
                    ),
                    onPressed: _imagePath == null || _isLoading
                        ? null
                        : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });

                        // Kiểm tra xem ID hoặc tên danh mục có tồn tại chưa
                        Map<String, bool> existsMap = await _firebaseService.doesCategoryExist(
                            categoryId: _idController.text.trim().toLowerCase(),
                            categoryName: _nameController.text.trim().toLowerCase()
                        );

                        if (existsMap['idExists']!) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('ID danh mục đã tồn tại!'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 1),
                            ),
                          );
                          setState(() {
                            _isLoading = false;
                          });
                          return;
                        }

                        if (existsMap['nameExists']!) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tên danh mục đã tồn tại!'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 1),
                            ),
                          );
                          setState(() {
                            _isLoading = false;
                          });
                          return;
                        }

                        // Tiến hành tải hình ảnh và thêm danh mục
                        String? imageUrl = await uploadImage(_imagePath!);
                        if (imageUrl != null) {
                          FoodCategory newCategory = FoodCategory(
                            id: _idController.text.trim(),
                            name: _nameController.text.trim(),
                            imagePath: imageUrl,
                            foods: [],
                          );
                          _firebaseService.setCategory(newCategory);

                          // Thông báo thành công:
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Thêm danh mục thành công!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 1),
                            ),
                          );

                          Navigator.pop(context, newCategory);
                        } else {
                          // Thông báo lỗi:
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Có lỗi xảy ra khi tải ảnh lên!'),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 1),
                            ),
                          );
                        }

                        setState(() {
                          _isLoading = false;
                        });
                      }
                    },
                    child: _isLoading
                        ? const Center(
                          child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                        )
                        : const Text('Thêm danh mục'),
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
