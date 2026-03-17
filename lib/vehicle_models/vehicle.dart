class Vehicle {
  final String id;
  final String licensePlate;
  final String ownerName;
  final String roomNumber;
  final String category;
  final String brand;
  final String model;
  final String color;
  final String imageUrl;

  Vehicle({
    required this.id,
    required this.licensePlate,
    required this.ownerName,
    required this.roomNumber,
    required this.category,
    required this.brand,
    required this.model,
    required this.color,
    required this.imageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'license_plate': licensePlate,
      'owner_name': ownerName,
      'room_number': roomNumber,
      'category': category,
      'brand': brand,
      'model': model,
      'color': color,
      'image_url': imageUrl,
    };
  }

  factory Vehicle.fromMap(Map<String, dynamic> map) {
    return Vehicle(
      id: map['id'] as String,
      licensePlate: map['license_plate'] as String,
      ownerName: map['owner_name'] as String,
      roomNumber: map['room_number'] as String,
      category: map['category'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      color: map['color'] as String,
      imageUrl: (map['image_url'] ?? '') as String,
    );
  }
}