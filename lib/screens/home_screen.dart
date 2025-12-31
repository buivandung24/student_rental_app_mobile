import 'package:final_project/models/contract.dart';
import 'package:final_project/screens/contracts/contract_list_screen.dart';
import 'package:final_project/screens/payments/payment_list_screen.dart';
import 'package:final_project/screens/rooms/room_list_screen.dart';
import 'package:final_project/screens/tenants/tenant_list_screen.dart';
import 'package:final_project/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService apiService = ApiService();

  late Future<int> totalRooms;
  late Future<int> occupiedRooms;
  late Future<int> availableRooms;
  late Future<List<Contract>> expiringContracts;
  late Future<Map<String, double>> monthlyRevenue;

  final NumberFormat currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    totalRooms = apiService.getRooms().then((rooms) => rooms.length);
    occupiedRooms = apiService.getRooms().then((rooms) => rooms.where((r) => r.status == 'occupied').length);
    availableRooms = apiService.getRooms().then((rooms) => rooms.where((r) => r.status == 'available').length);

    expiringContracts = apiService.getContracts().then((contracts) =>
        contracts.where((c) => c.status == 'about_to_expire').toList());

    // Tính doanh thu theo tháng trong năm hiện tại
    monthlyRevenue = _calculateMonthlyRevenue();
  }

  Future<Map<String, double>> _calculateMonthlyRevenue() async {
    final payments = await apiService.getPayments();
    final now = DateTime.now();
    final Map<String, double> revenue = {};

    for (int i = 1; i <= 12; i++) {
      final monthStr = i.toString().padLeft(2, '0');
      revenue['$monthStr/${now.year}'] = 0;
    }

    for (var p in payments) {
      final date = DateTime.parse(p.date);
      if (date.year == now.year) {
        final key = '${date.month.toString().padLeft(2, '0')}/${date.year}';
        revenue[key] = (revenue[key] ?? 0) + p.amount;
      }
    }

    return revenue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tổng quan'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // === PHẦN 1: Thống kê nhanh ===
            Row(
              children: [
                Expanded(child: _buildStatCard('Tổng phòng', totalRooms, Icons.home, Colors.blue)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Đang thuê', occupiedRooms, Icons.people, Colors.red)),
                const SizedBox(width: 12),
                Expanded(child: _buildStatCard('Phòng trống', availableRooms, Icons.home_repair_service, Colors.green)),
              ],
            ),
            const SizedBox(height: 24),

            // === PHẦN 2: Hợp đồng sắp hết hạn ===
            const Text(
              'Hợp đồng sắp hết hạn',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            FutureBuilder<List<Contract>>(
              future: expiringContracts,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Card(
                    color: Colors.orange,
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text('Không có hợp đồng nào sắp hết hạn', textAlign: TextAlign.center),
                    ),
                  );
                }

                final contracts = snapshot.data!;
                return SizedBox(
                  height: 140,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: contracts.length,
                    itemBuilder: (context, index) {
                      final contract = contracts[index];
                      return Card(
                        color: Colors.orange.shade100,
                        margin: const EdgeInsets.only(right: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('HĐ ${contract.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text('Phòng: ${contract.roomId}'),
                              Text('Người thuê: ${contract.tenantId}'),
                              Text('Hết hạn: ${contract.endDate}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, Future<int> futureCount, IconData icon, Color color) {
    return FutureBuilder<int>(
      future: futureCount,
      builder: (context, snapshot) {
        final count = snapshot.data ?? 0;
        return Card(
          elevation: 6,
          color: color.withOpacity(0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Icon(icon, size: 40, color: color),
                const SizedBox(height: 8),
                Text(
                  '$count',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: color),
                ),
                Text(title, style: TextStyle(fontSize: 14, color: color)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBarChart(List<String> months, List<double> revenues) {
    // Tạo dữ liệu đơn giản cho biểu đồ cột
    final List<Map<String, dynamic>> chartData = [];
    for (int i = 0; i < months.length; i++) {
      chartData.add({
        'month': months[i].split('/')[0], // Chỉ lấy tháng (01, 02...)
        'revenue': revenues[i] / 1000000, // Chuyển sang triệu đồng cho dễ đọc
      });
    }

    // Vì Flutter không có chart built-in, ta dùng ListView ngang với các cột thủ công
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: chartData.length,
      itemBuilder: (context, index) {
        final item = chartData[index];
        final height = (item['revenue'] as double) * 20; // Scale để vừa màn hình
        final isCurrentMonth = index + 1 == DateTime.now().month;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                currencyFormat.format(item['revenue'] * 1000000),
                style: TextStyle(fontSize: 10, fontWeight: isCurrentMonth ? FontWeight.bold : FontWeight.normal),
              ),
              const SizedBox(height: 4),
              Container(
                width: 30,
                height: height > 0 ? height : 10,
                decoration: BoxDecoration(
                  color: isCurrentMonth ? Colors.blue : Colors.blue.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(item['month'], style: const TextStyle(fontSize: 12)),
            ],
          ),
        );
      },
    );
  }
}

class ResourcesScreen extends StatelessWidget {
  const ResourcesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tài nguyên'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Phòng trọ'),
              Tab(icon: Icon(Icons.person), text: 'Người thuê'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RoomListScreen(),
            TenantListScreen(),
          ],
        ),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = <Widget>[
    DashboardScreen(),
    ContractListScreen(),
    ResourcesScreen(),
    PaymentListScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description),
            label: 'Hợp đồng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Phòng & Khách',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.payment),
            label: 'Thanh toán',
          ),
        ],
      ),
    );
  }
}