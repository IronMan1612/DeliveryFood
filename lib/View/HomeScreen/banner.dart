import 'dart:async';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Data/banner_list_data.dart';

class BannerWidget extends StatefulWidget {
  @override
  _BannerWidgetState createState() => _BannerWidgetState();
}

class _BannerWidgetState extends State<BannerWidget> {
  final PageController _pageController = PageController();
  int currentPage = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      if (currentPage < banners.length - 1) {
        currentPage++;
      } else {
        currentPage = 0;
      }

      _pageController.animateToPage(
        currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeIn,
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          height: 190,
          width: double.infinity,
          child: PageView.builder(
            controller: _pageController,
            itemCount: banners.length,
            itemBuilder: (context, index) {
              return Image.asset(
                banners[index],
                fit: BoxFit.contain,
              );
            },
            onPageChanged: (int index) {
              setState(() {
                currentPage = index;
              });
            },
          ),
        ),
        Positioned(  // Sử dụng Positioned để xác định vị trí của DotsIndicator trong Stack
          bottom: 30,  // Đặt ở dưới cùng của Stack và cách đáy 10px
          left: 0,
          right: 0,
          child: Center(  // Sử dụng Center để căn giữa DotsIndicator theo chiều ngang
            child: DotsIndicator(
              dotsCount: banners.length,
              position: currentPage.toInt(),
              decorator: const DotsDecorator(
                color: Colors.grey,
                activeColor: Colors.orange,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {        //Huỷ banner khi chuyển widget ở bottomBar
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

}
