// lib/src/domain/services/file_transfer_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:drift/drift.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;
import 'package:quicksender/src/core/enums/enums.dart';
import 'package:quicksender/src/data/database/app_database.dart';
import 'package:quicksender/src/data/models/device.dart';
import 'package:quicksender/src/domain/services/network_discovery_service.dart';
import 'package:uuid/uuid.dart';
import 'package:quicksender/src/data/models/transfer_session.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:quicksender/src/domain/services/sound_service.dart';
import 'dart:async';
import 'package:quicksender/src/core/events/transfer_events.dart';
import 'package:disk_space_2/disk_space_2.dart';

class FileTransferService extends ChangeNotifier {
  final Map<String, TransferSession> _activeSessions = {};

  List<TransferSession> get activeSessions => _activeSessions.values.toList();

  // Map để lưu các ServerSocket đang lắng nghe
  final Map<String, ServerSocket> _serverSockets = {};

  final Map<String, Socket> _activeSockets = {};

  final NetworkDiscoveryService _networkDiscoveryService;

  final SoundService _soundService;

  final AppDatabase _db;

  final _eventController = StreamController<TransferEvent>.broadcast();
  Stream<TransferEvent> get eventsStream => _eventController.stream;

  FileTransferService(
    this._networkDiscoveryService,
    this._db,
    this._soundService,
  ) {
    // Lắng nghe stream các phản hồi truyền file
    _networkDiscoveryService.incomingTransferResponsesStream.listen(
      _handleTransferResponse,
    );
    _networkDiscoveryService.incomingTransferControlStream.listen(
      _handleControlCommand,
    );
  }

  void _handleTransferResponse(Map<String, dynamic> response) {
    final sessionId = response['sessionId'] as String;
    final accepted = response['accepted'] as bool;

    // Nếu người nhận từ chối
    if (!accepted) {
      debugPrint(
        'Receiver declined transfer for session $sessionId. Cancelling...',
      );

      // Tìm session tương ứng trong danh sách active
      final session = _activeSessions[sessionId];
      if (session != null) {
        // Hủy server socket đang chờ kết nối (rất quan trọng)
        _serverSockets[sessionId]?.close();
        _serverSockets.remove(sessionId);

        // Gọi hàm cancelTransfer để ghi log và dọn dẹp khỏi UI
        // Trạng thái là "declined"
        cancelTransfer(sessionId, status: TransferStatus.declined);
      }
    }
    // (Trong tương lai, bạn có thể xử lý trường hợp `accepted: true` ở đây
    // ví dụ như thay đổi trạng thái UI từ "Đang chờ" sang "Đang kết nối")
  }

  void pauseTransfer(String sessionId) {
    // Tìm session tương ứng
    final session = _activeSessions[sessionId];

    // Chỉ thực hiện nếu session tồn tại và đang trong trạng thái truyền file
    if (session == null || session.status != TransferStatus.transferring) {
      return;
    }

    debugPrint('Pausing transfer for session $sessionId');

    // BƯỚC 1: Cập nhật trạng thái local ngay lập tức để UI thay đổi
    session.status = TransferStatus.paused;
    notifyListeners();

    // BƯỚC 2: Phá hủy socket hiện tại.
    // Đây là hành động cốt lõi để dừng việc truyền/nhận dữ liệu.
    // Vòng lặp `await for` hoặc `socket.listen` ở cả hai bên sẽ bị lỗi
    // (ném ra exception) và thoát ra một cách an toàn.
    _activeSockets[sessionId]?.destroy();
    _activeSockets.remove(sessionId);

    // BƯỚC 3: Gửi lệnh "pause" qua mạng cho đối tác
    // để họ cũng cập nhật trạng thái giao diện của mình.
    _networkDiscoveryService.sendPauseCommand(session.targetDevice, sessionId);
  }

