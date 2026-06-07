import 'package:flutter/material.dart';

class YesNoSelector extends StatefulWidget {
  final String? value;
  final ValueChanged<String> onChanged;

  const YesNoSelector({
    super.key,
    this.value = 'Yes',
    required this.onChanged,
  });

  @override
  State<YesNoSelector> createState() => _YesNoSelectorState();
}

class _YesNoSelectorState extends State<YesNoSelector> {
  late String? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.value ?? 'Yes';
    // ✅ ابعت الـ default فوراً من غير ما اليوزر يدوس
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(_selected!);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: ['Yes', 'No'].map((option) {
        final selected = _selected == option;
        print('Option: $option, Selected: $selected, _selected: $_selected');
        return GestureDetector(
          onTap: () {
            setState(() => _selected = option);
            widget.onChanged(option);
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? const Color(0xFF1E63F3) : Colors.grey,
                    width: 2,
                  ),
                ),
                child: selected
                    ? Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1E63F3),
                          ),
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 6),
              Text(option),
              const SizedBox(width: 20),
            ],
          ),
        );
      }).toList(),
    );
  }
}
