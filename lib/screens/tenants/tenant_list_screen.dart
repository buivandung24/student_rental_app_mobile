import 'package:final_project/models/tenant.dart';
import 'package:final_project/services/api_service.dart';
import 'package:flutter/material.dart';
import 'tenant_detail_screen.dart';
import 'tenant_form_screen.dart';

class TenantListScreen extends StatefulWidget {
  const TenantListScreen({super.key});

  @override
  State<TenantListScreen> createState() => _TenantListScreenState();
}

class _TenantListScreenState extends State<TenantListScreen> {
  late Future<List<Tenant>> futureTenants;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadTenants();
  }

  void _loadTenants() {
    setState(() {
      futureTenants = apiService.getTenants();
    });
  }

  void _refreshTenants() {
    _loadTenants();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Người thuê'),
      ),
      body: FutureBuilder<List<Tenant>>(
        future: futureTenants,
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
                    onPressed: _loadTenants,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Chưa có người thuê nào. Hãy thêm mới!'),
            );
          }

          final tenants = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: tenants.length,
            itemBuilder: (context, index) {
              final tenant = tenants[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      tenant.fullName[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    tenant.fullName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('SĐT: ${tenant.contact}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TenantDetailScreen(tenant: tenant),
                      ),
                    );
                    if (result == true) {
                      _refreshTenants();
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
              builder: (context) => const TenantFormScreen(),
            ),
          );
          if (result == true) {
            _refreshTenants();
          }
        },
        child: const Icon(Icons.add),
        tooltip: 'Thêm người thuê mới',
      ),
    );
  }
}