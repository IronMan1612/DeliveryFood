import 'package:flutter/material.dart';
class DefaultButton extends StatelessWidget {
  const DefaultButton(
      {super.key,
      required this.text,
      required this.press,
      required this.color});
  final String? text;
  final Function press;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: press as void Function()?,
      child: Container(
        margin: const EdgeInsets.all(15),
        width: MediaQuery.of(context).size.width,
        height: 52,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: color,
        ),
        child: Center(
          child: Text(
            text!,
            style: const TextStyle(
                fontSize: 23, color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}
