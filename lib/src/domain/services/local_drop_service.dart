import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:quicksender/src/core/enums/enums.dart';
import 'package:quicksender/src/data/models/local_drop_item.dart';
import 'package:quicksender/src/domain/services/network_discovery_service.dart';
import 'package:uuid/uuid.dart';

class DownloadSession {
  final LocalDropItem item;
  int bytesReceived = 0;
  DownloadSession(this.item);
}

class LocalDropService extends ChangeNotifier {
  final NetworkDiscoveryService _networkDiscoveryService;
  LocalDropService(this._networkDiscoveryService) {
    // Lắng nghe các broadcast về item mới một cách chính xác
    _networkDiscoveryService.incomingDropItemsStream.listen((Map<String, dynamic> message) {
      final type = MessageType.values.byName(message['type'] as String);
      final payload = message['payload'] as Map<String, dynamic>;

      switch (type) {
        case MessageType.dropItem:
          final item = LocalDropItem.fromJson(payload);
          _handleNewDropItem(item);
          break;
        case MessageType.dropItemExpired:
          final itemId = payload['itemId'] as String;
          _handleExpiredDropItem(itemId);
          break;
        default:
          break;
      }
    });
  }

  // Danh sách các item có sẵn trong mạng LAN
  final Map<String, LocalDropItem> _availableItems = {};
  List<LocalDropItem> get availableItems => _availableItems.values.toList();

  // Map để giữ các ServerSocket cho các item do chính thiết bị này tạo ra
  final Map<String, ServerSocket> _itemServers = {};

  /// Xử lý khi nhận được quảng bá về một item mới
  void _handleNewDropItem(LocalDropItem item) {
    if (item.expiresAt.isBefore(DateTime.now())) return; // Bỏ qua nếu đã hết hạn
    //if (item.sourceDevice.id == _networkDiscoveryService.thisDevice?.id) return; // Bỏ qua item của chính mình

    _availableItems[item.itemId] = item;
    notifyListeners();

    // Tự động xóa khỏi danh sách khi hết hạn
    final duration = item.expiresAt.difference(DateTime.now());
    Timer(duration, () {
      _availableItems.remove(item.itemId);
      notifyListeners();
    });
  }

  /// Xử lý khi nhận được thông báo một item đã hết hạn
  void _handleExpiredDropItem(String itemId) {
    if (_availableItems.containsKey(itemId)) {
      _availableItems.remove(itemId);
      notifyListeners();
    }
  }

  /// Được gọi từ UI để "drop" một file cho mọi người trong mạng
  Future<void> dropFile(PlatformFile file) async {
    final serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
    final itemId = const Uuid().v4();
    final duration = const Duration(minutes: 5);

    final dropItem = LocalDropItem(
      itemId: itemId,
      sourceDevice: _networkDiscoveryService.thisDevice!,
      itemType: ItemType.file,
      content: file.name,
      fileSize: file.size,
      expiresAt: DateTime.now().add(duration),
      port: serverSocket.port,
    );

    _availableItems[itemId] = dropItem;
    notifyListeners(); // Thông báo cho UI để hiển thị ngay

    _itemServers[itemId] = serverSocket;
    serverSocket.listen((socket) {
      _sendFileToDownloader(file.path!, socket);
    });

    _networkDiscoveryService.broadcastDropItem(dropItem);
    debugPrint('Dropped file: ${file.name} on port ${serverSocket.port}');

    // Tự hủy sau khi hết hạn
    Timer(duration, () => _cleanupItem(itemId));
  }

  /// Dọn dẹp một item do thiết bị này tạo ra
  void _cleanupItem(String itemId) {
    _itemServers[itemId]?.close();
    _itemServers.remove(itemId);
    _networkDiscoveryService.broadcastDropItemExpired(itemId);
    debugPrint('Cleaned up dropped item: $itemId');
  }

  /// Gửi nội dung file cho người tải
  Future<void> _sendFileToDownloader(String filePath, Socket socket) async {
    debugPrint('Downloader connected, sending file: $filePath');
    try {
      final file = File(filePath);
      await socket.addStream(file.openRead());
    } catch (e) {
      debugPrint('Error sending dropped file: $e');
    } finally {
      await socket.close();
    }
  }

