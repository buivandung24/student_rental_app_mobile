import 'package:final_project/models/payment.dart';
import 'package:final_project/services/api_service.dart';
import 'package:flutter/material.dart';


class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  late Future<List<Payment>> futurePayments;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadPayments();
  }

  void _loadPayments() {
    setState(() {
      futurePayments = apiService.getPayments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lịch sử Thanh toán'),
      ),
      body: FutureBuilder<List<Payment>>(
        future: futurePayments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Chưa có thanh toán nào được ghi nhận'),
            );
          }

          final payments = snapshot.data!..sort((a, b) => b.date.compareTo(a.date));

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: payments.length,
            itemBuilder: (context, index) {
              final payment = payments[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      payment.amount.toStringAsFixed(0).substring(0, 1),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    '${payment.amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')} đ',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text(
                    'Hợp đồng: ${payment.contractId}\n'
                        'Ngày: ${payment.date}\n'
                        'Ghi chú: ${payment.note.isEmpty ? 'Không có' : payment.note}',
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}