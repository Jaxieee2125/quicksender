// lib/src/data/models/transfer_session.dart
import 'package:quicksender/src/core/enums/enums.dart';
import 'package:quicksender/src/data/models/device.dart';

class TransferableFile {
  final String fileName;
  final String filePath;
  final int size;
  final String checksum; // Thêm thuộc tính checksum

  TransferableFile({
    required this.fileName,
    required this.filePath,
    required this.size,
    required this.checksum,
  });
}

class TransferSession {
  final String sessionId;
  final TransferType type;
  final Device targetDevice;
  final List<TransferableFile> files;
  final int totalSize;
  final DateTime createdAt = DateTime.now();
  
  // Các thuộc tính trạng thái
  TransferStatus status;
  int transferredSize;

  int currentFileIndex;
  int currentFileTransferredBytes;

  List<String> tempFilePaths; 

  TransferSession({
    required this.sessionId,
    required this.type,
    required this.targetDevice,
    required this.files,
    this.status = TransferStatus.pending,
    this.transferredSize = 0,
    this.currentFileIndex = 0,
    this.currentFileTransferredBytes = 0,
    this.tempFilePaths = const [],
  }) : totalSize = files.fold(0, (sum, file) => sum + file.size);

  void resetProgress() {
    transferredSize = 0;
    currentFileIndex = 0;
    currentFileTransferredBytes = 0;
  }
}