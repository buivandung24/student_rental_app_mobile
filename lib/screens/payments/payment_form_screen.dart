import 'package:final_project/models/payment.dart';
import 'package:final_project/services/api_service.dart';
import 'package:flutter/material.dart';

class PaymentFormScreen extends StatefulWidget {
  final String contractId;
  final double roomPrice; // Để gợi ý số tiền mặc định

  const PaymentFormScreen({super.key, required this.contractId, required this.roomPrice});

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  DateTime _selectedDate = DateTime.now();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.roomPrice.toStringAsFixed(0);
    _noteController.text = 'Tiền phòng tháng ${_selectedDate.month}/${_selectedDate.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _noteController.text = 'Tiền phòng tháng ${picked.month}/${picked.year}';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final newPayment = Payment(
      id: '',
      contractId: widget.contractId,
      amount: double.parse(_amountController.text.replaceAll('.', '')),
      date: _selectedDate.toIso8601String().split('T')[0],
      note: _noteController.text.trim(),
    );

    try {
      await apiService.createPayment(newPayment);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ghi nhận thanh toán thành công!')),
      );
      Navigator.pop(context, true); // Trả về true để refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ghi nhận Thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              ListTile(
                title: Text('Ngày thanh toán: ${_selectedDate.toIso8601String().split('T')[0]}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectDate(context),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Số tiền (VNĐ)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Nhập số tiền';
                  if (double.tryParse(value.replaceAll('.', '')) == null) return 'Không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: const Text('Ghi nhận thanh toán', style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}