  final Map<String, DownloadSession> _activeDownloads = {};
List<DownloadSession> get activeDownloads => _activeDownloads.values.toList();

Future<void> downloadItem(LocalDropItem item) async {
  // =======================================================================
  // === LOGIC MỚI: XỬ LÝ TEXT ===
  // =======================================================================
  if (item.itemType == ItemType.text) {
    debugPrint('Attempting to "download" text item...');
    Socket? socket;
    try {
      socket = await Socket.connect(item.sourceDevice.ipAddress, item.port)
          .timeout(const Duration(seconds: 10));
      
      // Dùng utf8.decodeStream để nhận và ghép các chuỗi text một cách an toàn
      final receivedText = await utf8.decodeStream(socket);
      
      // Sao chép kết quả vào clipboard
      await Clipboard.setData(ClipboardData(text: receivedText));
      debugPrint('Text item content copied to clipboard!');

      // PHÁT SỰ KIỆN THÀNH CÔNG (để UI có thể hiển thị SnackBar)
      // Bạn sẽ cần tạo một Stream Event cho LocalDropService, tương tự FileTransferService
      // Ví dụ: _eventController.add(TextCopiedEvent());

    } catch (e) {
      debugPrint('Could not download text item: $e');
      // PHÁT SỰ KIỆN LỖI
      // Ví dụ: _eventController.add(GenericErrorEvent("Không thể nhận text."));
    } finally {
      socket?.destroy();
    }
    return; // Kết thúc hàm sau khi xử lý text
  }

  // =======================================================================
  // === LOGIC CŨ: XỬ LÝ FILE (được giữ lại và cải tiến) ===
  // =======================================================================
  if (item.itemType == ItemType.file) {
    if (_activeDownloads.containsKey(item.itemId)) return; // Đã đang tải rồi

    final session = DownloadSession(item);
    _activeDownloads[item.itemId] = session;
    notifyListeners();

    debugPrint('Attempting to download file: ${item.content} from ${item.sourceDevice.ipAddress}:${item.port}');
    
    BytesBuilder receivedBytes = BytesBuilder();
    Socket? socket;

    try {
      socket = await Socket.connect(item.sourceDevice.ipAddress, item.port);
      
      final completer = Completer<void>();

      socket.listen(
        (Uint8List data) {
          receivedBytes.add(data);
          session.bytesReceived = receivedBytes.length;
          notifyListeners();
        },
        onDone: () {
          if (!completer.isCompleted) completer.complete();
        },
        onError: (error) {
          if (!completer.isCompleted) completer.completeError(error);
        },
        cancelOnError: true,
      );
      
      await completer.future;

      // Logic lưu file của bạn đã đúng, giữ nguyên
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        await FilePicker.platform.saveFile(
          dialogTitle: 'Lưu file từ Local Drop:',
          fileName: item.content,
          bytes: receivedBytes.toBytes(),
        );
      } else {
        final params = SaveFileDialogParams(
          data: receivedBytes.toBytes(),
          fileName: item.content,
        );
        await FlutterFileDialog.saveFile(params: params);
      }
      debugPrint('Downloaded item ${item.content} saved successfully!');

    } catch (e) {
      debugPrint('Could not connect or download file: $e');
      // PHÁT SỰ KIỆN LỖI
    } finally {
      socket?.destroy();
      _activeDownloads.remove(item.itemId);
      notifyListeners();
    }
  }
}

Future<void> dropText(String text) async {
  final serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, 0);
  final itemId = const Uuid().v4();
  final duration = const Duration(minutes: 5);

  final dropItem = LocalDropItem(
    itemId: itemId,
    sourceDevice: _networkDiscoveryService.thisDevice!,
    itemType: ItemType.text, // SỬ DỤNG ItemType.text
    content: text, // Nội dung chính là đoạn text
    fileSize: null, // Không có file size
    expiresAt: DateTime.now().add(duration),
    port: serverSocket.port,
  );

  _itemServers[itemId] = serverSocket;
  // Khi có người kết nối, chỉ cần gửi nội dung text và đóng lại
  serverSocket.listen((socket) {
    debugPrint('Downloader connected for text item, sending content...');
    try {
      socket.write(text);
    } finally {
      socket.close();
    }
  });

  // Thêm item vào UI local ngay lập tức
  _availableItems[itemId] = dropItem;
  notifyListeners();

  _networkDiscoveryService.broadcastDropItem(dropItem);
  debugPrint('Dropped text on port ${serverSocket.port}');

  Timer(duration, () => _cleanupItem(itemId));
}
}