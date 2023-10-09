import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfileDetails extends StatefulWidget {
  @override
  _UserProfileDetailsState createState() => _UserProfileDetailsState();
}

class _UserProfileDetailsState extends State<UserProfileDetails> {
  late User user;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  String genderValue = 'Khác';
  String jobValue = 'Khác';
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser!;
    _loadSavedInfo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Thông tin cá nhân"),
        backgroundColor: Colors.orange,
      ),
      body: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      _infoItem('Email:', user.email!),
                      //const Divider(),
                      //_infoItem('User ID:', user.uid),
                      const Divider(),
                      _infoItem('Ngày tạo:',
                          _formatDate(user.metadata.creationTime!)),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Tên',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0)),
                            Expanded(
                              child: TextFormField(
                                textAlign: TextAlign.end,
                                controller: nameController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Nhập tên',
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty)
                                    return 'Không được để trống';
                                  if (RegExp(r'[0-9]|[!@#$%^&*(),.?":{}|<>]')
                                      .hasMatch(value)) {
                                    return 'Tên không được chứa số và kí tự đặc biệt';
                                  }
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Số điện thoại',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0)),
                            Expanded(
                              child: TextFormField(
                                textAlign: TextAlign.end,
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Nhập số điện thoại',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Không được để trống';
                                  if (!RegExp(r"^(0)[0-9]{9}$").hasMatch(value))
                                    return 'Số điện thoại không hợp lệ';
                                  return null;
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Giới tính',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        trailing: DropdownButton<String>(
                          value: genderValue,
                          items:
                              <String>['Nam', 'Nữ', 'Khác'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              genderValue = newValue!;
                            });
                          },
                        ),
                      ),
                      const Divider(),
                      ListTile(
                        title: const Text('Nghề nghiệp',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        trailing: DropdownButton<String>(
                          value: jobValue,
                          items: <String>[
                            'Văn phòng',
                            'Học sinh/Sinh viên',
                            'Ở nhà',
                            'Khác'
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value,
                                  style:
                                      const TextStyle(fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              jobValue = newValue!;
                            });
                          },
                        ),
                      ),
                      const Divider(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveInfoToFirebase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    textStyle: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                  ),
                  child: const Text("Lưu thông tin"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} | ${date.hour}:${date.minute}:${date.second}';
  }

  _loadSavedInfo() async {
    // Lấy tham chiếu đến userInfo của một user cụ thể
    DocumentReference userInfoRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('userInfo')
        .doc(user.uid);

    DocumentSnapshot snapshot = await userInfoRef.get();

    if (snapshot.exists) {
      Map<String, dynamic> userData = snapshot.data()! as Map<String, dynamic>;
      setState(() {
        nameController.text = userData['name'] ?? '';
        phoneController.text = userData['phone'] ?? '';
        genderValue = userData['gender'] ?? 'Khác';
        jobValue = userData['job'] ?? 'Khác';
      });
    }
  }

  _saveInfoToFirebase() async {
    if (_formKey.currentState!.validate()) {
      DocumentReference userInfoRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('userInfo')
          .doc(user.uid);

      try {
        await userInfoRef.set({
          'name': nameController.text,
          'phone': phoneController.text,
          'gender': genderValue,
          'job': jobValue
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
            "Lưu thông tin thành công",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          duration: const Duration(seconds: 1),
        ));

        _loadSavedInfo();
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text(
            "Có lỗi xảy ra",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          duration: const Duration(seconds: 1),
        ));
      }
    }
  }
}
