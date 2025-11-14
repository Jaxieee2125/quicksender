import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:quicksender/src/core/enums/enums.dart';
import 'package:quicksender/src/data/models/device.dart';
import 'package:quicksender/src/data/models/local_drop_item.dart';
import 'package:quicksender/src/domain/repositories/settings_repository.dart';
import 'package:quicksender/src/domain/services/local_drop_service.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_multicast_lock/flutter_multicast_lock.dart';

class NetworkDiscoveryService extends ChangeNotifier {
  static const int _port = 48698;
  final _controller = StreamController<List<Device>>.broadcast();
  final Map<String, Device> _onlineDevices = {};
  final Map<String, Timer> _deviceTimers = {};
  late RawDatagramSocket _socket;
  final _requestController = StreamController<Map<String, dynamic>>.broadcast();
  final flutterMulticastLock = FlutterMulticastLock();
  final SettingsRepository _settingsRepository;
  NetworkDiscoveryService(this._settingsRepository);
  final _dropItemController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get incomingDropItemsStream =>
      _dropItemController.stream;

  final _transferResponseController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get incomingTransferResponsesStream =>
      _transferResponseController.stream;

  Stream<Map<String, dynamic>> get incomingTransferRequestsStream =>
      _requestController.stream;

  final _transferControlController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get incomingTransferControlStream =>
      _transferControlController.stream;

  Device? _thisDevice;

  Device? get thisDevice => _thisDevice;

  List<String> Function() _getHostedItemsCallback = () => [];
  void registerHostedItemsCallback(List<String> Function() callback) {
    _getHostedItemsCallback = callback;
  }

  Stream<List<Device>> get onlineDevicesStream => _controller.stream;

  final _textMessageController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get incomingTextMessagesStream =>
      _textMessageController.stream;

  Future<void> start() async {
    // Lưu ý: UDP multicast/broadcast không được hỗ trợ trên Flutter Web.
    if (kIsWeb) {
      debugPrint("Network discovery is not supported on Web.");
      _controller.add([]);
      return;
    }

    // Khởi tạo thông tin thiết bị này
    _thisDevice = await _createCurrentDeviceInfo(_settingsRepository);
    notifyListeners();

    debugPrint(
      'This device info: ${_thisDevice?.toJson()}',
    ); // In ra thông tin máy hiện tại

    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _port);
    debugPrint(
      'Socket bound to: ${_socket.address.address}:${_socket.port}',
    ); // In ra socket đã bind
    _socket.broadcastEnabled = true;

    await flutterMulticastLock.acquireMulticastLock();

