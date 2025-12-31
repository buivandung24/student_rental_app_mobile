import 'package:final_project/models/contract.dart';
import 'package:final_project/models/room.dart';
import 'package:final_project/models/tenant.dart';
import 'package:final_project/services/api_service.dart';
import 'package:flutter/material.dart';
import 'contract_detail_screen.dart';
import 'contract_create_screen.dart';

class ContractListScreen extends StatefulWidget {
  const ContractListScreen({super.key});

  @override
  State<ContractListScreen> createState() => _ContractListScreenState();
}

class _ContractListScreenState extends State<ContractListScreen> {
  late Future<List<Contract>> futureContracts;
  late Future<List<Room>> futureRooms;
  late Future<List<Tenant>> futureTenants;
  final ApiService apiService = ApiService();

  String _filterStatus = 'all'; // all, active, about_to_expire, expired

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      futureContracts = apiService.getContracts();
      futureRooms = apiService.getRooms();
      futureTenants = apiService.getTenants();
    });
  }

  void _refresh() {
    _loadData();
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.green;
      case 'about_to_expire':
        return Colors.orange;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'active':
        return 'Đang hiệu lực';
      case 'about_to_expire':
        return 'Sắp hết hạn';
      case 'expired':
        return 'Đã hết hạn';
      default:
        return 'Không xác định';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách Hợp đồng'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) {
              setState(() {
                _filterStatus = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'all', child: Text('Tất cả')),
              const PopupMenuItem(value: 'active', child: Text('Đang hiệu lực')),
              const PopupMenuItem(value: 'about_to_expire', child: Text('Sắp hết hạn')),
              const PopupMenuItem(value: 'expired', child: Text('Đã hết hạn')),
            ],
          ),
        ],
      ),
      body: FutureBuilder(
        future: Future.wait([futureContracts, futureRooms, futureTenants]),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData) {
            return const Center(child: Text('Không có dữ liệu'));
          }

          final contracts = snapshot.data![0] as List<Contract>;
          final rooms = snapshot.data![1] as List<Room>;
          final tenants = snapshot.data![2] as List<Tenant>;

          // Map để tra cứu nhanh
          final roomMap = {for (var r in rooms) r.id: r};
          final tenantMap = {for (var t in tenants) t.id: t};

          // Lọc theo trạng thái
          final filteredContracts = _filterStatus == 'all'
              ? contracts
              : contracts.where((c) => c.status == _filterStatus).toList();

          if (filteredContracts.isEmpty) {
            return Center(
              child: Text(_filterStatus == 'all'
                  ? 'Chưa có hợp đồng nào'
                  : 'Không có hợp đồng nào $_getStatusText(_filterStatus)'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: filteredContracts.length,
            itemBuilder: (context, index) {
              final contract = filteredContracts[index];
              final room = roomMap[contract.roomId];
              final tenant = tenantMap[contract.tenantId];

              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(contract.status),
                    child: Text(contract.id, style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text('Phòng ${room?.id ?? contract.roomId}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Người thuê: ${tenant?.fullName ?? 'Chưa có thông tin'}'),
                      Text('Từ: ${contract.startDate} → ${contract.endDate}'),
                      Text('Trạng thái: ${_getStatusText(contract.status)}',
                          style: TextStyle(color: _getStatusColor(contract.status), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ContractDetailScreen(
                          contract: contract,
                          room: room,
                          tenant: tenant,
                        ),
                      ),
                    );
                    if (result == true) _refresh();
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
            MaterialPageRoute(builder: (context) => const ContractCreateScreen()),
          );
          if (result == true) _refresh();
        },
        child: const Icon(Icons.add),
        tooltip: 'Tạo hợp đồng mới',
      ),
    );
  }
}