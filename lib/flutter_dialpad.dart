library flutter_dialpad;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:flutter_dtmf/flutter_dtmf.dart';

class DialPad extends StatefulWidget {
  final ValueSetter<String> makeCall;
  final Color? buttonColor;
  final Color? buttonTextColor;
  final Color? dialButtonColor;
  final Color? dialButtonIconColor;
  final Color? backspaceButtonIconColor;
  final String? outputMask;
  final bool? enableDtmf;
  final bool shouldOval;

  DialPad({
    required this.makeCall,
    this.outputMask,
    this.buttonColor,
    this.buttonTextColor,
    this.dialButtonColor,
    this.dialButtonIconColor,
    this.backspaceButtonIconColor,
    this.enableDtmf,
    this.shouldOval = false,
  });

  @override
  _DialPadState createState() => _DialPadState();
}

class _DialPadState extends State<DialPad> {
  final TextEditingController textController = TextEditingController();
  late MaskTextInputFormatter maskFormatter;
  //late MaskedTextController textEditingController;
  var _value = "";
  var mainTitle = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "*", "0", "＃"];
  var subTitle = [
    "",
    "ABC",
    "DEF",
    "GHI",
    "JKL",
    "MNO",
    "PQRS",
    "TUV",
    "WXYZ",
    null,
    "+",
    null
  ];

  @override
  void initState() {
    // textEditingController = MaskedTextController(
    //     mask: widget.outputMask != null ? widget.outputMask : '(000) 000-0000');
    maskFormatter = MaskTextInputFormatter(
        mask: widget.outputMask ?? '(000) 000-0000',
        filter: {"#": RegExp(r'[0-9]')});
    super.initState();
  }

  _setText(String value) async {
    if (widget.enableDtmf == null || widget.enableDtmf!) {
      FlutterDtmf.playTone(digits: value);
    }

    setState(() {
      _value += value;
      textController.text = _value;
    });
  }

  List<Widget> _getDialerButtons() {
    var rows = <Widget>[]; //List<Widget>();
    var items = <Widget>[]; // List<Widget>();

    for (var i = 0; i < mainTitle.length; i++) {
      if (i % 3 == 0 && i > 0) {
        rows.add(Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: items));
        rows.add(const SizedBox(
          height: 12,
        ));
        items = <Widget>[]; //List<Widget>();
      }

      items.add(DialButton(
        title: mainTitle[i],
        subtitle: subTitle[i],
        color: widget.buttonColor,
        textColor: widget.buttonTextColor,
        shouldButtonOval: widget.shouldOval,
        onTap: _setText,
      ));
    }
    //To Do: Fix this workaround for last row
    rows.add(
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: items));
    rows.add(const SizedBox(
      height: 12,
    ));

    return rows;
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var sizeFactor = screenSize.height * 0.09852217;

    return Center(
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(20),
            child: TextFormField(
              readOnly: true,
              style: TextStyle(color: Colors.white, fontSize: sizeFactor / 2),
              textAlign: TextAlign.center,
              decoration: InputDecoration(border: InputBorder.none),
              controller: textController,
              inputFormatters: [maskFormatter],
            ),
          ),
          ..._getDialerButtons(),
          const SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Expanded(
                child: Container(),
              ),
              Expanded(
                child: Center(
                  child: DialButton(
                    icon: Icons.phone,
                    color: Colors.green,
                    shouldButtonOval: widget.shouldOval,
                    onTap: (value) {
                      widget.makeCall(_value);
                    },
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding:
                      EdgeInsets.only(right: screenSize.height * 0.03685504),
                  child: IconButton(
                    icon: Icon(
                      Icons.backspace,
                      size: sizeFactor / 2,
                      color: _value.isNotEmpty
                          ? (widget.backspaceButtonIconColor ?? Colors.white24)
                          : Colors.white24,
                    ),
                    onPressed: _value.isEmpty
                        ? null
                        : () {
                            if (_value.isNotEmpty) {
                              setState(() {
                                _value = _value.substring(0, _value.length - 1);
                                textController.text = _value;
                              });
                            }
                          },
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

class DialButton extends StatefulWidget {
  final Key? key;
  final String? title;
  final String? subtitle;
  final Color? color;
  final Color? textColor;
  final IconData? icon;
  final Color? iconColor;
  final ValueSetter<String>? onTap;
  final bool? shouldAnimate;
  final bool? shouldButtonOval;

  DialButton({
    this.key,
    this.title,
    this.subtitle,
    this.color,
    this.textColor,
    this.icon,
    this.iconColor,
    this.shouldAnimate,
    this.onTap,
    this.shouldButtonOval,
  });

  @override
  _DialButtonState createState() => _DialButtonState();
}

class _DialButtonState extends State<DialButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation _colorTween;
  Timer? _timer;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));
    _colorTween =
        ColorTween(begin: widget.color ?? Colors.white24, end: Colors.white)
            .animate(_animationController);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    if ((widget.shouldAnimate == null || widget.shouldAnimate!) &&
        _timer != null) _timer!.cancel();
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    var sizeFactor = screenSize.height * 0.09852217;

    return GestureDetector(
      onTap: () {
        if (widget.onTap != null) widget.onTap!(widget.title ?? '');

        if (widget.shouldAnimate == null || widget.shouldAnimate!) {
          if (_animationController.status == AnimationStatus.completed) {
            _animationController.reverse();
          } else {
            _animationController.forward();
            _timer = Timer(const Duration(milliseconds: 200), () {
              setState(() {
                _animationController.reverse();
              });
            });
          }
        }
      },
      child: ShouldOval(
          shouldOval: widget.shouldButtonOval ?? false,
          child: AnimatedBuilder(
              animation: _colorTween,
              builder: (context, child) => Container(
                    color: _colorTween.value,
                    height: sizeFactor,
                    width: sizeFactor,
                    child: Center(
                        child: widget.icon == null
                            ? widget.subtitle != null
                                ? Column(
                                    children: <Widget>[
                                      Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8),
                                          child: Text(
                                            widget.title ?? '',
                                            style: TextStyle(
                                                fontSize: sizeFactor / 2,
                                                color: widget.textColor ??
                                                    Colors.white),
                                          )),
                                      Text(widget.subtitle ?? '',
                                          style: TextStyle(
                                              color: widget.textColor ??
                                                  Colors.white))
                                    ],
                                  )
                                : Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      widget.title ?? '',
                                      style: TextStyle(
                                          fontSize: widget.title == "*" &&
                                                  widget.subtitle == null
                                              ? screenSize.height * 0.0862069
                                              : sizeFactor / 2,
                                          color:
                                              widget.textColor ?? Colors.white),
                                    ))
                            : Icon(widget.icon,
                                size: sizeFactor / 2,
                                color: widget.iconColor ?? Colors.white)),
                  ))),
    );
  }
}

class ShouldOval extends StatelessWidget {
  bool shouldOval;
  Widget child;
  ShouldOval({Key? key, this.shouldOval = false, required this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return shouldOval
        ? ClipOval(
            child: child,
          )
        : child;
  }
}
