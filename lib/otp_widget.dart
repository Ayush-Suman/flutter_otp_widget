library otp_widget;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OTPWidget extends StatefulWidget {
  final String? title;
  final TextStyle? titleStyle;
  final TextEditingController? controller;
  final InputBorder? enabledBorder;
  final InputBorder? disabledBorder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final InputBorder? focusedErrorBorder;
  final Color? cursorColor;
  final String? hint;
  final TextStyle? hintStyle;
  final int otpSize;

  OTPWidget({
    this.title,
    this.titleStyle,
    this.controller,
    this.otpSize = 6,
    this.hint,
    this.hintStyle,
    this.focusedBorder,
    this.enabledBorder,
    this.disabledBorder,
    this.errorBorder,
    this.focusedErrorBorder,
    this.cursorColor,
  });

  @override
  State<OTPWidget> createState() => _OTPWidgetState();
}

class _OTPWidgetState extends State<OTPWidget> {
  late final List<FocusNode> focusNodes;
  late final List<TextEditingController> controllers;
  late final TextEditingController mainController;
  late Function() listener;
  late Function() callback;

  @override
  void initState() {
    mainController = widget.controller ?? TextEditingController();
    focusNodes = List.generate(widget.otpSize, (index) => FocusNode());
    controllers =
        List.generate(widget.otpSize, (index) => TextEditingController());
    listener = () {
      for (int i = 0; i < widget.otpSize; i++) {
        try {
          if (controllers[i].text !=
              mainController.text.characters.elementAt(i))
            controllers[i].text = mainController.text.characters.elementAt(i);
        } catch (e) {
          print("No value in $i otp field");
        }
      }
    };
    listener();
    mainController.addListener(listener);

    callback = () {
      try {
        mainController.text =
            "${controllers[0].text.characters.last}${controllers[1].text.characters.last}${controllers[2].text.characters.last}${controllers[3].text.characters.last}${controllers[4].text.characters.last}${controllers[5].text.characters.last}";
        print(mainController.text);
      } catch (e) {
        print(e);
      }
    };

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //final List<TextEditingController> controllers = [];//useOtpControllersWithTextEditingController(controller);

    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          widget.title != null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(widget.title!, style: widget.titleStyle))
              : SizedBox(),
          Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                widget.otpSize,
                (index) => Flexible(
                  child: RawKeyboardListener(
                    focusNode: FocusNode(),
                    onKey: (event) {
                      if (event.logicalKey == LogicalKeyboardKey.backspace &&
                          event.runtimeType.toString() == 'RawKeyDownEvent') {
                        if (index == 0) {
                          controllers[index].text = "";
                          callback();
                          focusNodes[index].unfocus();
                        } else {
                          controllers[index].text = "";
                          callback();
                          focusNodes[index].unfocus();
                          focusNodes[index - 1].requestFocus();
                        }
                      }
                    },
                    child: TextField(
                      textAlign: TextAlign.center,
                      showCursor: false,
                      enableInteractiveSelection: false,
                      keyboardType: TextInputType.number,
                      controller: controllers[index],
                      onChanged: (n) {
                        if (index == widget.otpSize - 1) {
                          controllers[index].text = n.characters.last;
                          callback();
                          focusNodes[index].unfocus();
                        } else {
                          controllers[index].text = n.characters.last;
                          callback();
                          focusNodes[index].unfocus();
                          focusNodes[index + 1].requestFocus();
                          Future.delayed(Duration(milliseconds: 100), () {
                            controllers[index].selection =
                                TextSelection.collapsed(
                                    offset: controllers[index].text.length);
                          });
                        }
                      },
                      onTap: () {
                        focusNodes[index].requestFocus();
                        controllers[index].selection = TextSelection.collapsed(
                            offset: controllers[index].text.length);
                      },
                      focusNode: focusNodes[index],
                      cursorColor: widget.cursorColor ??
                          widget.focusedBorder?.borderSide.color ??
                          null,
                      decoration: InputDecoration(
                        hintText: widget.hint,
                        hintStyle: widget.hintStyle,
                        alignLabelWithHint: true,
                        focusedBorder: widget.focusedBorder,
                        enabledBorder: widget.enabledBorder,
                        disabledBorder: widget.disabledBorder,
                        errorBorder: widget.errorBorder,
                        focusedErrorBorder: widget.focusedErrorBorder,
                      ),
                    ),
                  ),
                  flex: 2,
                ),
              ))
        ]);
  }

  @override
  void dispose() {
    mainController.removeListener(listener);

    super.dispose();
  }
}
