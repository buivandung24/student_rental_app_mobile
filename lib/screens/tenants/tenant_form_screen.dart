import 'package:final_project/models/tenant.dart';
import 'package:final_project/services/api_service.dart';
import 'package:flutter/material.dart';


class TenantFormScreen extends StatefulWidget {
  final Tenant? tenant;

  const TenantFormScreen({super.key, this.tenant});

  @override
  State<TenantFormScreen> createState() => _TenantFormScreenState();
}

class _TenantFormScreenState extends State<TenantFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService apiService = ApiService();

  late TextEditingController _idController;
  late TextEditingController _fullNameController;
  late TextEditingController _contactController;

  @override
  void initState() {
    super.initState();
    _idController = TextEditingController(text: widget.tenant?.id ?? '');
    _fullNameController = TextEditingController(text: widget.tenant?.fullName ?? '');
    _contactController = TextEditingController(text: widget.tenant?.contact ?? '');
  }

  @override
  void dispose() {
    _idController.dispose();
    _fullNameController.dispose();
    _contactController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedTenant = Tenant(
      id: _idController.text.trim(),
      fullName: _fullNameController.text.trim(),
      contact: _contactController.text.trim(),
    );

    try {
      if (widget.tenant == null) {
        // Thêm mới
        await apiService.createTenant(updatedTenant);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Thêm người thuê thành công')),
        );
      } else {
        // Cập nhật (sửa)
        await apiService.updateTenant(updatedTenant);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cập nhật thông tin người thuê thành công')),
        );
      }
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.tenant != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Sửa thông tin' : 'Thêm người thuê mới'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(
                  labelText: 'Họ và tên',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập họ tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _contactController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value.trim())) {
                    return 'Số điện thoại không hợp lệ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(isEdit ? 'Cập nhật' : 'Thêm mới', style: const TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}