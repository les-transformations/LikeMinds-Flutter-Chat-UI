import 'dart:io';

import 'package:likeminds_chat_fl/likeminds_chat_fl.dart';

enum LmMediaType { video, image, document, link }

class MediaModel {
  // defines the type of media
  LmMediaType mediaType;
  // one of mediaFile or link must be provided
  File? mediaFile; // Photo Video or Document File
  String? link; // Photo Video, Document or Link Preview URL
  int? duration; // required for video url
  String? format; // required for documents
  int? size; // required for documents
  OgTags? ogTags; // required for links (attachment type 4)

  MediaModel({
    required this.mediaType,
    this.mediaFile,
    this.link,
    this.duration,
    this.format,
    this.size,
    this.ogTags,
  });

  // convert
  int mapMediaTypeToInt() {
    if (mediaType == LmMediaType.image) {
      return 1;
    } else if (mediaType == LmMediaType.video) {
      return 2;
    } else if (mediaType == LmMediaType.document) {
      return 3;
    } else if (mediaType == LmMediaType.link) {
      return 4;
    } else {
      throw 'no valid media type provided';
    }
  }
}

LmMediaType mapIntToMediaType(int attachmentType) {
  if (attachmentType == 1) {
    return LmMediaType.image;
  } else if (attachmentType == 2) {
    return LmMediaType.video;
  } else if (attachmentType == 3) {
    return LmMediaType.document;
  } else if (attachmentType == 4) {
    return LmMediaType.link;
  } else {
    throw 'no valid media type provided';
  }
}
