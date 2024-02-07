import 'package:campus_app/widgets/remove_glow_behaviour.dart';
import 'package:campus_app/widgets/text_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/Constants.dart';
import '../constants/Sizes.dart';

typedef VoidCallback = void Function();

class InputWidget extends StatefulWidget {

  void Function(String) onInputChanged;
  void Function(String) onInputSubmitted;
  void Function(bool) onFocusChanged;

  String placeHolder, text;
  bool passwordInput, placeHolderInsideOfInput;
  int maxLength, maxLines;
  TextInputType textInputType;
  Color color, textColor, placeHolderColor;
  FocusNode focus = FocusNode();

  InputWidget({super.key, required this.onInputChanged, required this.onFocusChanged, required this.onInputSubmitted, this.placeHolder = "", this.text = "", this.passwordInput = false, this.maxLength = 1000, this.maxLines = 1, this.textInputType = TextInputType.text, this.color = lightGrey, this.textColor = black, this.placeHolderColor = black, this.placeHolderInsideOfInput = true});

  @override
  State<StatefulWidget> createState() {
    return _InputWidgetState();
  }

}

class _InputWidgetState extends State<InputWidget> {

  late Color currentColor;
  late TextEditingController inputController;


  @override
  void initState() {
    super.initState();
    currentColor = widget.color;
    inputController = TextEditingController(text: widget.text);
    widget.focus.addListener(onFocusChange);
  }

  void onFocusChange(){
    widget.onFocusChanged(widget.focus.hasFocus);
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: EdgeInsets.only(bottom: !widget.placeHolderInsideOfInput ? Sizes.paddingSmall * 0.5 : 0),
          width: double.infinity,
          child: !widget.placeHolderInsideOfInput ? DMSansRegularText(
            text: widget.placeHolder,
            size: Sizes.textSizeSmall,
            color: widget.placeHolderColor,
          ) : Container(),
        ),
        Container(
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(Sizes.borderRadius),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: Sizes.paddingSmall
          ),
          child: RemoveGlowBehavior(
            child: Theme(
              data: Theme.of(context).copyWith(
                textSelectionTheme: TextSelectionThemeData(
                  cursorColor: green,
                  selectionColor: green.withAlpha(100),
                  selectionHandleColor: green
                )
              ),
              child: TextField(
                focusNode: widget.focus,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(widget.maxLength)
                ],
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: widget.placeHolderInsideOfInput ? widget.placeHolder : "",
                  hintStyle: TextStyle(
                    color: widget.placeHolderColor,
                    fontFamily: "DM Sans Medium",
                    fontSize: Sizes.textSizeSmall * 0.9,
                  ),
                ),
                onSubmitted: (String value){
                  widget.onInputSubmitted(value);
                },
                onChanged: (String value){
                  widget.text = value;
                  widget.onInputChanged(value);
                },
                obscureText: widget.passwordInput,
                controller: inputController,
                maxLines: widget.maxLines,
                cursorColor: green,
                autocorrect: false,
                textAlign: TextAlign.left,
                keyboardType: widget.textInputType,
                style: TextStyle(
                  color: widget.textColor,
                  fontFamily: "DM Sans Medium",
                  fontSize: Sizes.textSizeSmall * 0.9,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
