import 'package:final_project/models/contract.dart';
import 'package:final_project/models/room.dart';
import 'package:final_project/models/tenant.dart';
import 'package:final_project/services/api_service.dart';
import 'package:flutter/material.dart';

class ContractDetailScreen extends StatefulWidget {
  final Contract contract;
  final Room? room;
  final Tenant? tenant;

  const ContractDetailScreen({super.key, required this.contract, this.room, this.tenant});

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen> {
  final ApiService apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    final statusColor = widget.contract.status == 'active'
        ? Colors.green
        : widget.contract.status == 'about_to_expire'
        ? Colors.orange
        : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hợp đồng ${widget.contract.id}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Phòng', widget.room?.id ?? widget.contract.roomId),
            _infoRow('Loại phòng', widget.room?.roomType ?? '-'),
            _infoRow('Người thuê', widget.tenant?.fullName ?? '-'),
            _infoRow('SĐT', widget.tenant?.contact ?? '-'),
            _infoRow('Ngày bắt đầu', widget.contract.startDate),
            _infoRow('Ngày kết thúc', widget.contract.endDate),
            _infoRow('Tiền cọc', '${widget.contract.deposit.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ'),
            _infoRow('Trạng thái', widget.contract.status, color: statusColor),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, color: color)),
        ],
      ),
    );
  }
}