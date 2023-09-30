import 'package:flutter/material.dart';
import 'package:likeminds_chat_ui_fl/src/utils/theme.dart';

class LMProfilePicture extends StatelessWidget {
  const LMProfilePicture({
    super.key,
    this.imageUrl,
    required this.fallbackText,
    this.size = 48,
    this.borderRadius = 24,
    this.border = 0,
    this.backgroundColor,
  });

  final double size;
  final String? imageUrl;
  final String fallbackText;
  final double borderRadius;
  final double border;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(
          Radius.circular(borderRadius),
        ),
        border: Border.all(
          color: Colors.white,
          width: border,
        ),
        color: backgroundColor ?? Theme.of(context).primaryColor,
      ),
      child: imageUrl == null || imageUrl!.isEmpty
          ? Center(
              child: Text(
                fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : "",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: size / 2,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, _, __) => Center(
                child: Text(
                  fallbackText.isNotEmpty ? fallbackText[0].toUpperCase() : "",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: size / 2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
    );
  }
}
