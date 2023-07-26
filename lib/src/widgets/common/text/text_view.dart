import 'package:flutter/material.dart';

class LMTextView extends StatelessWidget {
  final String text;
  final bool selectable;
  final Function()? onTap;

  final int? maxLines;
  final TextOverflow? overflow;
  final TextAlign textAlign;
  final TextStyle? textStyle;

  final Color? backgroundColor;
  final double? borderRadius;
  final EdgeInsets? padding;

  const LMTextView({
    Key? key,
    required this.text,
    this.selectable = true,
    this.textAlign = TextAlign.start,
    this.onTap,
    this.textStyle,
    this.maxLines,
    this.overflow,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    TextStyle? defaultTextStyle = Theme.of(context).textTheme.bodyMedium;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: backgroundColor,
          // borderRadius: BorderRadius.circular(borderRadius ?? 0),
          shape: BoxShape.circle,
        ),
        child: Text(
          text,
          overflow: overflow ?? TextOverflow.fade,
          maxLines: maxLines,
          style: textStyle ?? defaultTextStyle,
        ),
      ),
    );
  }
}
