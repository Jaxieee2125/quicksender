// lib/src/core/enums/enums.dart
enum TransferStatus { pending, accepted, declined, transferring, paused, completed, failed, connecting }
enum TransferType { send, receive }
enum MessageType { presence, transferRequest, dropItem, dropItemExpired, transferResponse, pauseTransfer, resumeTransfer }
enum ItemType { text, file }