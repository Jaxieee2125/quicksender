// trong file: lib/src/presentation/screens/main_screen_shell.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quicksender/src/data/models/device.dart';
import 'package:quicksender/src/presentation/providers/network_providers.dart';

// Import các màn hình con
import 'package:quicksender/src/presentation/screens/receive/receive_screen.dart';
import 'package:quicksender/src/presentation/screens/send/send_screen.dart';
import 'package:quicksender/src/presentation/screens/drop/drop_screen.dart';
import 'package:quicksender/src/presentation/screens/settings/settings_screen.dart';

// Import các widget chung
import 'package:quicksender/src/presentation/widgets/active_transfers_list.dart';

// Import logic lắng nghe sự kiện
import 'package:quicksender/src/core/events/transfer_events.dart';
import 'package:quicksender/src/presentation/providers/transfer_providers.dart';
import 'package:quicksender/src/core/utils/dialogs.dart'; // File chứa showErrorDialog
import 'package:quicksender/src/presentation/providers/settings_providers.dart';

import 'package:quicksender/src/presentation/widgets/dialogs/receive_file_dialog.dart';
import 'package:quicksender/src/presentation/widgets/dialogs/receive_text_dialog.dart';

class MainScreenShell extends ConsumerStatefulWidget {
  const MainScreenShell({super.key});

  @override
  ConsumerState<MainScreenShell> createState() => _MainScreenShellState();
}

class _MainScreenShellState extends ConsumerState<MainScreenShell> {
  int _selectedIndex = 0; // Index của màn hình đang được chọn
  bool _isRailExtended = true;

  // Danh sách các màn hình chính
  static const List<Widget> _widgetOptions = <Widget>[
    ReceiveScreen(),
    SendScreen(),
    DropScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<Map<String, dynamic>>>(incomingTransferRequestsProvider, (previous, next) {
      if (!next.hasValue || next.value == null) return;
      // Ngăn dialog hiển thị lại nếu state không thay đổi
      if (previous?.value == next.value) return;

      final payload = next.value!;
      final isQuickSaveOn = ref.read(quickSaveProvider);
      final transferService = ref.read(fileTransferServiceProvider);

      if (isQuickSaveOn) {
        // Nếu Quick Save đang bật, tự động chấp nhận
        debugPrint('Quick Save is ON. Auto-accepting transfer.');
        transferService.acceptTransfer(payload);
      }
      else {
        debugPrint('Quick Save is OFF. Prompting user for transfer.');
      

      final sender = Device.fromJson(payload['sender']);
      final fileCount = (payload['files'] as List).length;

      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withOpacity(0.85), // Hiệu ứng mờ tối
        builder: (_) => ReceiveFileDialog(
          sender: sender,
          fileCount: fileCount,
          onDecline: () {
            ref.read(fileTransferServiceProvider).declineTransfer(payload);
            Navigator.of(context).pop();
          },
          onAccept: () {
            ref.read(fileTransferServiceProvider).acceptTransfer(payload);
            Navigator.of(context).pop();
          },
        ),
      );
      }
    });

