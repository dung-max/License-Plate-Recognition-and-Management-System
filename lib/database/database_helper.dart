import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:vehicle_manager/vehicle_models/vehicle.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'vehicle_manager.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE vehicles (
        id TEXT PRIMARY KEY,
        license_plate TEXT NOT NULL UNIQUE,
        owner_name TEXT NOT NULL,
        room_number TEXT NOT NULL,
        category TEXT NOT NULL,
        brand TEXT NOT NULL,
        model TEXT NOT NULL,
        color TEXT NOT NULL,
        image_url TEXT
      )
    ''');
  }

  Future<int> insertVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.insert(
      'vehicles',
      vehicle.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Vehicle>> getAllVehicles() async {
    final db = await database;
    final maps = await db.query(
      'vehicles',
      orderBy: 'owner_name ASC',
    );

    return maps.map((map) => Vehicle.fromMap(map)).toList();
  }

  Future<Vehicle?> getVehicleById(String id) async {
    final db = await database;
    final maps = await db.query(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Vehicle.fromMap(maps.first);
    }
    return null;
  }

  Future<Vehicle?> getVehicleByLicensePlate(String licensePlate) async {
    final db = await database;
    final normalizedPlate = normalizePlate(licensePlate);

    final maps = await db.query(
      'vehicles',
      where: 'REPLACE(UPPER(license_plate), " ", "") = ?',
      whereArgs: [normalizedPlate],
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return Vehicle.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Vehicle>> searchVehicles(String keyword) async {
    final db = await database;
    final searchValue = '%${keyword.trim()}%';

    final maps = await db.query(
      'vehicles',
      where: '''
        license_plate LIKE ? OR
        owner_name LIKE ? OR
        room_number LIKE ? OR
        category LIKE ? OR
        brand LIKE ? OR
        model LIKE ? OR
        color LIKE ?
      ''',
      whereArgs: [
        searchValue,
        searchValue,
        searchValue,
        searchValue,
        searchValue,
        searchValue,
        searchValue,
      ],
      orderBy: 'owner_name ASC',
    );

    return maps.map((map) => Vehicle.fromMap(map)).toList();
  }

  Future<int> updateVehicle(Vehicle vehicle) async {
    final db = await database;
    return await db.update(
      'vehicles',
      vehicle.toMap(),
      where: 'id = ?',
      whereArgs: [vehicle.id],
    );
  }

  Future<int> deleteVehicle(String id) async {
    final db = await database;
    return await db.delete(
      'vehicles',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  String normalizePlate(String plate) {
    return plate.replaceAll(' ', '').toUpperCase();
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}