    _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, _port);
    _socket.broadcastEnabled = true;

    // 1. Lắng nghe các broadcast từ thiết bị khác
    _socket.listen((RawSocketEvent event) {
      if (event == RawSocketEvent.read) {
        final datagram = _socket.receive();
        if (datagram != null) {
          try {
            final message = utf8.decode(datagram.data);
            final json = jsonDecode(message) as Map<String, dynamic>;
            final typeString = json['type'] as String?;

            if (typeString == null) return; // Bỏ qua nếu không có type

            // TÌM GIÁ TRỊ ENUM MỘT CÁCH AN TOÀN
            final messageType = MessageType.values.firstWhere(
              (e) => e.name == typeString,
              orElse: () => MessageType
                  .presence, // Trả về một giá trị mặc định nếu không tìm thấy
            );

            // Thêm debug để xem kết quả
            if (messageType.name != typeString) {
              debugPrint(
                '!!! WARNING: Received unknown message type "$typeString". Defaulting to "presence".',
              );
              return; // Bỏ qua hoàn toàn các tin nhắn không xác định
            }

            final payload = json['payload'];

            switch (messageType) {
              case MessageType.presence:
                final receivedDevice = Device.fromJson(payload);

                // === THÊM ĐIỀU KIỆN KIỂM TRA QUAN TRỌNG NÀY ===
                // So sánh ID của gói tin nhận được với ID của chính thiết bị này
                if (receivedDevice.id == _thisDevice?.id) {
                  return; // Nếu là của mình, bỏ qua hoàn toàn
                }

                // Nếu không phải của mình, mới xử lý
                _handleDiscoveredDevice(receivedDevice);
                break;
              case MessageType.transferRequest:
                _requestController.add(payload);
                break;
              case MessageType.transferResponse:
                _transferResponseController.add(payload);
                break;
              case MessageType.dropItem:
              case MessageType.dropItemExpired:
                _dropItemController.add(json); // Drop item vẫn cần cả 'type'
                break;
              case MessageType.pauseTransfer:
              case MessageType.resumeTransfer:
                _transferControlController.add(payload);
                break;
              case MessageType.textMessage:
                _textMessageController.add(payload);
                break;
            }
          } catch (e) {
            debugPrint("Error decoding broadcast message: $e");
          }
        }
      }
    });

    // 2. Bắt đầu phát sóng thông tin của thiết bị này
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _broadcastPresence();
    });

    // 3. Dọn dẹp các thiết bị đã offline
    Timer.periodic(const Duration(seconds: 10), (timer) {
      _cleanupOfflineDevices();
    });
  }

  void sendPauseCommand(Device target, String sessionId) {
    final payload = {'sessionId': sessionId, 'command': 'pause'};
    final message = {
      'type': MessageType.pauseTransfer.name,
      'payload': payload,
    };

    // Gửi trực tiếp đến IP của thiết bị đối tác
    final targetIp = InternetAddress(target.ipAddress);
    final messageBytes = utf8.encode(jsonEncode(message));
    _socket.send(messageBytes, targetIp, _port);
  }

  void sendResumeCommand({
    required Device target,
    required String sessionId,
    required int newPort,
    required int fileIndex,
    required int fileBytes,
  }) {
    final payload = {
      'sessionId': sessionId,
      'command': 'resume',
      'newPort': newPort,
      'fileIndex': fileIndex,
      'fileBytes': fileBytes,
    };
    final message = {
      'type': MessageType.resumeTransfer.name,
      'payload': payload,
    };

    final targetIp = InternetAddress(target.ipAddress);
    final messageBytes = utf8.encode(jsonEncode(message));
    _socket.send(messageBytes, targetIp, _port);
  }

  void _broadcastPresence() {
    if (_thisDevice != null) {
      final hostedItemIds = _getHostedItemsCallback();

      final deviceJson = _thisDevice!.toJson();
      deviceJson['hosted_items'] = hostedItemIds;

      final payload = {
        'type': MessageType.presence.name,
        'payload': deviceJson,
      };
      final message = jsonEncode(payload);

      // Lấy địa chỉ broadcast của mạng con
      // Ví dụ: nếu IP là 192.168.1.14, địa chỉ broadcast sẽ là 192.168.1.255
      final broadcastAddress = InternetAddress(
        _thisDevice!.ipAddress.substring(
              0,
              _thisDevice!.ipAddress.lastIndexOf('.'),
            ) +
            '.255',
      );

      //debugPrint('Broadcasting presence to $broadcastAddress: $message');

      // Gửi đến địa chỉ broadcast cụ thể
      _socket.send(utf8.encode(message), broadcastAddress, _port);

      // Bạn cũng có thể gửi thêm 1 gói đến địa chỉ chung để tăng độ tin cậy
      // _socket.send(utf8.encode(message), InternetAddress("255.255.255.255"), _port);
    }
  }

  void sendTextMessage(Device target, String text) {
    final payload = {'sender': thisDevice!.toJson(), 'content': text};
    final message = {'type': MessageType.textMessage.name, 'payload': payload};
    final targetIp = InternetAddress(target.ipAddress);
    _socket.send(utf8.encode(jsonEncode(message)), targetIp, _port);
  }

  // Thêm hàm mới để gửi yêu cầu
  void sendTransferRequest(Device target, Map<String, dynamic> requestPayload) {
    final payload = {
      'type': MessageType.transferRequest.name,
      'payload': requestPayload,
    };
    final message = jsonEncode(payload);
    // Gửi trực tiếp đến IP của thiết bị đích
    _socket.send(
      utf8.encode(message),
      InternetAddress(target.ipAddress),
      _port,
    );
  }

  void sendTransferResponse(
    Device target,
    String sessionId, {
    required bool accepted,
  }) {
    final payload = {'sessionId': sessionId, 'accepted': accepted};
    final message = {
      'type': MessageType.transferResponse.name,
      'payload': payload,
    };

    // Gửi trực tiếp đến IP của người gửi ban đầu, không broadcast
    final targetIp = InternetAddress(target.ipAddress);
    final messageBytes = utf8.encode(jsonEncode(message));
    _socket.send(messageBytes, targetIp, _port);
  }

  void _handleDiscoveredDevice(Device device) {
    // Đặt lại bộ đếm thời gian cho thiết bị này
    _deviceTimers[device.id]?.cancel();
    _deviceTimers[device.id] = Timer(const Duration(seconds: 15), () {
      // Nếu sau 15 giây không nhận được tin nhắn, coi như offline
      _onlineDevices.remove(device.id);
      _updateStream();
    });

    // Thêm hoặc cập nhật thiết bị vào danh sách
    if (!_onlineDevices.containsKey(device.id)) {
      _onlineDevices[device.id] = device;
      _updateStream();
    }
  }

  void _cleanupOfflineDevices() {
    // Logic này được xử lý bởi Timer trong _handleDiscoveredDevice
  }

  void _updateStream() {
    _controller.add(_onlineDevices.values.toList());
  }

  Future<Device> _createCurrentDeviceInfo(
    SettingsRepository settingsRepo,
  ) async {
    String os = "unknown";
    if (kIsWeb) os = "web";
    if (Platform.isAndroid) os = "android";
    if (Platform.isWindows) os = "windows";
    // ... thêm các nền tảng khác

    String ip = "127.0.0.1";
    String bestIp = "127.0.0.1"; // Biến để lưu IP "tốt nhất" tìm được

    // Lấy danh sách tất cả các card mạng
    final interfaces = await NetworkInterface.list(
      includeLoopback: false, // Bỏ qua địa chỉ loopback 127.0.0.1
      type: InternetAddressType.IPv4,
    );

    // Vòng lặp để tìm card mạng phù hợp nhất
    for (var interface in interfaces) {
      // Bỏ qua các card mạng ảo phổ biến dựa vào tên
      final interfaceName = interface.name.toLowerCase();
      if (interfaceName.contains('virtual') ||
          interfaceName.contains('vmware') ||
          interfaceName.contains('vbox') ||
          interfaceName.contains('docker') ||
          interfaceName.contains('hyper-v') ||
          interfaceName.contains('wsl')) {
        debugPrint('Ignoring virtual interface: ${interface.name}');
        continue;
      }

      for (var addr in interface.addresses) {
        // Chỉ lấy địa chỉ IPv4
        if (addr.type == InternetAddressType.IPv4) {
          ip = addr.address;

          // Ưu tiên các địa chỉ IP trong dải LAN phổ biến
          if (ip.startsWith("192.168.") || ip.startsWith("10.")) {
            // Nếu tìm thấy IP thuộc dải 192.168.1.x, gần như chắc chắn là nó
            if (ip.startsWith("192.168.1.")) {
              bestIp = ip;
              break; // Thoát vòng lặp trong
            }
            // Nếu chưa có IP tốt nhất, tạm lấy IP này
            if (bestIp == "127.0.0.1") {
              bestIp = ip;
            }
          }
        }
      }
      if (bestIp.startsWith("192.168.1.")) {
        break; // Thoát vòng lặp ngoài
      }
    }

    // Nếu không tìm được IP tốt nhất, dùng IP cuối cùng tìm được
    if (bestIp == "127.0.0.1" && ip != "127.0.0.1") {
      bestIp = ip;
    }

    final customName = await settingsRepo.getSetting('deviceName');
    final hostname = Platform.localHostname;
    final deviceName = (customName != null && customName.isNotEmpty)
        ? customName
        : hostname;

    // 1. Thử đọc ID đã lưu từ database
    String? deviceId = await settingsRepo.getSetting('deviceId');

    // 2. Nếu chưa có ID nào được lưu
    if (deviceId == null) {
      // Tạo một ID mới
      deviceId = const Uuid().v4();
      // Và lưu nó lại để dùng cho các lần sau
      await settingsRepo.saveSetting('deviceId', deviceId);
      debugPrint('Generated and saved new device ID: $deviceId');
    } else {
      debugPrint('Loaded existing device ID: $deviceId');
    }

    return Device(
      id: deviceId,
      name: deviceName,
      ipAddress: bestIp, // Sử dụng IP tốt nhất đã được chọn lọc
      port: _port,
      os: DeviceOS.values.firstWhere(
        (e) => e.toString().split('.').last == os,
        orElse: () => DeviceOS.unknown,
      ),
    );
  }

  void dispose() {
    flutterMulticastLock.releaseMulticastLock();
    _socket.close();
    _controller.close();
    for (var timer in _deviceTimers.values) {
      timer.cancel();
    }
  }

  void broadcastDropItem(LocalDropItem item) {
    _broadcastJson({
      'type': MessageType.dropItem.name,
      'payload': item.toJson(),
    });
  }

  void broadcastDropItemExpired(String itemId) {
    _broadcastJson({
      'type': MessageType.dropItemExpired.name,
      'payload': {'itemId': itemId},
    });
  }

  // (Optional) Tái cấu trúc hàm gửi để tránh lặp code
  void _broadcastJson(Map<String, dynamic> json) {
    final message = jsonEncode(json);
    final broadcastAddress = InternetAddress(
      _thisDevice!.ipAddress.substring(
            0,
            _thisDevice!.ipAddress.lastIndexOf('.'),
          ) +
          '.255',
    );
    _socket.send(utf8.encode(message), broadcastAddress, _port);
  }
}
