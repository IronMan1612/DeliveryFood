import 'package:DeliveryFood/Model/food_item.dart';

// Dữ liệu cho mỗi danh mục
List<FoodItem> foodsForCategory1 = [
  FoodItem(
    id: '1',
    name: 'Pizza',
    description:
    'Là món ăn đặc trưng của Italy, pizza có nguồn gốc từ người Hy Lạp, với phiên bản đầu tiên là bánh mì mỏng, dẹt nướng với thảo mộc. Pizza là món ăn nhanh phổ biến trên thế giới. Bạn có thể tìm thấy loại bánh này ở nhiều nhà hàng trong các thành phố.',
    price: 150000,
    imagePath: 'assets/imgFood/pizza.png',
    isAvailable: true,
    category: '1',
    //... (thông tin khác)
  ),
  FoodItem(
    id: '2',
    name: 'Mì trộn ',
    description: 'Mì trộn tương đen là món ăn nổi tiếng trong văn hoá ẩm thực Hàn Quốc và được yêu thích trên toàn thế giới. Với sự kết hợp giữa sợi mì dai ngon trứ danh hoà nước sốt độc quyền ',
    price: 50000,
    imagePath: 'assets/imgFood/mitron.png',
    isAvailable: true,
    category: '1',
  ),
  FoodItem(
    id: '3',
    name: 'Sushi',
    description: 'Sushi là một món ăn Nhật Bản gồm cơm trộn giấm (shari) kết hợp với các nguyên liệu khác (neta). Neta và hình thức trình bày sushi rất đa dạng, nhưng nguyên liệu chính mà tất cả các loại sushi đều có là shari. Neta phổ biến nhất là hải sản. Thịt sống cắt lát gọi riêng là sashimi. ',
    price: 65000,
    imagePath: 'assets/imgFood/sushi.png',
    isAvailable: true,
    category: '1',
  ),
  FoodItem(
    id: '4',
    name: 'Phở bò',
    description: 'Phở bò truyền thống với nước dùng thơm ngon ',
    price: 50000,
    imagePath: 'assets/imgFood/pho.png',
    isAvailable: false,
    category: '1',
  ),
  FoodItem(
    id: '5',
    name: 'Salad',
    description: 'Món khai vị gồm rau xà lách , cà chua , sốt mayonaise  ',
    price: 30000,
    imagePath: 'assets/imgFood/salad.png',
    isAvailable: true,
    category: '1',
  ),
  // ... (các món ăn khác)
];

List<FoodItem> foodsForCategory2 = [
  FoodItem(
    id: '6',
    name: 'Frezze Trà xanh',
    description: 'Thức uống rất được ưa chuộng! Trà xanh thượng hạng từ cao nguyên Việt Nam, kết hợp cùng đá xay, thạch trà dai dai, thơm ngon và một lớp kem dày phủ lên trên',
    price: 55000,
    imagePath: 'assets/imgFood/highland1.png',
    isAvailable: true,
    category: '2',
  ),
  FoodItem(
    id: '7',
    name: 'Cà phê đen đá',
    description: 'Không ngọt ngào như Bạc sỉu hay Cà phê sữa, Cà phê đen mang trong mình phong vị trầm lắng, thi vị hơn',
    price: 29000,
    imagePath: 'assets/imgFood/highland2.png',
    isAvailable: true,
    category: '2',
  ),
  FoodItem(
    id: '8',
    name: 'Trà sen vàng',
    description: 'Trà sen vàng là món “đỉnh” trong menu đồ uống của Highland Coffee. Món thức uống với hương vị thanh mát đã giúp Highland Coffee hấp dẫn được một lượng lớn khách',
    price: 45000,
    imagePath: 'assets/imgFood/highland3.png',
    isAvailable: true,
    category: '2',
  ),
  FoodItem(
    id: '9',
    name: 'Cà phê sữa lon',
    description: 'cà phê dạng lon tiện lợi',
    price: 20000,
    imagePath: 'assets/imgFood/highland4.png',
    isAvailable: false,
    category: '2',
  ),
  // ... (các món ăn khác)
];

List<FoodItem> foodsForCategory3 = [
  FoodItem(
    id: '10',
    name: 'Bánh Macron',
    description:
    ' Một loại bánh ngọt của Pháp được làm từ lòng trắng trứng, đường bột, ... ',
    price: 50000,
    imagePath: 'assets/imgFood/cake1.png',
    isAvailable: true,
    category: '3',
  ),
  FoodItem(
    id: '11',
    name: 'Bánh su kem',
    description:
    ' Bánh su kem (tiếng Pháp: chou à la crème) là món bánh ngọt ở dạng kem sữa được làm từ các nguyên liệu như bột mì, trứng, sữa, bơ.',
    price: 50000,
    imagePath: 'assets/imgFood/cake2.png',
    isAvailable: true,
    category: '3',
  ),
  FoodItem(
    id: '12',
    name: 'Red velet',
    description:
    ' Theo truyền thống, red velvet là loại bánh chocolate nhiều lớp có màu đỏ, nâu đỏ, đỏ thẫm hoặc đỏ tươi, chia lớp bởi lớp kem phủ bằng cream cheese hoặc ermine trắng.',
    price: 50000,
    imagePath: 'assets/imgFood/cake3.png',
    isAvailable: true,
    category: '3',
  ),
  FoodItem(
    id: '13',
    name: 'Bánh trung thu',
    description:
    ' Bánh truyền thống của người Việt , nhân thập cẩm ',
    price: 120000,
    imagePath: 'assets/imgFood/cake4.png',
    isAvailable: false,
    category: '3',
  ),
  // ... (các món ăn khác)
];
// Dữ liệu cho tất cả các món
List<FoodItem> allFoods = [
  ...foodsForCategory1,
  ...foodsForCategory2,
  ...foodsForCategory3,
  // ... (nếu có thêm danh mục khác, thêm ở đây)
];

// ... (dữ liệu cho các danh mục khác)


