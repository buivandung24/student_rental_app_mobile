import 'package:final_project/models/room.dart';
import 'package:final_project/services/api_service.dart';
import 'package:flutter/material.dart';
import 'room_form_screen.dart';

class RoomDetailScreen extends StatelessWidget {
  final Room room;
  final ApiService apiService = ApiService();

  RoomDetailScreen({super.key, required this.room});

  Future<void> _deleteRoom(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa phòng?'),
        content: Text('Bạn có chắc muốn xóa phòng ${room.id}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await apiService.deleteRoom(room.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa phòng thành công')),
          );
          Navigator.pop(context, true); // Trả về true để refresh list
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi khi xóa: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phòng ${room.id}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoomFormScreen(room: room),
                ),
              );
              if (result == true) {
                if (context.mounted) Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteRoom(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Mã phòng', room.id),
            _buildInfoCard('Loại phòng', room.roomType),
            _buildInfoCard('Giá thuê', '${room.price.toStringAsFixed(0)} đ/tháng'),
            _buildInfoCard('Trạng thái', room.status == 'available' ? 'Trống' : 'Đã thuê',
                color: room.status == 'available' ? Colors.green : Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, {Color? color}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(value, style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}