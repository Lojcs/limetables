import 'package:flutter/material.dart';
import 'package:limetables/src/extensions/context_extension.dart';

enum TextFieldSize { small, medium, large }

class CustomTextField extends StatelessWidget {
  final String hintText;
  final String initialValue;
  final TextFieldSize size;
  final bool interactive;
  final bool numberKeyboard;
  final void Function(String value)? onChanged;
  const CustomTextField(
      {this.hintText = "",
      this.initialValue = "",
      this.size = TextFieldSize.medium,
      this.interactive = true,
      this.numberKeyboard = false,
      this.onChanged,
      super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: switch (size) {
        TextFieldSize.small => 20,
        TextFieldSize.medium => 30,
        TextFieldSize.large => 60
      },
      child: TextFormField(
        keyboardType: numberKeyboard ? TextInputType.number : null,
        enabled: interactive,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        initialValue: initialValue,
        style: switch (size) {
          TextFieldSize.small =>
            context.theme.textTheme.titleMedium!.copyWith(color: Colors.white),
          TextFieldSize.medium =>
            context.theme.textTheme.titleLarge!.copyWith(color: Colors.white),
          TextFieldSize.large => context.theme.textTheme.headlineMedium!
              .copyWith(color: Colors.white)
        },
        decoration: InputDecoration(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          hintText: hintText,
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey)),
          border: const OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }
}
