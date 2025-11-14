import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import các models
import 'package:quicksender/src/data/models/device.dart';
// Cần cho DeviceOS

// Import các providers
import 'package:quicksender/src/presentation/providers/network_providers.dart';
import 'package:quicksender/src/presentation/providers/settings_providers.dart';
import 'package:quicksender/src/presentation/screens/history_screen.dart';

// Import các widget chung

class ReceiveScreen extends ConsumerWidget {
  const ReceiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final thisDevice = ref.watch(currentDeviceProvider);

    return Scaffold(
      // AppBar bây giờ chỉ còn các nút action, không có tiêu đề
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Nền trong suốt
        elevation: 0,
        actions: [
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
            icon: const Icon(Icons.info_outline),
            tooltip: 'Thông tin mạng',
            onPressed: thisDevice == null
                ? null
                : () => _showNetworkInfoDialog(context, thisDevice),
          ),
        ],
      ),
      // Body chính
      body: thisDevice == null
          // Trạng thái đang tải khi chưa có thông tin thiết bị
          ? const Center(child: CircularProgressIndicator())
          // Giao diện chính khi đã có thông tin
          : Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Đẩy nội dung lên trên một chút
                    const Spacer(flex: 2),

                    // Avatar/Icon lớn
                    PulsingAvatar(
                      // Lấy icon tương ứng với HĐH của thiết bị hiện tại
                      iconData: _getIconForOS(thisDevice.os),
                    ),
                    const SizedBox(height: 20),

                    // Tên thiết bị
                    Text(
                      thisDevice.name,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),

                    // Địa chỉ IP
                    Text(
                      thisDevice.ipAddress,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                    ),

                    // Spacer đẩy nút toggle xuống dưới cùng
                    const Spacer(flex: 3),

                    // Widget cho nút "Quick Save"
                    _buildQuickSaveToggle(context, ref),

                    // Thêm một chút khoảng trống ở dưới
                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
    );
  }

  // Widget con cho nút "Quick Save"
  Widget _buildQuickSaveToggle(BuildContext context, WidgetRef ref) {
    // `watch` provider để UI tự cập nhật khi state thay đổi
    final isQuickSaveOn = ref.watch(quickSaveProvider);

    return Column(
      children: [
        Text(
          'Lưu nhanh',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        SegmentedButton<bool>(
          segments: const [
            ButtonSegment<bool>(value: false, label: Text('Tắt')),
            ButtonSegment<bool>(value: true, label: Text('Bật')),
          ],
          selected: {isQuickSaveOn},
          onSelectionChanged: (Set<bool> newSelection) {
            // `read` provider để thay đổi state khi người dùng nhấn
            ref.read(quickSaveProvider.notifier).state = newSelection.first;
            // TODO: Lưu cài đặt này vào database để ghi nhớ
          },
        ),
      ],
    );
  }

  // === HÀM HELPER MỚI ĐỂ HIỂN THỊ DIALOG ===
  void _showNetworkInfoDialog(BuildContext context, Device thisDevice) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thông tin mạng'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Tên thiết bị: ${thisDevice.name}'),
              const SizedBox(height: 8),
              Text('Địa chỉ IP: ${thisDevice.ipAddress}'),
              const SizedBox(height: 8),
              Text('Port khám phá: ${thisDevice.port}'),
              const SizedBox(height: 8),
              Text('Hệ điều hành: ${thisDevice.os.name}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Đóng'),
            ),
          ],
        );
      },
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

class PulsingAvatar extends StatefulWidget {
  final IconData iconData;
  const PulsingAvatar({super.key, required this.iconData});

  @override
  State<PulsingAvatar> createState() => _PulsingAvatarState();
}

// `SingleTickerProviderStateMixin` là cần thiết để cung cấp "nhịp tim" cho AnimationController
class _PulsingAvatarState extends State<PulsingAvatar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Tạo controller với thời gian animation là 3 giây
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 7000),
    );
    // Bắt đầu animation và lặp lại vô hạn
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200, // Kích thước tổng thể của khu vực animation
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // === CÁC VÒNG SÓNG ANIMATION ===
          // Chúng ta tạo ra 3 vòng sóng, mỗi vòng bắt đầu ở một thời điểm khác nhau
          _buildExpandingWave(delay: 0.0),
          _buildExpandingWave(delay: 0.3),
          _buildExpandingWave(delay: 0.6),

          // === ICON CHÍNH Ở GIỮA ===
          CircleAvatar(
            radius: 60,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              widget.iconData,
              size: 60,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  // Hàm helper để build một vòng sóng
  Widget _buildExpandingWave({required double delay}) {
    // AnimatedBuilder sẽ tự động lắng nghe controller và build lại chỉ riêng widget này
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // `CurvedAnimation` với `Interval` để tạo hiệu ứng trễ
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, 1.0, curve: Curves.easeInOut),
        );

        // Tính toán bán kính và độ mờ dựa trên giá trị animation (0.0 -> 1.0)
        final radius = 60 + (animation.value * 140);
        final opacity = 1.0 - animation.value;

        return Container(
          width: radius,
          height: radius,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              // Màu của sóng, mờ dần đi
              color: Theme.of(context).colorScheme.primary.withOpacity(opacity > 0 ? opacity : 0),
              width: 2.0,
            ),
          ),
        );
      },
    );
  }
}
