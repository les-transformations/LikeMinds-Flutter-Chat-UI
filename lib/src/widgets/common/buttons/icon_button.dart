import 'package:flutter/material.dart';
import 'package:likeminds_chat_ui_fl/src/widgets/common/icon/icon.dart';
import 'package:likeminds_chat_ui_fl/src/widgets/common/text/text_view.dart';

class LMIconButton extends StatefulWidget {
  const LMIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.title,
    this.activeIcon,
    this.containerSize,
    this.borderRadius,
    this.backgroundColor,
  });

  final LMIcon icon;
  final Function(bool activeStatus) onTap;
  final LMIcon? activeIcon;
  final LMTextView? title;

  final double? containerSize;
  final double? borderRadius;
  final Color? backgroundColor;

  @override
  State<LMIconButton> createState() => _LMIconButtonState();
}

class _LMIconButtonState extends State<LMIconButton> {
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isActive = !_isActive;
        });
        widget.onTap(_isActive);
      },
      child: Container(
        color: Colors.transparent,
        child: Column(
          children: [
            Container(
              height: widget.containerSize ?? 32,
              width: widget.containerSize ?? 32,
              decoration: BoxDecoration(
                color: widget.backgroundColor ?? Colors.transparent,
                borderRadius: BorderRadius.circular(widget.borderRadius ?? 16),
              ),
              child: _isActive ? widget.activeIcon ?? widget.icon : widget.icon,
            ),
            if (widget.title != null) const SizedBox(height: 6),
            if (widget.title != null) widget.title!,
          ],
        ),
      ),
    );
  }
}
