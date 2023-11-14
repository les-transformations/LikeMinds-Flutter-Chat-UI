import 'package:flutter/material.dart';
import 'package:likeminds_chat_ui_fl/likeminds_chat_ui_fl.dart';

class LMMenu extends StatelessWidget {
  const LMMenu({
    super.key,
    required this.menuItems,
    required this.child,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.semanticLabel,
    this.shape,
    this.color,
    this.constraints,
    this.clipBehavior,
    this.itemPadding,
  });

  final List<LMMenuItemUI> menuItems;
  final Widget child;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final String? semanticLabel;
  final ShapeBorder? shape;
  final Color? color;
  final BoxConstraints? constraints;
  final Clip? clipBehavior;
  final EdgeInsets? itemPadding;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPressStart: (details) {
        if (menuItems.isNotEmpty) {
          final RenderBox overlay =
              Overlay.of(context).context.findRenderObject() as RenderBox;

          final RelativeRect position = RelativeRect.fromRect(
            Rect.fromPoints(
              details.globalPosition,
              details.globalPosition.translate(0, 0),
            ),
            overlay.localToGlobal(Offset.zero) & overlay.size,
          );
          showMenu(
              context: context,
              position: position,
              elevation: elevation,
              shadowColor: shadowColor,
              surfaceTintColor: surfaceTintColor,
              semanticLabel: semanticLabel,
              shape: shape,
              color: color,
              constraints: constraints,
              clipBehavior: clipBehavior ?? Clip.none,
              items: [
                for (LMMenuItemUI menuItem in menuItems)
                  PopupMenuItem(
                    onTap: () {
                      menuItem.onTap();
                    },
                    padding: itemPadding ?? EdgeInsets.zero,
                    child: ListTile(
                      leading: menuItem.leading,
                      title: menuItem.title,
                    ),
                  ),
                // kVerticalPaddingSmall,
              ]);
        }
      },
      child: child,
    );
  }
}
