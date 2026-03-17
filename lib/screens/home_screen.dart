import 'package:flutter/material.dart';
import 'package:vehicle_manager/database/database_helper.dart';
import 'package:vehicle_manager/screens/add_vehicle_screen.dart';
import 'package:vehicle_manager/screens/vehicle_detail_screen.dart';
import 'package:vehicle_manager/vehicle_models/vehicle.dart';
import 'dart:io'; // Để sử dụng File

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Vehicle> _allVehicles = [];
  List<Vehicle> _filteredVehicles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterVehicles);
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    final vehicles = await DatabaseHelper.instance.getAllVehicles();

    if (!mounted) return;

    setState(() {
      _allVehicles = vehicles;
      _filteredVehicles = vehicles;
      _isLoading = false;
    });
  }

  void _filterVehicles() {
    final keyword = _searchController.text.trim().toLowerCase();

    setState(() {
      if (keyword.isEmpty) {
        _filteredVehicles = List.from(_allVehicles);
      } else {
        _filteredVehicles = _allVehicles.where((vehicle) {
          return vehicle.licensePlate.toLowerCase().contains(keyword) ||
              vehicle.ownerName.toLowerCase().contains(keyword) ||
              vehicle.roomNumber.toLowerCase().contains(keyword) ||
              vehicle.category.toLowerCase().contains(keyword) ||
              vehicle.brand.toLowerCase().contains(keyword) ||
              vehicle.model.toLowerCase().contains(keyword) ||
              vehicle.color.toLowerCase().contains(keyword);
        }).toList();
      }
    });
  }

  Future<void> _goToAddVehicleScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddVehicleScreen(),
      ),
    );

    if (result == true) {
      await _loadVehicles();
    }
  }

  Future<void> _goToVehicleDetail(Vehicle vehicle) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VehicleDetailScreen(vehicle: vehicle),
      ),
    );

    if (result == true) {
      await _loadVehicles();
    }
  }

  Future<void> _deleteVehicle(String id) async {
    await DatabaseHelper.instance.deleteVehicle(id);
    await _loadVehicles();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa xe'),
      ),
    );
  }

  void _showDeleteDialog(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa xe'),
          content: Text(
            'Bạn có chắc muốn xóa xe biển số ${vehicle.licensePlate} không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteVehicle(vehicle.id);
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterVehicles);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý xe'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _filteredVehicles.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        onRefresh: _loadVehicles,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _filteredVehicles.length,
                          itemBuilder: (context, index) {
                            final vehicle = _filteredVehicles[index];
                            return _buildVehicleCard(vehicle);
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _goToAddVehicleScreen,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Tìm theo biển số, chủ xe, số phòng, hãng xe...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    _searchController.clear();
                  },
                  icon: const Icon(Icons.clear),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: vehicle.imageUrl.isNotEmpty
              ? FileImage(File(vehicle.imageUrl))
              : null,
          child: vehicle.imageUrl.isEmpty
              ? const Icon(Icons.motorcycle)
              : null,
        ),
        title: Text(
          vehicle.licensePlate,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Chủ xe: ${vehicle.ownerName}'),
              Text('Phòng: ${vehicle.roomNumber}'),
              Text('Xe: ${vehicle.brand} ${vehicle.model}'),
              Text('Loại xe: ${vehicle.category} - Màu: ${vehicle.color}'),
            ],
          ),
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'view') {
              _goToVehicleDetail(vehicle);
            } else if (value == 'delete') {
              _showDeleteDialog(vehicle);
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem<String>(
              value: 'view',
              child: Text('Xem chi tiết'),
            ),
            PopupMenuItem<String>(
              value: 'delete',
              child: Text('Xóa'),
            ),
          ],
        ),
        onTap: () => _goToVehicleDetail(vehicle),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bike_outlined,
            size: 80,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'Chưa có dữ liệu xe',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Bấm nút + để thêm xe vào cơ sở dữ liệu',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}