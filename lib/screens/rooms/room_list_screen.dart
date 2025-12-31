import 'package:final_project/models/room.dart';
import 'package:final_project/services/api_service.dart';
import 'package:flutter/material.dart';
import 'room_detail_screen.dart';
import 'room_form_screen.dart';

class RoomListScreen extends StatefulWidget {
  const RoomListScreen({super.key});

  @override
  State<RoomListScreen> createState() => _RoomListScreenState();
}

class _RoomListScreenState extends State<RoomListScreen> {
  late Future<List<Room>> futureRooms;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  void _loadRooms() {
    setState(() {
      futureRooms = apiService.getRooms();
    });
  }

  // Hàm refresh khi thêm/sửa/xóa
  void _refreshRooms() {
    _loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Phòng trọ'),
      ),
      body: FutureBuilder<List<Room>>(
        future: futureRooms,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 60),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: _loadRooms,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Chưa có phòng nào. Hãy thêm phòng mới!'),
            );
          }

          final rooms = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: rooms.length,
            itemBuilder: (context, index) {
              final room = rooms[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: room.status == 'available'
                        ? Colors.green
                        : Colors.red,
                    child: Text(
                      room.id,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    'Phòng ${room.id} - ${room.roomType}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Giá: ${room.price.toStringAsFixed(0).replaceAll(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), r'$1.')} đ/tháng\n'
                        'Trạng thái: ${room.status == 'available' ? 'Trống' : 'Đã thuê'}',
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RoomDetailScreen(room: room),
                      ),
                    );
                    if (result == true) {
                      _refreshRooms(); // Refresh nếu có thay đổi (sửa/xóa)
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RoomFormScreen(),
            ),
          );
          if (result == true) {
            _refreshRooms();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Thêm phòng mới',
      ),
    );
  }
}