  // Thêm hàm mới này vào class FileTransferService
  void _handleControlCommand(Map<String, dynamic> payload) {
    final sessionId = payload['sessionId'] as String;
    final command = payload['command'] as String;

    // Tìm session tương ứng
    final session = _activeSessions[sessionId];
    if (session == null) {
      return;
    }

    debugPrint('Received control command: "$command" for session $sessionId');

    // Xử lý lệnh "pause"
    if (command == 'pause') {
      // Chỉ cần cập nhật trạng thái và thông báo cho UI.
      // Không cần đóng socket ở đây, vì bên kia đã chủ động đóng rồi.
      // Việc đóng đó sẽ tự động gây ra lỗi và dừng vòng lặp nhận dữ liệu
      // của chúng ta một cách an toàn.
      if (session.status == TransferStatus.transferring) {
        session.status = TransferStatus.paused;
        notifyListeners();

        _activeSockets[sessionId]?.destroy();
        _activeSockets.remove(sessionId);
      }
    } else if (command == 'resume') {
      debugPrint('== RECEIVER: Received RESUME command! ==');
      debugPrint('== RECEIVER: Payload: $payload ==');

      final newPort = payload['newPort'] as int;
      final fileIndex = payload['fileIndex'] as int;
      final fileBytes = payload['fileBytes'] as int;

      // Cập nhật lại trạng thái local của session
      session.status = TransferStatus.transferring;
      session.currentFileIndex = fileIndex;
      session.currentFileTransferredBytes = fileBytes;

      // Tính lại transferredSize tổng
      int previousFilesSize = 0;
      for (int i = 0; i < fileIndex; i++) {
        previousFilesSize += session.files[i].size;
      }
      session.transferredSize = previousFilesSize + fileBytes;
      notifyListeners();

      // Kết nối lại đến người gửi
      _resumeReceivingData(session, newPort);
    }
  }

  Future<void> _resumeReceivingData(
    TransferSession session,
    int newPort,
  ) async {
    try {
      final socket = await Socket.connect(
        session.targetDevice.ipAddress,
        newPort,
      );
      _activeSockets[session.sessionId] = socket; // Lưu socket mới

      // Logic lắng nghe stream dữ liệu nhận được
      socket.listen(
        (Uint8List data) async {
          // MỞ FILE Ở CHẾ ĐỘ APPEND
          // Bạn sẽ cần biết đường dẫn file đã lưu từ trước.
          // Điều này đòi hỏi phải lưu lại đường dẫn file tạm khi pause.
          // Đây là một điểm phức tạp cần xử lý.
          // ...
        },
        // onDone, onError xử lý như cũ
      );
    } catch (e) {
      // Xử lý lỗi kết nối
    }
  }

  Future<void> _logTransferToDatabase(
    TransferSession session,
    TransferStatus status,
  ) async {
    final historyEntry = TransferHistoryCompanion.insert(
      sessionId: session.sessionId,
      type: session.type.name,
      targetDeviceName: session.targetDevice.name,
      targetDeviceIp: session.targetDevice.ipAddress,
      fileNames: jsonEncode(session.files.map((f) => f.fileName).toList()),
      totalSize: session.totalSize,
      status: status.name,
      createdAt: session
          .createdAt, // Thêm `final DateTime createdAt = DateTime.now();` vào class TransferSession
      completedAt: Value(DateTime.now()),
    );
    await _db.into(_db.transferHistory).insert(historyEntry);
  }

