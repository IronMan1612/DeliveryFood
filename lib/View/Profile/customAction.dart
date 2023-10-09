import 'package:flutter/material.dart';

class action extends StatelessWidget {
  final String? text;
  final VoidCallback? onTap;
  final IconData? icon; // Icon data
  final Color? iconColor; // Màu của icon
  final double? iconSize; // Kích thước của icon

  const action({
    Key? key,
    this.text,
    this.onTap,
    this.icon,
    this.iconColor = Colors.black,  // Màu mặc định nếu không chỉ định
    this.iconSize = 26.0,  // Kích thước mặc định nếu không chỉ định
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        child: Row(
          children: [
            // Nếu có icon, thì hiển thị nó
            if (icon != null)
              Icon(
                icon,
                color: iconColor,
                size: iconSize,
              ),
            SizedBox(width: 10.0), // Khoảng cách giữa icon và text
            Expanded(
              child: Text(
                text!,
                style: const TextStyle(
                    fontSize: 14,
                    color: Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.w900),
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }
}