      ref.listen<AsyncValue<Map<String, dynamic>>>(incomingTextMessagesProvider, (prev, next) { // Bạn sẽ tạo provider này
      if (!next.hasValue || next.value == null) return;
      
      final payload = next.value!;
      final sender = Device.fromJson(payload['sender']);
      final content = payload['content'] as String;

      showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.85),
        builder: (_) => ReceiveTextDialog(
          sender: sender,
          message: content,
          onCopy: () {
            Clipboard.setData(ClipboardData(text: content));
            Navigator.of(context).pop();
            // Hiển thị một SnackBar nhỏ để xác nhận đã sao chép
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã sao chép vào clipboard!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          onClose: () {
            Navigator.of(context).pop();
          },
        ),
      );
  });

    ref.listen<Stream<TransferEvent>>(
      // Chúng ta cần `select` để chỉ lắng nghe stream, không build lại widget khi có event
      fileTransferServiceProvider.select((provider) => provider.eventsStream),
      (previous, next) {
        // `next` là stream, chúng ta cần listen vào nó một lần nữa
        next.listen((event) {
          if (event is NotEnoughSpaceEvent) {
            showErrorDialog(
              context: context,
              title: 'Không đủ dung lượng',
              message: 'Không đủ dung lượng để nhận file. Yêu cầu ${event.requiredSpaceMB.toStringAsFixed(1)} MB nhưng chỉ còn trống ${event.freeSpaceMB.toStringAsFixed(1)} MB.',
            );
          } else if (event is ChecksumMismatchEvent) {
            showErrorDialog(
              context: context,
              title: 'Lỗi truyền file',
              message: 'File "${event.fileName}" đã bị lỗi trong quá trình truyền và đã được tự động xóa để đảm bảo an toàn.',
            );
          } else if (event is ResumeFailedEvent) {
            showErrorDialog(
              context: context,
              title: 'Không thể tiếp tục',
              message: 'Không nhận được phản hồi từ thiết bị kia. Vui lòng thử lại.',
            );
          }
        });
      },
    );
    
    // Sử dụng LayoutBuilder để chọn thanh điều hướng phù hợp
    return LayoutBuilder(
      builder: (context, constraints) {
        // Nếu màn hình hẹp (điện thoại) -> Dùng BottomNavigationBar
        if (constraints.maxWidth < 640) {
          return Scaffold(
            body: Column(
              children: [
                Expanded(
                  child: IndexedStack( // Dùng IndexedStack để giữ trạng thái các tab
                    index: _selectedIndex,
                    children: _widgetOptions,
                  ),
                ),
                // Thanh tiến trình luôn nằm ở dưới cùng
                const ActiveTransfersList(),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(icon: Icon(Icons.call_received), label: 'Nhận'),
                BottomNavigationBarItem(icon: Icon(Icons.send), label: 'Gửi'),
                BottomNavigationBarItem(icon: Icon(Icons.public), label: 'Local Drop'),
                BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Cài đặt'),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Theme.of(context).colorScheme.primary,
              unselectedItemColor: Colors.grey, // Quan trọng để các item khác vẫn hiện
              onTap: _onItemTapped,
            ),
            // Thanh tiến trình có thể được đặt chồng lên trên bằng Stack hoặc ở dưới BottomNav
            // Để đơn giản, ta đặt nó trong 1 Column
          );
        } else {
          // Nếu màn hình rộng (desktop) -> Dùng NavigationRail
          return Scaffold(
            body: Row(
              children: <Widget>[
                // THANH BÊN ĐIỀU HƯỚNG MỚI
                NavigationRail(
                  // Trạng thái mở rộng được điều khiển bởi biến state
                  extended: _isRailExtended,
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  
                  // === PHẦN HEADER CỦA THANH BÊN ===
                  leading: Column(
                    children: [
                      // IconButton(
                      //   icon: Icon(_isRailExtended ? Icons.menu_open : Icons.menu),
                      //   onPressed: () {
                      //     setState(() {
                      //       _isRailExtended = !_isRailExtended;
                      //     });
                      //   },
                      // ),
                      const SizedBox(height: 20),
                      // Hiển thị logo hoặc tên app
                      if (_isRailExtended)
                        const Text(
                          'QuickSender',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                  // === CÁC MỤC ĐIỀU HƯỚNG ===
                  destinations: const <NavigationRailDestination>[
                    NavigationRailDestination(
                      icon: Icon(Icons.call_received_outlined),
                      selectedIcon: Icon(Icons.call_received),
                      label: Text('Nhận'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.send_outlined),
                      selectedIcon: Icon(Icons.send),
                      label: Text('Gửi'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.public_outlined),
                      selectedIcon: Icon(Icons.public),
                      label: Text('Local Drop'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.settings_outlined),
                      selectedIcon: Icon(Icons.settings),
                      label: Text('Cài đặt'),
                    ),
                  ],

                  // === TÙY CHỈNH GIAO DIỆN (ĐỂ GIỐNG LOCALSEND) ===
                  backgroundColor: Theme.of(context).colorScheme.surface, // Màu nền
                  indicatorColor: Theme.of(context).colorScheme.primaryContainer, // Màu của item được chọn
                  selectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.onPrimaryContainer),
                  unselectedIconTheme: IconThemeData(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  selectedLabelTextStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                ),
                
                const VerticalDivider(thickness: 1, width: 1),
                
                // Phần nội dung chính (không thay đổi)
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: IndexedStack(
                          index: _selectedIndex,
                          children: _widgetOptions,
                        ),
                      ),
                      const ActiveTransfersList(),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}