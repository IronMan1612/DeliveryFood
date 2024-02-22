import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../../Model/food_category.dart';
import '../../Model/food_item.dart';
import '../../Services/Firebase_Service.dart';

class AddFood extends StatefulWidget {
  const AddFood({super.key});

  @override
  _AddFoodState createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;

  late final TextEditingController _idController = TextEditingController();
  late final TextEditingController _nameController = TextEditingController();
  late final TextEditingController _descriptionController = TextEditingController();
  late final TextEditingController _priceController = TextEditingController();

  File? _pickedImage;
  final _imagePicker = ImagePicker();

  String _chosenCategory = "";
  bool _isAvailable = true;

  late Future<List<FoodCategory>> _categoriesFuture;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _setInitialFoodId();
    _categoriesFuture = _firebaseService.fetchCategoriesData();
  }

  void _setInitialFoodId() async {
    int? maxId = await _firebaseService.getMaxFoodId();
    setState(() {
      _idController.text = (maxId + 1).toString();
    });
  }


  Future<String?> uploadImage(String imagePath) async {
    try {
      File imageFile = File(imagePath);
      String fileName = path.basename(imagePath);
      var snapshot = await FirebaseStorage.instance
          .ref()
          .child('foods/$fileName')
          .putFile(imageFile);
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error in uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Lỗi khi tải ảnh: $e'),
        backgroundColor: Colors.red,
      ));
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thêm món ăn mới"),
        backgroundColor: Colors.orange,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.always,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _idController,
                    decoration: const InputDecoration(labelText: "ID"),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'ID không được để trống.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: "Tên món"),
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Tên món không được để trống.';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: "Mô tả"),
                    maxLines: 3,
                    validator: (value) {
                      if (value!.trim().isEmpty) {
                        return 'Mô tả không được để trống.';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: "Giá"),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value!.trim().isEmpty || int.parse(value) < 1000) {
                        return 'Giá phải tối thiểu là 1000.';
                      }
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                  ),

                  const SizedBox(height: 10.0),
                  FutureBuilder<List<FoodCategory>>(
                    future: _categoriesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const CircularProgressIndicator();
                      } else if (!snapshot.hasData || snapshot.hasError) {
                        return Column(
                          children: [
                            const Text("Lỗi khi lấy danh mục"),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _categoriesFuture =
                                      _firebaseService.fetchCategoriesData();
                                });
                              },
                              child: const Text("Thử lại"),
                            )
                          ],
                        );
                      } else {

                        List<FoodCategory> categories = snapshot.data!;
                        // Set the _chosenCategory if it's not set already
                        if (_chosenCategory.isEmpty && categories.isNotEmpty) {
                          _chosenCategory = categories[0].id; // Set it to the first category id
                        }
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Danh mục",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            DropdownButton<String>(
                              value: _chosenCategory,
                              items: categories.map((FoodCategory category) {
                                return DropdownMenuItem<String>(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }).toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  _chosenCategory = value!;
                                });
                              },
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 15.0),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.black, // Color of the border
                      ),
                    ),
                    child: SwitchListTile(
                      title: const Text("Hiển thị",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      value: _isAvailable,
                      onChanged: (bool value) {
                        setState(() {
                          _isAvailable = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 15.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(
                          Icons.image,
                          color: Colors.orange,
                        ),
                        label: const Text(
                          "Chọn hình ảnh",
                          style: TextStyle(color: Colors.orange),
                        ),
                        onPressed: () async {
                          final pickedImageFile = await _imagePicker.pickImage(
                            source: ImageSource.gallery,
                            imageQuality: 100, // nén chất lượng HD 0-100
                            // maxWidth: 320,
                          );

                          setState(() {
                            if (pickedImageFile != null) {
                              _pickedImage = File(pickedImageFile.path);
                            } else {
                              print('No image selected.');
                            }
                          });
                        },
                      ),
                    ],
                  ),
                  if (_pickedImage != null)
                    Image.file(_pickedImage!),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading || _pickedImage == null
                          ? null
                          : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _isLoading = true;
                          });

                          String? imageUrl;
                          if (_pickedImage != null) {
                            imageUrl = await uploadImage(_pickedImage!.path);
                            if (imageUrl == null) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Lỗi khi tải ảnh lên!'),
                                backgroundColor: Colors.red,
                              ));
                              setState(() {
                                _isLoading = false;
                              });
                              return;
                            }
                          }

                          // Kiểm tra trùng lặp
                          Map<String, bool> existence = await _firebaseService.doesFoodExist(
                            foodId: _idController.text,
                            foodName: _nameController.text,
                          );

                          if (existence['idExists']!) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('ID đã tồn tại!'),
                              backgroundColor: Colors.red,
                            ));
                            setState(() {
                              _isLoading = false;
                            });
                            return;
                          }
                          if (existence['nameExists']!) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Tên món ăn đã tồn tại!'),
                              backgroundColor: Colors.red,
                            ));
                            setState(() {
                              _isLoading = false;
                            });
                            return;
                          }

                          // Cập nhật món ăn mới
                          FoodItem newFood = FoodItem(
                            id: _idController.text,
                            name: _nameController.text,
                            description: _descriptionController.text,
                            price: double.parse(_priceController.text),
                            category: _chosenCategory,
                            isAvailable: _isAvailable,
                            imagePath: imageUrl ?? "", // Vì món ăn mới, không có URL gốc
                          );

                          try {
                            await _firebaseService.setFood(newFood);
                            // Cập nhật món ăn vào danh mục tương ứng
                            await _firebaseService.addFoodToCategory(newFood.id, _chosenCategory);

                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Thành công!'),
                              backgroundColor: Colors.green,
                            ));
                            Navigator.pop(context,newFood);
                          } catch (error) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('Lỗi: $error'),
                              backgroundColor: Colors.red,
                            ));
                          } finally {
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        }

                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                      )
                          : const Text("Thêm"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}