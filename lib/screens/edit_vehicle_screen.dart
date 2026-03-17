import 'package:flutter/material.dart';
import 'package:vehicle_manager/database/database_helper.dart';
import 'package:vehicle_manager/vehicle_models/vehicle.dart';

class EditVehicleScreen extends StatefulWidget {
  final Vehicle vehicle;

  const EditVehicleScreen({
    super.key,
    required this.vehicle,
  });

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _licensePlateController;
  late TextEditingController _ownerNameController;
  late TextEditingController _roomNumberController;
  late TextEditingController _brandController;
  late TextEditingController _modelController;
  late TextEditingController _colorController;

  late String _selectedCategory;
  bool _isSaving = false;

  final List<String> _categories = [
    'Xe số',
    'Xe ga',
    'Xe côn tay',
    'Xe điện',
  ];

  @override
  void initState() {
    super.initState();
    _licensePlateController =
        TextEditingController(text: widget.vehicle.licensePlate);
    _ownerNameController =
        TextEditingController(text: widget.vehicle.ownerName);
    _roomNumberController =
        TextEditingController(text: widget.vehicle.roomNumber);
    _brandController = TextEditingController(text: widget.vehicle.brand);
    _modelController = TextEditingController(text: widget.vehicle.model);
    _colorController = TextEditingController(text: widget.vehicle.color);
    _selectedCategory = widget.vehicle.category;
  }

  Future<void> _updateVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final updatedVehicle = Vehicle(
      id: widget.vehicle.id,
      licensePlate: _licensePlateController.text.trim().toUpperCase(),
      ownerName: _ownerNameController.text.trim(),
      roomNumber: _roomNumberController.text.trim(),
      category: _selectedCategory,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      color: _colorController.text.trim(),
      imageUrl: widget.vehicle.imageUrl,
    );

    try {
      final existedVehicle = await DatabaseHelper.instance
          .getVehicleByLicensePlate(updatedVehicle.licensePlate);

      if (existedVehicle != null && existedVehicle.id != widget.vehicle.id) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Biển số xe đã tồn tại'),
          ),
        );
        setState(() {
          _isSaving = false;
        });
        return;
      }

      await DatabaseHelper.instance.updateVehicle(updatedVehicle);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cập nhật xe thành công'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi cập nhật xe: $e'),
        ),
      );
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  void dispose() {
    _licensePlateController.dispose();
    _ownerNameController.dispose();
    _roomNumberController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sửa thông tin xe'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                controller: _licensePlateController,
                label: 'Biển số xe',
                hint: 'Ví dụ: 59A1-12345',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập biển số xe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _ownerNameController,
                label: 'Tên chủ xe',
                hint: 'Ví dụ: Nguyễn Văn A',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên chủ xe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _roomNumberController,
                label: 'Số phòng',
                hint: 'Ví dụ: P101',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập số phòng';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Loại xe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                items: _categories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _brandController,
                label: 'Hãng xe',
                hint: 'Ví dụ: Honda',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập hãng xe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _modelController,
                label: 'Dòng xe',
                hint: 'Ví dụ: Vision',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập dòng xe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _colorController,
                label: 'Màu xe',
                hint: 'Ví dụ: Đen',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập màu xe';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _updateVehicle,
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : const Text('Cập nhật xe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}