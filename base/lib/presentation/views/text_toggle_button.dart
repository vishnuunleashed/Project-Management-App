

import 'package:flutter/material.dart';

class TextToggleButton extends StatefulWidget {
  final String buttonOneText;
  final String buttonTwoText;
  final double height;
  final double width;
  final Function onTapFirstButton;
  final Function onTapSecongButton;
  final bool selectFirstButton;
  final bool isEnabled;

  ///[firstbutton,secondbutton]

  const TextToggleButton(
      {super.key,
      required this.buttonOneText,
      required this.buttonTwoText,
      required this.height,
      required this.width,
      required this.onTapFirstButton,
      required this.onTapSecongButton,
      required this.selectFirstButton,
      this.isEnabled = true});

  @override
  State<TextToggleButton> createState() => _TextToggleButtonState();
}

class _TextToggleButtonState extends State<TextToggleButton> {
  List<bool> isSelected = [true, false];


  @override
  Widget build(BuildContext context) {

      isSelected = [widget.selectFirstButton, !widget.selectFirstButton];

    return SizedBox(
      width: widget.width,
      child: Row(
        children: [
          Expanded(
              child: InkWell(
            onTap: !widget.isEnabled
                ? null
                : () {
                    setState(() {
                      isSelected[0] = true;
                      isSelected[1] = false;
                    });
                    widget.onTapFirstButton();
                  },
            child: TweenAnimationBuilder(
                tween: ColorTween(
                  begin: Colors.grey,
                  end:
                      isSelected[0] ? Theme.of(context).primaryColor : Theme.of(context).disabledColor,
                ),
                duration: Duration(milliseconds: 300),
                builder: (_, color, __) => Container(
                      height: widget.height,
                      decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(30)),
                      child: Center(child: Text(widget.buttonOneText)),
                    )),
          )),
          SizedBox(width: 10),
          Expanded(
              child: InkWell(
                  onTap: !widget.isEnabled
                      ? null
                      : () {
                          setState(() {
                            isSelected[0] = false;
                            isSelected[1] = true;
                          });
                          widget.onTapSecongButton();
                        },
                  child: TweenAnimationBuilder(
                      tween: ColorTween(
                        begin: Colors.grey,
                        end: isSelected[1]
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).disabledColor,
                      ),
                      duration: Duration(milliseconds: 300),
                      builder: (_, color, __) => Container(
                          height: widget.height,
                          decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(30)),
                          child: Center(child: Text(widget.buttonTwoText)))))),
        ],
      ),
    );
  }
}
