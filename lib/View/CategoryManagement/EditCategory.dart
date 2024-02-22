import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../../Model/food_category.dart';
import '../../Services/Firebase_Service.dart';
import 'package:path/path.dart' as path;

class EditCategory extends StatefulWidget {
  final FoodCategory category;

  EditCategory({required this.category});

  @override
  _EditCategoryState createState() => _EditCategoryState();
}

class _EditCategoryState extends State<EditCategory> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _idController;
  final FirebaseService _firebaseService = FirebaseService();
  String? _imagePath;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category.name);
    _idController = TextEditingController(text: widget.category.id);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _idController.dispose();
    super.dispose();
  }

  Future<String?> uploadImage(String imagePath) async {
    try {
      File imageFile = File(imagePath);
      String fileName = path.basename(imagePath);
      var snapshot = await FirebaseStorage.instance
          .ref()
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
    final XFile? image =
    await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
        _hasChanges = true; // Đã thay đổi hình ảnh
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chỉnh sửa danh mục: ${widget.category.name}'),
        backgroundColor: Colors.orange,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Card(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'ID danh mục',
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty)
                      return 'Vui lòng nhập ID danh mục';
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _hasChanges = true; // Đã thay đổi ID
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên danh mục',
                  ),
                  validator: (value) {
                    if (value!.trim().isEmpty)
                      return 'Vui lòng nhập tên danh mục';
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      _hasChanges = true; // Đã thay đổi tên danh mục
                    });
                  },
                ),
                const SizedBox(height: 16),
                if (_imagePath == null)
                  Image.network(
                    widget.category.imagePath,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Image.asset(widget.category.imagePath);
                    },
                  ),
                if (_imagePath != null)
                  Image.file(File(_imagePath!)),

                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(
                    Icons.add_photo_alternate,
                    color: Colors.orange,
                  ),
                  label: const Text(
                    "Thay đổi hình ảnh",
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      _isLoading ? Colors.grey : Colors.orange,
                    ),

                    onPressed: _isLoading
                        ? null
                        : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() {
                          _isLoading = true;
                        });

                        // Kiểm tra xem ID hoặc tên danh mục có tồn tại chưa
                        Map<String, bool> existsMap =
                        await _firebaseService.doesCategoryExist(
                          currentCategoryId: widget.category.id,
                          categoryId: _idController.text.trim(),
                          categoryName: _nameController.text.trim(),
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
                        if (_imagePath != null) {
                          String? imageUrl = await uploadImage(_imagePath!);
                          if (imageUrl != null) {
                            FoodCategory updatedCategory = FoodCategory(
                              id: _idController.text.trim(),
                              name: _nameController.text.trim(),
                              imagePath: imageUrl,
                              foods: [],
                            );
                            try {
                              await _firebaseService.setCategory(updatedCategory);
                            } catch (e) {
                              print("Error while updating category: $e");
                            }

                            // Thông báo thành công:
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cập nhật danh mục thành công!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 1),
                              ),
                            );

                            Navigator.pop(context, updatedCategory);
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
                        } else {
                          // Trường hợp không có sự thay đổi về hình ảnh
                          // Thực hiện hành động khác tùy thuộc vào yêu cầu của bạn
                          // Ví dụ:
                          // Cập nhật dữ liệu với sự thay đổi khác (nếu có)
                          if (_hasChanges) {
                            FoodCategory updatedCategory = FoodCategory(
                              id: _idController.text.trim(),
                              name: _nameController.text.trim(),
                              imagePath: widget.category.imagePath,
                              foods: [],
                            );
                            try {
                              await _firebaseService.setCategory(updatedCategory);
                            } catch (e) {
                              print("Error while updating category: $e");
                            }

                            // Thông báo thành công:
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cập nhật danh mục thành công!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 1),
                              ),
                            );

                            Navigator.pop(context, updatedCategory);
                          } else {
                            // Thông báo hoặc thực hiện hành động khác tùy thuộc vào yêu cầu của bạn
                            // Ví dụ:
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Không có thay đổi để lưu!'),
                                backgroundColor: Colors.blue,
                                duration: Duration(seconds: 1),
                              ),
                            );
                          }

                          setState(() {
                            _isLoading = false;
                          });
                        }
                      }
                    },
                    child: _isLoading
                        ? const CircularProgressIndicator(
                      valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                        : const Text('Lưu thay đổi'),
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
