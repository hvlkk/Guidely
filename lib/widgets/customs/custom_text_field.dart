import 'package:flutter/material.dart';
import 'package:guidely/misc/common.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String header;

  const CustomTextField({
    super.key,
    this.header = '',
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
      },
      child: TextFormField(
        decoration: InputDecoration(
          hintText: header,
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: MainColors.divider),
          ),
          fillColor: MainColors.textHint,
        ),
        keyboardType: TextInputType.multiline,
        controller: controller,
        maxLines: 5,
      ),
      onTapDown: (_) {
        FocusScope.of(context).unfocus(); // Close the keyboard
      },
    );
  }
}
