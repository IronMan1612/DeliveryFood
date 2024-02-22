import 'package:flutter/material.dart';

class appbarr extends StatelessWidget {
  const appbarr({super.key, this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.only(left: 20, right: 20),
      height: 45,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () {
              // Navigator.pop(context);
            },
            child: Image.asset('assets/back.png'),
          ),
          Text(
            text!,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
          ),
          const SizedBox(
            width: 30,
          )
        ],
      ),
    );
  }
}
