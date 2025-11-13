import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

// Import các models
import 'package:quicksender/src/data/models/device.dart';

// Import các providers
import 'package:quicksender/src/presentation/providers/network_providers.dart';
import 'package:quicksender/src/presentation/providers/transfer_providers.dart';

// Import các màn hình và widgets khác
import 'package:quicksender/src/presentation/screens/history_screen.dart';
import 'package:quicksender/src/presentation/screens/settings_screen.dart';
import 'package:quicksender/src/presentation/widgets/active_transfers_list.dart';
import 'package:quicksender/src/presentation/widgets/empty_state_widget.dart';
import 'package:quicksender/src/presentation/widgets/local_drop_area.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listener cho các yêu cầu truyền file đến, đặt ở đây là an toàn nhất.
    ref.listen<AsyncValue<Map<String, dynamic>>>(incomingTransferRequestsProvider, (previous, next) {
      if (!next.hasValue || next.value == null) return;
      // Ngăn dialog hiển thị lại nếu state không thay đổi
      if (previous?.value == next.value) return;

      final payload = next.value!;
      final sender = Device.fromJson(payload['sender']);
      final fileCount = (payload['files'] as List).length;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Yêu cầu nhận file'),
          content: Text('Bạn có muốn nhận $fileCount file từ ${sender.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                ref.read(fileTransferServiceProvider).declineTransfer(payload);
                Navigator.of(context).pop();
                },
              child: const Text('Từ chối'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(fileTransferServiceProvider).acceptTransfer(payload);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đang bắt đầu nhận file...')),
                );
              },
              child: const Text('Chấp nhận'),
            ),
          ],
        ),
      );
    });

    // Sử dụng LayoutBuilder để quyết định layout nào sẽ được hiển thị
    return LayoutBuilder(
      builder: (context, constraints) {
        // Đặt ngưỡng cho màn hình rộng, 600 là một giá trị phổ biến
        const wideLayoutThreshold = 600.0;
        if (constraints.maxWidth >= wideLayoutThreshold) {
          return _buildWideLayout(context, ref);
        } else {
          return _buildNarrowLayout(context, ref);
        }
      },
    );
  }

  // =========================================================================
  // B. Bố cục cho màn hình HẸP (Điện thoại)
  // =========================================================================
  Widget _buildNarrowLayout(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('QuickSender'),
          actions: _buildAppBarActions(context),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.devices), text: 'Thiết bị'),
              Tab(icon: Icon(Icons.public), text: 'Local Drop'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildDeviceList(ref),
                  const LocalDropArea(),
                ],
              ),
            ),
            const ActiveTransfersList(),
          ],
        ),
      ),
    );
  }

  // =========================================================================
  // A. Bố cục cho màn hình RỘNG (Desktop, Tablet ngang)
  // =========================================================================
  Widget _buildWideLayout(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QuickSender'),
        actions: _buildAppBarActions(context),
        // Không cần TabBar ở đây
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                // === Cột bên trái: Danh sách thiết bị ===
                Expanded(
                  flex: 2, // Chiếm 2 phần không gian
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'Thiết bị trong mạng',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const Divider(),
                        Expanded(child: _buildDeviceList(ref)),
                      ],
                    ),
                  ),
                ),
                const VerticalDivider(width: 1.0, thickness: 1.0),
                // === Cột bên phải: Local Drop ===
                Expanded(
                  flex: 3, // Chiếm 3 phần không gian
                  child: const LocalDropArea(),
                ),
              ],
            ),
          ),
          const ActiveTransfersList(),
        ],
      ),
    );
  }

  // === WIDGETS DÙNG CHUNG ===

  // Tách các nút action của AppBar ra để tái sử dụng
  List<Widget> _buildAppBarActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.history),
        tooltip: 'Lịch sử',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HistoryScreen()),
          );
        },
      ),
      IconButton(
        icon: const Icon(Icons.settings),
        tooltip: 'Cài đặt',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const SettingsScreen()),
          );
        },
      ),
    ];
  }

  // Tách widget danh sách thiết bị ra một hàm riêng
  Widget _buildDeviceList(WidgetRef ref) {
    final onlineDevicesAsync = ref.watch(onlineDevicesProvider);
    return onlineDevicesAsync.when(
      data: (devices) {
        if (devices.isEmpty) {
          return const EmptyStateWidget(
            icon: Icons.wifi_off_rounded,
            message: 'Không tìm thấy thiết bị nào.\nHãy đảm bảo các thiết bị khác đang chạy QuickSender và kết nối cùng mạng Wi-Fi.',
          );
        }
        return ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return ListTile(
              leading: Icon(_getIconForOS(device.os)),
              title: Text(device.name),
              subtitle: Text(device.ipAddress),
              trailing: const Icon(Icons.circle, color: Colors.green, size: 14),
              onTap: () async {
                final result = await FilePicker.platform.pickFiles(allowMultiple: true);
                if (result != null && result.files.isNotEmpty) {
                  try {
                    await ref.read(fileTransferServiceProvider).requestToSendFiles(device, result.files);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Đã gửi yêu cầu tới ${device.name}...')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: $e')),
                    );
                  }
                }
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Lỗi khi khám phá mạng: $err')),
    );
  }

  // Hàm helper để lấy icon tương ứng với hệ điều hành
  IconData _getIconForOS(DeviceOS os) {
    switch (os) {
      case DeviceOS.windows:
        return Icons.desktop_windows;
      case DeviceOS.android:
        return Icons.phone_android;
      case DeviceOS.ios:
        return Icons.phone_iphone;
      case DeviceOS.linux:
        return Icons.laptop;
      case DeviceOS.macos:
        return Icons.laptop_mac;
      default:
        return Icons.devices;
    }
  }
}