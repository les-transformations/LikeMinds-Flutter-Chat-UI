import 'package:flutter/material.dart';
import 'package:likeminds_chat_ui_fl/likeminds_chat_ui_fl.dart';
import 'package:likeminds_chat_ui_fl/src/utils/theme.dart';

/// This widget is used to display link preview
///
/// A [LMLinkPreview] displays link heading, description and URL
/// The [LMLinkPreview] can be customized by passing in the required parameters

class LMLinkPreview extends StatelessWidget {
  /// Create a link preview
  ///
  /// A [LMLinkPreview] displays link heading, description and URL
  /// The [LMLinkPreview] can be customized by passing in the required parameters
  const LMLinkPreview({
    super.key,
    this.linkModel,
    this.width,
    this.height,
    this.backgroundColor,
    this.borderRadius,
    this.padding,
    this.onTap,
    this.title,
    this.subtitle,
    this.url,
    this.imageUrl,
    this.showLinkUrl = false,
    this.border,
  });

  // data class to provide link preview data
  // Attachment attch;
  final MediaModel? linkModel;
  // defaults to width of screen
  final double? width;
  // defaults to null
  final double? height;
  // defaults to null
  final Color? backgroundColor;
  // defaults to 8.0
  final double? borderRadius;
  final double? padding;
  final VoidCallback? onTap;
  // defaults to null,
  final String? imageUrl;
  // defaults to null, for custom styling
  final LMTextView? title;
  // defaults to null, for custom styling
  final LMTextView? subtitle;
  // defaults to null, for custom styling
  final LMTextView? url;
  // defaults to false, to show link url
  final bool showLinkUrl;
  final Border? border;

  bool checkNullMedia() {
    return ((linkModel == null ||
        linkModel!.ogTags == null ||
        linkModel!.ogTags!.image == null ||
        linkModel!.ogTags!.image!.isEmpty));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: kWhiteColor,
          border: border,
          // ??
          //     Border.all(
          //       color: kGrey3Color,
          //       width: 0.0,
          //     ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        height: checkNullMedia() ? null : height,
        width: width ?? MediaQuery.of(context).size.width,
        child: Column(
          children: <Widget>[
            checkNullMedia()
                ? const SizedBox.shrink()
                : LMImage(
                    errorWidget: LMIcon(
                      type: LMIconType.icon,
                      icon: Icons.error_outline,
                      size: 24,
                      color: kGrey3Color,
                    ),
                    width: width,
                    height: height != null ? height! - 60 : 100,
                    borderRadius: borderRadius,
                    imageUrl: imageUrl ?? linkModel!.ogTags?.image,
                  ),
            Container(
              // height: height != null ? 60 : null,
              color: backgroundColor,
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                width: width ?? MediaQuery.of(context).size.width,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      width: width ?? MediaQuery.of(context).size.width,
                      child: title ??
                          LMTextView(
                            text: linkModel != null
                                ? linkModel!.ogTags!.title!
                                : 'NOT PRODUCING',
                            textStyle: const TextStyle(
                              color: kGrey1Color,
                              fontSize: kFontSmallMed,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                    ),
                    kVerticalPaddingSmall,
                    SizedBox(
                      width: width ?? MediaQuery.of(context).size.width,
                      child: subtitle ??
                          LMTextView(
                            text: linkModel != null
                                ? linkModel!.ogTags!.description!
                                : 'NOT PRODUCING',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textStyle: const TextStyle(
                              color: kGrey3Color,
                              fontSize: kFontSmall,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                    ),
                    kVerticalPaddingXSmall,
                    showLinkUrl
                        ? SizedBox(
                            width: width ?? MediaQuery.of(context).size.width,
                            child: LMTextView(
                              text: linkModel != null
                                  ? linkModel!.link ?? linkModel!.ogTags!.url!
                                  : 'NOT PRODUCING',
                              maxLines: 1,
                              textStyle: const TextStyle(
                                color: kGrey3Color,
                                fontSize: kFontXSmall,
                              ),
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
