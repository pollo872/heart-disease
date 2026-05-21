import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String hint;
  // final String title;
  final List<T> items;
  final T? value;
  final Function(T?) onChanged;

  const CustomDropdown({
    super.key,
    required  this.hint,
    // required this.title,
    required this.items,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return _buildDropdown(hint: hint, items: items, value: value, onChanged: onChanged);
  }


   Widget _buildDropdown<T>({
    required String hint,
    required List<T> items,
    required T? value,
    required ValueChanged<T?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          hint: Text('DropDownHint.$hint'.tr(),
              style: const TextStyle(color: Colors.black38, fontSize: 14)),
          value: value,
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
          items: items
              .map((e) => DropdownMenuItem<T>(
                    value: e,
                    child: Text(e.toString(),
                        style: const TextStyle(fontSize: 14)),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}