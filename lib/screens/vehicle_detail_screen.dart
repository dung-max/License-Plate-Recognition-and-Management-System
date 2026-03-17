import 'package:flutter/material.dart';
import 'package:vehicle_manager/database/database_helper.dart';
import 'package:vehicle_manager/screens/edit_vehicle_screen.dart';
import 'package:vehicle_manager/vehicle_models/vehicle.dart';
import 'dart:io'; 

class VehicleDetailScreen extends StatefulWidget {
  final Vehicle vehicle;

  const VehicleDetailScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  late Vehicle _vehicle;

  @override
  void initState() {
    super.initState();
    _vehicle = widget.vehicle;
  }

  Future<void> _goToEditVehicleScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditVehicleScreen(vehicle: _vehicle),
      ),
    );

    if (result == true) {
      final updatedVehicle =
          await DatabaseHelper.instance.getVehicleById(_vehicle.id);

      if (updatedVehicle != null && mounted) {
        setState(() {
          _vehicle = updatedVehicle;
        });
      }
    }
  }

  Future<void> _deleteVehicle() async {
    await DatabaseHelper.instance.deleteVehicle(_vehicle.id);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Đã xóa xe'),
      ),
    );

    Navigator.pop(context, true);
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Xóa xe'),
          content: Text(
            'Bạn có chắc muốn xóa xe biển số ${_vehicle.licensePlate} không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _deleteVehicle();
              },
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style.copyWith(fontSize: 16),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vehicleName = '${_vehicle.brand} ${_vehicle.model}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết xe'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _goToEditVehicleScreen,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: _showDeleteDialog,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Thay NetworkImage bằng FileImage để hiển thị ảnh từ thư viện
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: _vehicle.imageUrl.isNotEmpty
                  ? FileImage(File(_vehicle.imageUrl))
                  : null,
              child: _vehicle.imageUrl.isEmpty
                  ? const Icon(Icons.motorcycle, size: 42)
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              _vehicle.licensePlate,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildInfoRow('Chủ xe', _vehicle.ownerName),
            _buildInfoRow('Số phòng', _vehicle.roomNumber),
            _buildInfoRow('Loại xe', _vehicle.category),
            _buildInfoRow('Hãng xe', _vehicle.brand),
            _buildInfoRow('Dòng xe', _vehicle.model),
            _buildInfoRow('Tên xe', vehicleName),
            _buildInfoRow('Màu xe', _vehicle.color),
          ],
        ),
      ),
    );
  }
}