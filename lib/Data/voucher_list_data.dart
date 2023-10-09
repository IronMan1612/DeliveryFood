import '../Model/Voucher.dart';

List<Voucher> initialVouchers = [
  Voucher(
    id: '1',
    voucherName: 'BANMOI',
    displayName: 'Nhập mã "BANMOI" giảm 50k trên giá món',
    discountPercentage: 100, // % giảm
    maxDiscount: 50000,  // Tối đa giảm 50k
    minOrderValue: 50000, // Đơn hàng tối thiểu 50k mới được sử dụng
    maxUses: 500,           // số lượt dùng
    currentUses: 0,
    startDate: DateTime(2023, 05, 1, 00, 00, 00), // Ngày bắt đầu là 01/05/2023 0:0:0
    expiryDate: DateTime(2024, 10, 31, 23, 59, 59), // Ngày hết hạn là 31/10/2024 23:59:59
    isHidden: false,
  ),
  Voucher(
    id: '2',
    voucherName: 'GIAM100K',
    displayName: 'Nhập mã "GIAM100K" giảm 100k trên giá món',
    discountPercentage: 20,
    maxDiscount: 100000,  // Tối đa giảm 100k
    minOrderValue: 100000, // Đơn hàng tối thiểu 100k mới được sử dụng
    maxUses: 50,
    currentUses: 0,
    startDate: DateTime(2023, 05, 1, 00, 00, 00), // Ngày bắt đầu là 01/05/2023 0:0:0
    expiryDate: DateTime(2024, 10, 31, 23, 59, 59), // Ngày hết hạn là 31/10/2024 23:59:59
    isHidden: false,
  ),
  Voucher(
    id: '3',
    voucherName: 'TIECVUI50',
    displayName: 'Nhập mã "TIECVUI50" giảm 50k trên giá món',
    discountPercentage: 50,
    maxDiscount: 100000,  // Tối đa giảm 100k
    minOrderValue: 500000, // Đơn hàng tối thiểu 500k mới được sử dụng
    maxUses: 50,
    currentUses: 0,
    startDate: DateTime(2023, 05, 1, 00, 00, 00), // Ngày bắt đầu là 01/05/2023 0:0:0
    expiryDate: DateTime(2024, 10, 31, 23, 59, 59), // Ngày hết hạn là 31/10/2024 23:59:59
    isHidden: false,
  ),
  Voucher(
    id: '4',
    voucherName: 'TIECVUI20',
    displayName: 'Nhập mã "TIECVUI20" giảm 20k trên giá món',
    discountPercentage: 100,
    maxDiscount: 20000,  // Tối đa giảm 20k
    minOrderValue: 50000, // Đơn hàng tối thiểu 50k mới được sử dụng
    maxUses: 10,
    currentUses: 0,
    startDate: DateTime(2023, 05, 1, 00, 00, 00), // Ngày bắt đầu là 01/05/2023 0:0:0
    expiryDate: DateTime(2024, 10, 31, 23, 59, 59), // Ngày hết hạn là 31/10/2024 23:59:59
    isHidden: false,
  ),
  Voucher(
    id: '5',
    voucherName: 'GIAM10K',
    displayName: 'Nhập mã "GIAM10K" giảm 10k trên giá món',
    discountPercentage: 10,
    maxDiscount: 30000,  // Tối đa giảm 30k
    minOrderValue: 200000, // Đơn hàng tối thiểu 200k mới được sử dụng
    maxUses: 10,
    currentUses: 0,
    startDate: DateTime(2023, 05, 1, 00, 00, 00), // Ngày bắt đầu là 01/05/2023 0:0:0
    expiryDate: DateTime(2024, 10, 31, 23, 59, 59), // Ngày hết hạn là 31/10/2024 23:59:59
    isHidden: false,
  ),
  Voucher(
    id: '6',
    voucherName: 'GIAM200K',
    displayName: 'Nhập mã "GIAM200K" giảm 200k trên giá món',
    discountPercentage: 10,
    maxDiscount: 200000,  // Tối đa giảm 30k
    minOrderValue: 1500000, // Đơn hàng tối thiểu 200k mới được sử dụng
    maxUses: 10,
    currentUses: 0,
    startDate: DateTime(2023, 05, 1, 00, 00, 00), // Ngày bắt đầu là 01/05/2023 0:0:0
    expiryDate: DateTime(2024, 10, 31, 23, 59, 59), // Ngày hết hạn là 31/10/2024 23:59:59
    isHidden: false,
  ),
  Voucher(
    id: '7',
    voucherName: 'XINCHAO',
    displayName: 'Nhập mã "XINCHAO" giảm 50k đơn hàng đầu tiên',
    discountPercentage: 100,
    maxDiscount: 50000,  // Tối đa giảm
    minOrderValue: 0, // Đơn hàng tối thiểu 0d mới được sử dụng
    maxUses: 10,
    currentUses: 0,
    startDate: DateTime(2023, 05, 1, 00, 00, 00), // Ngày bắt đầu là 01/05/2023 0:0:0
    expiryDate: DateTime(2024, 10, 31, 23, 59, 59), // Ngày hết hạn là 31/10/2024 23:59:59
    isHidden: true,
  ),
  Voucher(
    id: '8',
    voucherName: 'CUOITUAN',
    displayName: 'Nhập mã "CUOITUAN" giảm 30k trên giá món',
    discountPercentage: 100,
    maxDiscount: 30000,  // Tối đa giảm
    minOrderValue: 0, // Đơn hàng tối thiểu 0d mới được sử dụng
    maxUses: 10,
    currentUses: 0,
    startDate: DateTime(2023, 05, 1, 00, 00, 00), // Ngày bắt đầu là 01/05/2023 0:0:0
    expiryDate: DateTime(2024, 10, 31, 23, 59, 59), // Ngày hết hạn là 31/10/2024 23:59:59
    isHidden: true,
  ),
  Voucher(
    id: '9',
    voucherName: 'TRIAN',
    displayName: 'Nhập mã "TRIAN" giảm 40k cho khách hàng thân thiết',
    discountPercentage: 100,
    maxDiscount: 40000,  // Tối đa giảm
    minOrderValue: 40000, // Đơn hàng tối thiểu 40k mới được sử dụng
    maxUses: 1,
    currentUses: 0,
    startDate: DateTime(2023, 05, 1, 00, 00, 00), // Ngày bắt đầu là 01/05/2023 0:0:0
    expiryDate: DateTime(2024, 10, 31, 23, 59, 59), // Ngày hết hạn là 31/10/2024 23:59:59
    isHidden: true,
  ),
  // ... [Thêm các voucher khác tùy ý]
];
