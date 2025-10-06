import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './dtmf_button_widget.dart';

class KeypadGridWidget extends StatelessWidget {
  final Function(String) onNumberPressed;
  final Function(String) onNumberLongPressed;

  const KeypadGridWidget({
    Key? key,
    required this.onNumberPressed,
    required this.onNumberLongPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> keypadData = [
      {'number': '1', 'letters': '', 'longPress': '+'},
      {'number': '2', 'letters': 'ABC', 'longPress': '2'},
      {'number': '3', 'letters': 'DEF', 'longPress': '3'},
      {'number': '4', 'letters': 'GHI', 'longPress': '4'},
      {'number': '5', 'letters': 'JKL', 'longPress': '5'},
      {'number': '6', 'letters': 'MNO', 'longPress': '6'},
      {'number': '7', 'letters': 'PQRS', 'longPress': '7'},
      {'number': '8', 'letters': 'TUV', 'longPress': '8'},
      {'number': '9', 'letters': 'WXYZ', 'longPress': '9'},
      {'number': '*', 'letters': '', 'longPress': '*', 'special': true},
      {'number': '0', 'letters': '+', 'longPress': '+'},
      {'number': '#', 'letters': '', 'longPress': '#', 'special': true},
    ];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 4.w,
          mainAxisSpacing: 3.h,
          childAspectRatio: 1.0,
        ),
        itemCount: keypadData.length,
        itemBuilder: (context, index) {
          final buttonData = keypadData[index];
          return DtmfButtonWidget(
            number: buttonData['number'] as String,
            letters: buttonData['letters'] as String,
            isSpecialButton: buttonData['special'] == true,
            onPressed: () => onNumberPressed(buttonData['number'] as String),
            onLongPressed: buttonData['longPress'] != null
                ? () => onNumberLongPressed(buttonData['longPress'] as String)
                : null,
          );
        },
      ),
    );
  }
}
