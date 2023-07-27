import 'package:flutter_chat_ui_sample/service/media_service.dart';
import 'package:flutter_chat_ui_sample/utils/imports.dart';
import 'package:flutter_chat_ui_sample/widgets/media/document/document_preview.dart';

Widget documentPreviewFactory(List<Media> mediaList) {
  switch (mediaList.length) {
    case 1:
      return getSingleDocPreview(mediaList.first);
    case 2:
      return getDualDocPreview(mediaList);
    default:
      return GetMultipleDocPreview(mediaList: mediaList);
  }
}
