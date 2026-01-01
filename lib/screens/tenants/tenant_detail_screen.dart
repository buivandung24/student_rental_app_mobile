import 'package:final_project/models/tenant.dart';
import 'package:final_project/services/api_service.dart';
import 'package:flutter/material.dart';
import 'tenant_form_screen.dart';

class TenantDetailScreen extends StatelessWidget {
  final Tenant tenant;
  final ApiService apiService = ApiService();

  TenantDetailScreen({super.key, required this.tenant});

  Future<void> _deleteTenant(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa người thuê?'),
        content: Text('Bạn có chắc muốn xóa ${tenant.fullName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await apiService.deleteTenant(tenant.id);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Xóa người thuê thành công')),
          );
          Navigator.pop(context, true);
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
        title: Text(tenant.fullName),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TenantFormScreen(tenant: tenant),
                ),
              );
              if (result == true) {
                if (context.mounted) Navigator.pop(context, true);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => _deleteTenant(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard('Họ và tên', tenant.fullName),
            _buildInfoCard('Số điện thoại', tenant.contact),
            _buildInfoCard('ID', tenant.id, color: Colors.grey),
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