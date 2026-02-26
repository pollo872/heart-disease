import 'package:flutter/material.dart';

// --- PasswordFormFeild ---
class PasswordFormFeild extends StatefulWidget {
  final String formTitle;

  // ADD CONTROLLER AND VALIDATOR
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const PasswordFormFeild({
    super.key,
    required this.formTitle,
    this.controller, // Made optional
    this.validator, // Made optional
  });

  @override
  State<PasswordFormFeild> createState() => _PasswordFormFeildState();
}

class _PasswordFormFeildState extends State<PasswordFormFeild> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 327, // Consider using double.infinity for responsiveness
      // height: 80, // Remove fixed height when using validators/error messages
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.formTitle,
              style: TextStyle(
                color: Color(0xff626262),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          TextFormField(
            controller: widget.controller,
            // ATTACHED CONTROLLER
            validator: widget.validator,
            // ATTACHED VALIDATOR
            obscureText: _isObscured,
            keyboardType: TextInputType.visiblePassword,
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              suffixIcon: IconButton(
                icon: Icon(
                  _isObscured ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () {
                  setState(() {
                    _isObscured = !_isObscured;
                  });
                },
              ),
              iconColor: Colors.black,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 15,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xffe9e9e9)),
                gapPadding: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xffe9e9e9)),
                gapPadding: 10,
              ),
              // ADDED errorBorder for consistency with validation
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red),
                gapPadding: 10,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red, width: 2.0),
                gapPadding: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- AnyFormFeild ---
class AnyFormFeild extends StatefulWidget {
  final String formTitle;
  final TextInputType keyboardType;
  final TextEditingController? controller;
  final String? Function(String?)? validator;

  const AnyFormFeild({
    super.key,
    required this.formTitle,
    required this.keyboardType,
    this.controller,
    this.validator,
  });

  @override
  State<AnyFormFeild> createState() => _AnyFormFeildState();
}

class _AnyFormFeildState extends State<AnyFormFeild> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 327, // Consider using double.infinity for responsiveness
      // height: 80, // Remove fixed height when using validators/error messages
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.formTitle,
              style: TextStyle(
                color: Color(0xff626262),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          TextFormField(
            controller: widget.controller, // ATTACHED CONTROLLER
            validator: widget.validator, // ATTACHED VALIDATOR
            keyboardType: widget.keyboardType,
            decoration: InputDecoration(
              floatingLabelBehavior: FloatingLabelBehavior.never,
              iconColor: Colors.black,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 30,
                vertical: 15,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xffe9e9e9)),
                gapPadding: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xffe9e9e9)),
                gapPadding: 10,
              ),
              // ADDED errorBorder for consistency with validation
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red),
                gapPadding: 10,
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red, width: 2.0),
                gapPadding: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
