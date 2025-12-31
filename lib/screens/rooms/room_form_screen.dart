import 'package:final_project/models/room.dart';
import 'package:final_project/services/api_service.dart';
import 'package:flutter/material.dart';


class RoomFormScreen extends StatefulWidget {
  final Room? room; // Nếu null thì là thêm mới, nếu có thì là sửa

  const RoomFormScreen({super.key, this.room});

  @override
  State<RoomFormScreen> createState() => _RoomFormScreenState();
}

class _RoomFormScreenState extends State<RoomFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  late TextEditingController _idController;
  late TextEditingController _priceController;
  String _roomType = 'Single';
  String _status = 'available';

  final List<String> roomTypes = ['Single', 'Double', 'Studio'];

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.room?.id ?? '');
    _priceController = TextEditingController(text: widget.room?.price.toString() ?? '');
    _roomType = widget.room?.roomType ?? 'Single';
    _status = widget.room?.status ?? 'available';
  }

  @override
  void dispose() {
    _idController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final newRoom = Room(
      id: _idController.text.trim(),
      roomType: _roomType,
      price: double.parse(_priceController.text.replaceAll('.', '')),
      status: _status,
    );

    try {
      if (widget.room == null) {
        // Thêm mới
        await apiService.createRoom(newRoom);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm phòng thành công')),
        );
      } else {
        // Cập nhật
        await apiService.updateRoom(newRoom);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật phòng thành công')),
        );
      }
      Navigator.pop(context, true); // Trả về true để refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.room != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa phòng' : 'Thêm phòng mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _idController,
                decoration: const InputDecoration(
                  labelText: 'Mã phòng (ví dụ: R101)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập mã phòng';
                  }
                  return null;
                },
                enabled: !isEdit, // Không cho sửa ID khi edit
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _roomType,
                decoration: const InputDecoration(
                  labelText: 'Loại phòng',
                  border: OutlineInputBorder(),
                ),
                items: roomTypes.map((type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _roomType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Giá thuê (VNĐ/tháng)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập giá';
                  }
                  if (double.tryParse(value.replaceAll('.', '')) == null) {
                    return 'Giá không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Trạng thái',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'available', child: Text('Trống')),
                  DropdownMenuItem(value: 'occupied', child: Text('Đã thuê')),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEdit ? 'Cập nhật' : 'Thêm phòng', style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}