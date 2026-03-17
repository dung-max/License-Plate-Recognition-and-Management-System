import 'package:flutter/material.dart';
import 'package:vehicle_manager/database/database_helper.dart';
import 'package:vehicle_manager/vehicle_models/vehicle.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _licensePlateController = TextEditingController();
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _roomNumberController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();

  String _selectedCategory = 'Xe số';
  bool _isSaving = false;

  // Để lưu đường dẫn ảnh
  File? _imageFile;

  final List<String> _categories = [
    'Xe số',
    'Xe ga',
    'Xe côn tay',
    'Xe điện',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveVehicle() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final vehicle = Vehicle(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      licensePlate: _licensePlateController.text.trim().toUpperCase(),
      ownerName: _ownerNameController.text.trim(),
      roomNumber: _roomNumberController.text.trim(),
      category: _selectedCategory,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      color: _colorController.text.trim(),
      imageUrl: _imageFile?.path ?? '',  // Lưu đường dẫn ảnh vào imageUrl
    );

    try {
      final existedVehicle = await DatabaseHelper.instance
          .getVehicleByLicensePlate(vehicle.licensePlate);

      if (existedVehicle != null) {
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

      await DatabaseHelper.instance.insertVehicle(vehicle);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Thêm xe thành công'),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi khi thêm xe: $e'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thêm xe mới'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Nút chọn ảnh
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : null,
                  child: _imageFile == null
                      ? const Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.grey,
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 20),
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
                  onPressed: _isSaving ? null : _saveVehicle,
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : const Text('Lưu xe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
}