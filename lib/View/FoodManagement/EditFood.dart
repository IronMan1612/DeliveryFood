import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

import '../../Model/food_category.dart';
import '../../Model/food_item.dart';
import '../../Services/Firebase_Service.dart';

class EditFood extends StatefulWidget {
  final FoodItem food;

  const EditFood({Key? key, required this.food}) : super(key: key);

  @override
  _EditFoodState createState() => _EditFoodState();
}

class _EditFoodState extends State<EditFood> {
  final FirebaseService _firebaseService = FirebaseService();
  bool _isLoading = false;
  late String _originalCategory;
  late TextEditingController _idController;
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;

  File? _pickedImage;
  final _imagePicker = ImagePicker();

  String _chosenCategory = "";
  bool _isAvailable = true;

  late Future<List<FoodCategory>> _categoriesFuture;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _originalCategory = widget.food.category;
    _idController = TextEditingController(text: widget.food.id);
    _nameController = TextEditingController(text: widget.food.name);
    _descriptionController =
        TextEditingController(text: widget.food.description);
    _priceController =
        TextEditingController(text: widget.food.price.toStringAsFixed(0));
    _isAvailable = widget.food.isAvailable;
    _chosenCategory = widget.food.category;

    _categoriesFuture = _firebaseService.fetchCategoriesData();
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
        title: Text("Chỉnh sửa ${widget.food.name}"),
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
                          "Thay đổi hình ảnh",
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
                  const SizedBox(height: 10.0),
                  if (_pickedImage != null)
                    Image.file(_pickedImage!)
                  else
                    Image.network(
                      widget.food.imagePath,
                      fit: BoxFit.cover,
                      loadingBuilder: (BuildContext context, Widget child,
                          ImageChunkEvent? loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(widget.food.imagePath);
                      },
                    ),
                  const SizedBox(height: 20.0),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(

                      onPressed: _isLoading
                          ? null
                          : () async {
                        setState(() {
                          _isLoading = true;
                        });

                        if (_formKey.currentState!.validate()) {
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

                          FoodItem updatedFood = widget.food.copyWith(
                            id: _idController.text,
                            name: _nameController.text,
                            description: _descriptionController.text,
                            price: double.parse(_priceController.text),
                            category: _chosenCategory,
                            isAvailable: _isAvailable,
                            imagePath: imageUrl ?? widget.food.imagePath,
                          );

                          // Check if there are any changes
                          bool hasChanges =
                              _idController.text != widget.food.id ||
                                  _nameController.text != widget.food.name ||
                                  _descriptionController.text != widget.food.description ||
                                  double.parse(_priceController.text) != widget.food.price ||
                                  _chosenCategory != widget.food.category ||
                                  _isAvailable != widget.food.isAvailable ||
                                  _pickedImage != null;

                          if (hasChanges) {
                            // Here, you should also validate if the ID and Name exist in the Firestore
                            Map<String, bool> existence = await _firebaseService.doesFoodExist(
                              currentFoodId: widget.food.id,
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

                            // Update the category of the food if it has changed
                            if (_chosenCategory != _originalCategory) {
                              await _firebaseService.updateFoodCategory(
                                  widget.food.id, _originalCategory, _chosenCategory);
                            }

                            try {
                              await _firebaseService.setFood(updatedFood);
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                content: Text('Cập nhật thành công!'),
                                backgroundColor: Colors.green,
                              ));
                              Navigator.pop(context, updatedFood);
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Lỗi: $error'),
                                backgroundColor: Colors.red,
                              ));
                            }
                          } else {
                            // No changes, display a message or perform another action as needed
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content: Text('Không có thay đổi để lưu!'),
                              backgroundColor: Colors.blue,
                            ));
                            setState(() {
                              _isLoading = false;
                            });
                          }
                        } else {
                          setState(() {
                            _isLoading = false;
                          });
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange),
                      child: _isLoading
                          ? Transform.rotate(
                              angle: 5.0,
                              child: const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.orange),
                              ),
                            )
                          : const Text("Lưu thay đổi"),
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
