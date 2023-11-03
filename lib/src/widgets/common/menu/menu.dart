import 'package:flutter/material.dart';
import 'package:likeminds_chat_ui_fl/likeminds_chat_ui_fl.dart';

class LMMenu extends StatelessWidget {
  const LMMenu({
    super.key,
    required this.menuItems,
    required this.child,
    this.menuDecoration,
  });
  final List<LMMenuItemUI> menuItems;
  final Widget child;
  final LMMenuDecoration? menuDecoration;

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
              elevation: menuDecoration?.elevation,
              shadowColor: menuDecoration?.shadowColor,
              surfaceTintColor: menuDecoration?.surfaceTintColor,
              semanticLabel: menuDecoration?.semanticLabel,
              shape: menuDecoration?.shape,
              color: menuDecoration?.color,
              constraints: menuDecoration?.constraints,
              clipBehavior: menuDecoration?.clipBehavior ?? Clip.none,
              items: [
                for (LMMenuItemUI menuItem in menuItems)
                  PopupMenuItem(
                    onTap: () {
                      menuItem.onTap();
                    },
                    padding: menuDecoration?.itemPadding ?? EdgeInsets.zero,
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
