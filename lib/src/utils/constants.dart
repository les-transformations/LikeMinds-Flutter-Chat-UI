const String kRegexLinksAndTags =
    r'(?:(?:http|https|ftp|www)\:\/\/)?[a-zA-Z0-9\-\.]+\.[a-zA-Z]{1,3}(?::[a-zA-Z0-9]*)?\/?[^\s\n]+|[\w\.-]+@[a-zA-Z\d\.-]+\.[a-zA-Z]{2,}|<<([^<>]+)\|route://member/([a-zA-Z-0-9]+)>>|<<@participants\|route://participants>>';

// Attachment Type Constants
const String kAttachmentTypeImage = "image";
const String kAttachmentTypeVideo = "video";
const String kAttachmentTypeAudio = "audio";
const String kAttachmentTypePDF = "pdf";
const String kAttachmentTypeGIF = "gif";
const String kAttachmentTypeVoiceNote = "voice_note";