  // Hàm này sẽ được gọi từ UI khi người dùng chọn file và thiết bị nhận
  Future<void> requestToSendFiles(
    Device target,
    List<PlatformFile> files,
  ) async {
    final sessionId = const Uuid().v4();
    final transferableFiles = <TransferableFile>[];
    for (final file in files) {
      // Bỏ qua nếu file không có đường dẫn (xảy ra trên Web)
      if (file.path == null) continue;

      // Tính checksum cho mỗi file
      final checksum = await _calculateFileChecksum(file.path!);

      transferableFiles.add(
        TransferableFile(
          fileName: file.name,
          filePath: file.path!,
          size: file.size,
          checksum: checksum, // Thêm checksum vào model
        ),
      );
    }

    final session = TransferSession(
      sessionId: sessionId,
      type: TransferType.send,
      targetDevice: target,
      files: transferableFiles,
    );

    _activeSessions[sessionId] = session;
    notifyListeners();

    // 1. Mở một ServerSocket trên một port ngẫu nhiên để sẵn sàng nhận kết nối
    final serverSocket = await ServerSocket.bind(
      InternetAddress.anyIPv4,
      0,
    ); // Port 0 = port ngẫu nhiên
    final listeningPort = serverSocket.port;
    _serverSockets[sessionId] = serverSocket;

    debugPrint(
      'Server for session $sessionId listening on port $listeningPort',
    );

    // Lắng nghe kết nối từ người nhận
    serverSocket.listen((socket) {
      debugPrint('Receiver connected for session $sessionId!');
      // Bắt đầu quá trình gửi dữ liệu
      _startSendingData(session, socket);

      // Đóng server socket này lại vì nó chỉ phục vụ 1 kết nối
      serverSocket.close();
      _serverSockets.remove(sessionId);
    });

    final requestPayload = {
      'sessionId': sessionId,
      'sender': _networkDiscoveryService.thisDevice
          ?.toJson(), // Cần public thisDevice
      'files': transferableFiles
          .map((f) => {'name': f.fileName, 'size': f.size})
          .toList(),
      'totalSize': session.totalSize,
      'port': listeningPort,
    };
    _networkDiscoveryService.sendTransferRequest(target, requestPayload);
  }

  Future<void> _startSendingData(TransferSession session, Socket socket) async {
    debugPrint(
      'Sender: Starting data transfer. Updating status to "transferring".',
    );
    session.status = TransferStatus.transferring;
    session.resetProgress(); // Đảm bảo tiến trình bắt đầu từ 0
    notifyListeners();

    _activeSockets[session.sessionId] = socket;
    session.transferredSize = 0;
    notifyListeners();

    try {
      final metadata = {
        'file_count': session.files.length,
        'files': session.files
            .map(
              (f) => {
                'name': f.fileName,
                'size': f.size,
                'checksum': f.checksum, // GỬI CHECKSUM
              },
            )
            .toList(),
      };
      final jsonMetadata = jsonEncode(metadata);
      socket.write(jsonMetadata + '\n');
      // Gửi metadata đi ngay lập tức
      await socket.flush();

      for (int i = session.currentFileIndex; i < session.files.length; i++) {
        session.currentFileIndex = i;
        final file = session.files[i];
        final fileStream = File(file.filePath).openRead();

        await for (final chunk in fileStream) {
          if (session.status != TransferStatus.transferring) {
            debugPrint(
              'SENDER: Status changed to ${session.status}. Breaking send loop.',
            );
            // Không ném lỗi, chỉ thoát vòng lặp một cách êm đẹp
            break;
          }

          // 1. Gửi một khối dữ liệu vào buffer
          socket.add(chunk);

          // 2. CHỜ cho đến khi buffer được gửi đi qua mạng
          await socket.flush();

          // 3. CHỈ SAU KHI đã gửi thành công, mới cập nhật tiến trình
          session.currentFileTransferredBytes += chunk.length;
          int previousFilesSize = 0;
          for (int j = 0; j < i; j++) {
            previousFilesSize += session.files[j].size;
          }
          session.transferredSize =
              previousFilesSize + session.currentFileTransferredBytes;

          notifyListeners();
        }
        if (session.status != TransferStatus.transferring) {
          break;
        }

        // Reset cho file tiếp theo
        session.currentFileTransferredBytes = 0;
      }
      if (session.status == TransferStatus.transferring) {
        debugPrint(
          'Finished sending all files for session ${session.sessionId}',
        );
        session.status =
            TransferStatus.completed; // Cập nhật trạng thái cuối cùng
        _soundService.playTransferComplete();
        _logTransferToDatabase(session, TransferStatus.completed);
      }
    } on SocketException catch (e) {
      // BẮT LỖI CỤ THỂ
      debugPrint("Connection lost while sending: $e");
      // Gọi hàm hủy với trạng thái thất bại
      if (session.status == TransferStatus.transferring) {
        cancelTransfer(session.sessionId, status: TransferStatus.failed);
      }
      // Không cần làm gì thêm vì cancelTransfer đã dọn dẹp rồi
    } catch (e) {
      debugPrint('Error during sending data: $e');
      if (session.status == TransferStatus.transferring) {
        session.status = TransferStatus.failed;
        _logTransferToDatabase(session, TransferStatus.failed);
      }
    } finally {
      debugPrint(
        'Closing sender socket and cleaning up session ${session.sessionId}',
      );
      socket.close();
      await Future.delayed(
        const Duration(milliseconds: 100),
      ); // Đợi một chút để đảm bảo mọi dữ liệu đã được gửi
      if (session.status == TransferStatus.completed ||
          session.status == TransferStatus.failed) {
        _activeSessions.remove(session.sessionId);
      }
      // Dù sao đi nữa, cũng gọi notifyListeners() để UI cập nhật lần cuối
      notifyListeners();
    }
  }

