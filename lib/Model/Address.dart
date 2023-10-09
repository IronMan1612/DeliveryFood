class Address {
  final String id;  // Định danh duy nhất cho địa chỉ
  final String name;  // Tên của người nhận
  final String phoneNumber;  // Số điện thoại
  final String fullAddress;  // Địa chỉ đầy đủ
  final String note;  // Ghi chú cho địa chỉ

  Address({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.fullAddress,
    required this.note,
  });

  // Chuyển từ Map (thường dùng khi load từ Firebase) sang đối tượng Address
  factory Address.fromMap(Map<String, dynamic> data) {
    return Address(
      id: data['id'],
      name: data['name'],
      phoneNumber: data['phoneNumber'],
      fullAddress: data['fullAddress'],
      note: data['note'],
    );
  }

  // Chuyển từ đối tượng Address sang Map (thường dùng khi save lên Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'fullAddress': fullAddress,
      'note': note,
    };
  }
}
