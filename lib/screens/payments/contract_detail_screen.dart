import 'package:final_project/models/contract.dart';
import 'package:final_project/models/payment.dart';
import 'package:final_project/models/room.dart';
import 'package:final_project/models/tenant.dart';
import 'package:final_project/services/api_service.dart';
import 'package:flutter/material.dart';
import 'payment_form_screen.dart';

class ContractDetailScreen extends StatefulWidget {
  final Contract contract;
  final Room? room;
  final Tenant? tenant;

  const ContractDetailScreen({
    super.key,
    required this.contract,
    this.room,
    this.tenant,
  });

  @override
  State<ContractDetailScreen> createState() => _ContractDetailScreenState();
}

class _ContractDetailScreenState extends State<ContractDetailScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Payment>> futurePayments;

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  void _loadPayments() {
    futurePayments = apiService.getPaymentsByContractId(widget.contract.id);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active': return Colors.green;
      case 'about_to_expire': return Colors.orange;
      case 'expired': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final roomPrice = widget.room?.price ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Hợp đồng ${widget.contract.id}'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Thông tin hợp đồng',
            [
              _infoRow('Phòng', widget.room?.id ?? widget.contract.roomId),
              _infoRow('Loại phòng', widget.room?.roomType ?? '-'),
              _infoRow('Giá thuê/tháng', roomPrice > 0 ? '${roomPrice.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ' : '-'),
              _infoRow('Người thuê', widget.tenant?.fullName ?? '-'),
              _infoRow('SĐT', widget.tenant?.contact ?? '-'),
              _infoRow('Ngày bắt đầu', widget.contract.startDate),
              _infoRow('Ngày kết thúc', widget.contract.endDate),
              _infoRow('Tiền đặt cọc', '${widget.contract.deposit.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ'),
              _infoRow('Trạng thái', widget.contract.status, color: _getStatusColor(widget.contract.status)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lịch sử thanh toán', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.blue, size: 30),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentFormScreen(
                        contractId: widget.contract.id,
                        roomPrice: roomPrice,
                      ),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      _loadPayments();
                    });
                  }
                },
              ),
            ],
          ),
          const Divider(),
          FutureBuilder<List<Payment>>(
            future: futurePayments,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Lỗi: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Chưa có thanh toán nào', style: TextStyle(color: Colors.grey)),
                );
              }

              final payments = snapshot.data!..sort((a, b) => b.date.compareTo(a.date));

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: payments.length,
                itemBuilder: (context, index) {
                  final p = payments[index];
                  return Card(
                    child: ListTile(
                      leading: const Icon(Icons.payment, color: Colors.green),
                      title: Text('${p.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ'),
                      subtitle: Text('${p.date}\n${p.note}'),
                      isThreeLine: true,
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w500, color: color)),
        ],
      ),
    );
  }
}