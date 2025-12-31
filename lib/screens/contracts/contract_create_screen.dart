import 'package:final_project/models/contract.dart';
import 'package:final_project/models/room.dart';
import 'package:final_project/models/tenant.dart';
import 'package:final_project/services/api_service.dart';
import 'package:flutter/material.dart';

class ContractCreateScreen extends StatefulWidget {
  const ContractCreateScreen({super.key});

  @override
  State<ContractCreateScreen> createState() => _ContractCreateScreenState();
}

class _ContractCreateScreenState extends State<ContractCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  String? _selectedRoomId;
  String? _selectedTenantId;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 365));
  final TextEditingController _depositController = TextEditingController();

  late Future<List<Room>> futureAvailableRooms;
  late Future<List<Tenant>> futureTenants;

  @override
  void initState() {
    super.initState();
    futureAvailableRooms = apiService.getRooms();
    futureTenants = apiService.getTenants();
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) _endDate = _startDate.add(const Duration(days: 30));
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _calculateStatus() {
    final now = DateTime.now();
    final daysToEnd = _endDate.difference(now).inDays;

    if (daysToEnd < 0) return 'expired';
    if (daysToEnd <= 30) return 'about_to_expire';
    return 'active';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedRoomId == null || _selectedTenantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn phòng và người thuê')),
      );
      return;
    }

    final newContract = Contract(
      id: '', // MockAPI tự sinh ID
      roomId: _selectedRoomId!,
      tenantId: _selectedTenantId!,
      startDate: _startDate.toIso8601String().split('T')[0],
      endDate: _endDate.toIso8601String().split('T')[0],
      deposit: double.tryParse(_depositController.text.replaceAll('.', '')) ?? 0,
      status: _calculateStatus(),
    );

    try {
      await apiService.createContract(newContract);

      // Cập nhật trạng thái phòng thành occupied
      final rooms = await apiService.getRooms();
      final room = rooms.firstWhere((r) => r.id == _selectedRoomId);
      final updatedRoom = Room(
        id: room.id,
        roomType: room.roomType,
        price: room.price,
        status: 'occupied',
      );
      await apiService.updateRoom(updatedRoom);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo hợp đồng thành công!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tạo hợp đồng mới')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Chọn phòng trống
              FutureBuilder<List<Room>>(
                future: futureAvailableRooms,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  final availableRooms = snapshot.data!.where((r) => r.status == 'available').toList();
                  return DropdownButtonFormField<String>(
                    value: _selectedRoomId,
                    decoration: const InputDecoration(labelText: 'Chọn phòng trống', border: OutlineInputBorder()),
                    items: availableRooms.map((room) {
                      return DropdownMenuItem(
                        value: room.id,
                        child: Text('Phòng ${room.id} - ${room.roomType} (${room.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ)'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedRoomId = value),
                    validator: (value) => value == null ? 'Chọn phòng' : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Chọn người thuê
              FutureBuilder<List<Tenant>>(
                future: futureTenants,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const CircularProgressIndicator();
                  return DropdownButtonFormField<String>(
                    value: _selectedTenantId,
                    decoration: const InputDecoration(labelText: 'Chọn người thuê', border: OutlineInputBorder()),
                    items: snapshot.data!.map((tenant) {
                      return DropdownMenuItem(
                        value: tenant.id,
                        child: Text('${tenant.fullName} (${tenant.contact})'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedTenantId = value),
                    validator: (value) => value == null ? 'Chọn người thuê' : null,
                  );
                },
              ),
              const SizedBox(height: 16),

              // Ngày bắt đầu
              ListTile(
                title: Text('Ngày bắt đầu: ${_startDate.toIso8601String().split('T')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: 8),

              // Ngày kết thúc
              ListTile(
                title: Text('Ngày kết thúc: ${_endDate.toIso8601String().split('T')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _depositController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tiền đặt cọc (VNĐ)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nhập tiền cọc';
                  if (double.tryParse(value.replaceAll('.', '')) == null) return 'Số không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Tạo hợp đồng', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}