  Future<void> acceptTransfer(Map<String, dynamic> requestPayload) async {
    final sender = Device.fromJson(requestPayload['sender']);
    final files = requestPayload['files'] as List;

    final session = TransferSession(
      sessionId: requestPayload['sessionId'],
      type: TransferType.receive,
      targetDevice: sender, // Thiết bị đích ở đây là người gửi
      files: (requestPayload['files'] as List)
          .map(
            (f) => TransferableFile(
              fileName: f['name'],
              filePath: '', // Người nhận không có filePath
              size: f['size'],
              checksum: '', // Người nhận không có checksum lúc này
            ),
          )
          .toList(),
    );

    String? targetPath;

    // HỎI MỘT LẦN DUY NHẤT
    if (files.length > 1) {
      if (Platform.isAndroid) {
        // Dùng getDirectoryPath của file_picker để lấy URI qua SAF
        targetPath = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Chọn thư mục để lưu ${files.length} file',
        );
      } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        targetPath = await FilePicker.platform.getDirectoryPath(
          dialogTitle: 'Chọn thư mục để lưu ${files.length} file',
        );
      }

      if (targetPath == null) {
        declineTransfer(requestPayload);
        return;
      }
    }

    _activeSessions[session.sessionId] = session;
    notifyListeners();

     final double totalSizeMB = session.totalSize / (1024 * 1024); 
    // Lấy dung lượng trống trên thiết bị (tính bằng MB)
    final double? freeSpaceMB = await DiskSpace.getFreeDiskSpace; 

    if (freeSpaceMB != null && freeSpaceMB < totalSizeMB) {
      debugPrint("Not enough space.");
      _logTransferToDatabase(session, TransferStatus.failed);
      
      // PHÁT SỰ KIỆN
      _eventController.add(NotEnoughSpaceEvent(totalSizeMB, freeSpaceMB));
      
      return;
    }

    try {
      session.status = TransferStatus.connecting;
      notifyListeners();
      final socket = await Socket.connect(
        sender.ipAddress,
        requestPayload['port'],
      );
      _activeSockets[session.sessionId] = socket;

      // Truyền `targetPath` đã chọn vào hàm xử lý
      _startReceivingData(socket, requestPayload, targetPath);
    } catch (e) {
      cancelTransfer(session.sessionId, status: TransferStatus.failed);
    }
  }

  Future<void> cancelTransfer(
    String sessionId, {
    TransferStatus status = TransferStatus.declined,
  }) async {
    final session = _activeSessions[sessionId];
    final socket = _activeSockets[sessionId];

    if (session != null) {
      debugPrint(
        'Cleaning up transfer for session $sessionId with status: $status',
      );

      // 1. Phá hủy socket để dừng việc truyền/nhận ngay lập tức
      socket?.destroy();

      // 2. Ghi lại trạng thái đã hủy vào database
      await _logTransferToDatabase(
        session,
        status,
      ); // Hoặc tạo status 'cancelled'

      // 3. Xóa khỏi danh sách active
      _activeSockets.remove(sessionId);
      _activeSessions.remove(sessionId);
      notifyListeners();
    }
  }

  Future<void> resumeTransfer(String sessionId) async {
    final session = _activeSessions[sessionId];
    if (session == null || session.status != TransferStatus.paused) return;

    debugPrint('Resuming transfer for session $sessionId from file ${session.currentFileIndex} at ${session.currentFileTransferredBytes} bytes.');

    // Khai báo serverSocket ở đây để finally có thể truy cập
    ServerSocket? serverSocket; 
    try {
      session.status = TransferStatus.transferring;
      notifyListeners();

      serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
      
      _networkDiscoveryService.sendResumeCommand(
        target: session.targetDevice,
        sessionId: sessionId,
        newPort: serverSocket.port,
        fileIndex: session.currentFileIndex,
        fileBytes: session.currentFileTransferredBytes,
      );

      // Chờ người nhận kết nối lại, với timeout 15 giây
      final socket = await serverSocket.first.timeout(const Duration(seconds: 15));
      
      debugPrint('Receiver reconnected for resuming session $sessionId.');
      _activeSockets[sessionId] = socket;
      await _resumeSendingData(session, socket); // Đợi cho việc gửi tiếp hoàn tất
      
    } catch (e) {
      debugPrint('Error resuming transfer (e.g., timeout): $e.');
       _eventController.add(ResumeFailedEvent());
      // Nếu có lỗi, chuyển trạng thái thành failed và dọn dẹp
      if (session.status == TransferStatus.transferring) { // Chỉ thay đổi nếu chưa bị pause lần nữa
          session.status = TransferStatus.failed;
          _logTransferToDatabase(session, TransferStatus.failed);
          _activeSessions.remove(sessionId);
          notifyListeners();
      }
    } finally {
      serverSocket?.close();
    }
  }

  Future<void> _resumeSendingData(TransferSession session, Socket socket) async {
    try {
      // Bắt đầu từ file đang dang dở
      for (int i = session.currentFileIndex; i < session.files.length; i++) {
        session.currentFileIndex = i;
        final file = session.files[i];
        final fileHandle = await File(file.filePath).open(mode: FileMode.read);
        
        await fileHandle.setPosition(session.currentFileTransferredBytes);
        debugPrint('Resuming send for ${file.fileName} from position ${session.currentFileTransferredBytes}');

        final buffer = Uint8List(64 * 1024);
        int bytesRead;
        while ((bytesRead = await fileHandle.readInto(buffer)) > 0) {
          if (session.status != TransferStatus.transferring) {
            debugPrint('SENDER (Resume): Status changed. Breaking send loop.');
            break;
          }
          
          socket.add(buffer.sublist(0, bytesRead));
          await socket.flush();

          session.currentFileTransferredBytes += bytesRead;
          // ... Cập nhật transferredSize tổng ...
          notifyListeners();
        }
        
        await fileHandle.close();
        if (session.status != TransferStatus.transferring) break;
        session.currentFileTransferredBytes = 0;
      }

      if (session.status == TransferStatus.transferring) {
        session.status = TransferStatus.completed;
        // ... logic hoàn thành ...
      }
    } catch (e) {
      if (session.status == TransferStatus.transferring) {
        session.status = TransferStatus.failed;
        // ... logic báo lỗi ...
      }
    } finally {
      socket.close();
      if (session.status == TransferStatus.completed || session.status == TransferStatus.failed) {
        _activeSessions.remove(session.sessionId);
      }
      notifyListeners();
    }
  }

  Future<void> _startReceivingData(
    Socket socket,
    Map<String, dynamic> payload,
    String? targetPath,
  ) async {
    List<dynamic> fileMetas = [];
    int currentFileIndex = 0;

    // BytesBuilder này sẽ là buffer chung, chứa tất cả dữ liệu nhận được
    final receivedDataBuffer = BytesBuilder();
    bool metadataReceived = false;

    final String sessionId = payload['sessionId'] as String;
    TransferSession? session;
    bool hasLogged = false;

    socket.listen(
      (Uint8List data) async {
        session ??= _activeSessions[sessionId];
        if (session == null) {
          socket.destroy();
          return;
        }

        debugPrint(
          'Receiver: Starting data transfer. Updating status to "transferring".',
        );
        session?.status = TransferStatus.transferring;
        notifyListeners();

        // Luôn thêm dữ liệu mới vào buffer chung
        receivedDataBuffer.add(data);

        // === XỬ LÝ METADATA (CHỈ 1 LẦN) ===
        if (!metadataReceived) {
          final allBytes = receivedDataBuffer.toBytes();
          final newlineIndex = allBytes.indexOf(10);

          if (newlineIndex != -1) {
            final metaDataBytes = allBytes.sublist(0, newlineIndex);
            final metaJson = utf8.decode(metaDataBytes);
            fileMetas = jsonDecode(metaJson)['files'];
            metadataReceived = true;
            debugPrint('Metadata received. Total files: ${fileMetas.length}');

            // Xóa metadata khỏi buffer chung, chỉ giữ lại dữ liệu file
            final remainingData = allBytes.sublist(newlineIndex + 1);
            receivedDataBuffer.clear();
            receivedDataBuffer.add(remainingData);
          }
        }

        // === LOGIC XỬ LÝ FILE MỚI - ĐÁNG TIN CẬY HƠN ===
        if (metadataReceived) {
          // Vòng lặp này sẽ chạy liên tục cho đến khi buffer không đủ dữ liệu cho file tiếp theo
          while (metadataReceived &&
              currentFileIndex < fileMetas.length &&
              receivedDataBuffer.length >=
                  fileMetas[currentFileIndex]['size']) {
            final currentFileMeta = fileMetas[currentFileIndex];
            final fileName = (currentFileMeta['name'] as String).trim();
            final expectedChecksum = currentFileMeta['checksum'] as String;
            final fileSize = currentFileMeta['size'] as int;

            // Bóc tách đúng số byte của file hiện tại ra khỏi buffer chung
            final allReceivedBytes = receivedDataBuffer.toBytes();
            final fileBytes = allReceivedBytes.sublist(0, fileSize);

            // Cập nhật lại buffer chung: xóa đi phần dữ liệu của file vừa xử lý
            final remainingData = allReceivedBytes.sublist(fileSize);
            receivedDataBuffer.clear();
            receivedDataBuffer.add(remainingData);

            try {
              String?
              finalFilePath; // Biến để lưu đường dẫn file thực tế sau khi lưu

              // =========================================================================
              // KỊCH BẢN 1: NHẬN NHIỀU FILE (targetPath đã được chọn từ trước)
              // =========================================================================
              if (targetPath != null) {
                // Logic cho Desktop (Windows, Linux, macOS, Android)
                finalFilePath = p.join(targetPath, fileName);
                await File(finalFilePath).writeAsBytes(fileBytes);
              }
              // =========================================================================
              // KỊCH BẢN 2: NHẬN MỘT FILE DUY NHẤT (targetPath là null)
              // =========================================================================
              else {
                if (Platform.isWindows ||
                    Platform.isLinux ||
                    Platform.isMacOS) {
                  // Hỏi người dùng vị trí lưu cho file duy nhất này
                  final savedPath = await FilePicker.platform.saveFile(
                    dialogTitle: 'Lưu file:',
                    fileName: fileName,
                    bytes: fileBytes,
                  );
                  if (savedPath == null) {
                    debugPrint('User cancelled saving single file on Desktop.');
                    socket.destroy();
                    return; // Thoát khỏi callback
                  }
                  finalFilePath = savedPath;
                } else {
                  // Logic cho một file duy nhất trên Mobile (Android, iOS)
                  final savedPath = await FlutterFileDialog.saveFile(
                    params: SaveFileDialogParams(
                      data: Uint8List.fromList(fileBytes),
                      fileName: fileName,
                    ),
                  );
                  if (savedPath == null) {
                    debugPrint('User cancelled saving single file on Mobile.');
                    socket.destroy();
                    return; // Thoát khỏi callback
                  }
                  finalFilePath = savedPath;
                }
              }

              // =========================================================================
              // BƯỚC KIỂM TRA TOÀN VẸN (CHECKSUM)
              // =========================================================================
              // Chỉ thực hiện checksum nếu chúng ta có đường dẫn file vật lý
              if (finalFilePath != 'saf-uri') {
                debugPrint(
                  'File saved to $finalFilePath. Verifying checksum...',
                );
                final actualChecksum = await _calculateFileChecksum(
                  finalFilePath,
                );

                if (actualChecksum == expectedChecksum) {
                  debugPrint('Checksum OK for $fileName');
                } else {
                  debugPrint(
                    '!!! CHECKSUM MISMATCH for $fileName. Expected: $expectedChecksum, Got: $actualChecksum',
                  );

                  _eventController.add(ChecksumMismatchEvent(fileName));

                  await File(finalFilePath).delete(); // Xóa file bị lỗi
                  socket.destroy(); // Hủy toàn bộ session
                  return;
                }
              }
            } catch (e) {
              debugPrint('Error during file saving or checksum process: $e');
              socket.destroy(); // Hủy kết nối nếu có bất kỳ lỗi nào xảy ra
              return;
            }

            // Chuyển sang file tiếp theo
            currentFileIndex++;

            // Cập nhật tiến trình UI
            int previousFilesSize = 0;
            for (int i = 0; i < currentFileIndex; i++) {
              previousFilesSize += session!.files[i].size;
            }
            session!.transferredSize = previousFilesSize;
            notifyListeners();
          }

          // Cập nhật tiến trình cho file đang dang dở
          int previousFilesSize = 0;
          for (int i = 0; i < currentFileIndex; i++) {
            previousFilesSize += session!.files[i].size;
          }
          session!.transferredSize =
              previousFilesSize + receivedDataBuffer.length;
          notifyListeners();
        }
      },
      onDone: () {
        debugPrint('Transfer stream closed for session $sessionId.');
        final currentSession = _activeSessions[sessionId];
        // Chỉ dọn dẹp NẾU session không ở trạng thái paused
        if (currentSession != null &&
            currentSession.status != TransferStatus.paused &&
            !hasLogged) {
          hasLogged = true;
          _soundService.playTransferComplete();
          _logTransferToDatabase(currentSession, TransferStatus.completed);
          _activeSessions.remove(sessionId);
          notifyListeners();
        }
        socket.close();
      },
      onError: (error) {
        debugPrint('Error on stream for session $sessionId: $error');
        final currentSession = _activeSessions[sessionId];
        // Chỉ dọn dẹp NẾU session không ở trạng thái paused
        if (currentSession != null &&
            currentSession.status != TransferStatus.paused &&
            !hasLogged) {
          hasLogged = true;
          _logTransferToDatabase(currentSession, TransferStatus.failed);
          _activeSessions.remove(sessionId);
          notifyListeners();
        }
        socket.close();
      },
      cancelOnError: true,
    );
  }

  Future<String> _calculateFileChecksum(String filePath) async {
    final file = File(filePath);
    final stream = file.openRead();

    // md5.bind() tạo ra một StreamTransformer
    // Nó sẽ xử lý stream byte đầu vào và phát ra một Digest duy nhất
    final digest = await md5.bind(stream).first;

    return digest.toString();
  }

  void declineTransfer(Map<String, dynamic> requestPayload) {
    final sessionId = requestPayload['sessionId'] as String;
    // Người gửi ban đầu bây giờ là "target" để chúng ta gửi phản hồi
    final sender = Device.fromJson(requestPayload['sender']);

    debugPrint('Declining transfer for session $sessionId');
    // Gọi service mạng để gửi tin nhắn UDP "từ chối"
    _networkDiscoveryService.sendTransferResponse(
      sender,
      sessionId,
      accepted: false,
    );
  }

  @override
  void dispose() {
    super.dispose();
    for (var server in _serverSockets.values) {
      server.close();
    }
  }
}
