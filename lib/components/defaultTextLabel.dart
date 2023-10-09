import 'package:flutter/material.dart';

class DefaultTextLabel extends StatelessWidget {
  final String? text;
  final TextEditingController? controller;
  final bool obscureText;
  final FormFieldValidator<String>? validator;

  const DefaultTextLabel({
    Key? key,
    required this.text,
    this.controller,
    this.obscureText = false,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 25),
      margin: const EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width,
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xffECF0F1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: text!,
          hintStyle: const TextStyle(fontSize: 15),
        ),
        validator: validator,
      ),
    );
  }
}
