import 'package:flutter/material.dart';

import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class nearmeitem extends StatelessWidget {
  const nearmeitem({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){},
      child: Container(
        padding: const EdgeInsets.only(left: 20, right: 20),
        child: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 15),
              child: Image.asset('assets/Rectangle 6.png'),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: const EdgeInsets.all(4),
                    child: const Text(
                      'ShopeeFood',
                      style: TextStyle(
                          fontSize: 14,
                          color: Color.fromARGB(255, 0, 0, 0),
                          fontWeight: FontWeight.w900),
                    )),
                Container(
                    margin: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Image.asset('assets/11.png')),
                        const Text('257 Nguyễn Văn Linh'),
                      ],
                    )),
                Container(
                    margin: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: Image.asset('assets/clock 1.png')),
                        const Text('3 min - 1.1 km'),
                      ],
                    )),
                Container(
                    margin: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        Image.asset('assets/Vector.png'),
                        Image.asset('assets/Vector.png'),
                        Image.asset('assets/Vector.png'),
                        Image.asset('assets/Vector.png'),
                        Image.asset('assets/Vector.png'),
                      ],
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
