// lib/services/field_service.dart
import 'package:futsal_booking_app/models/field.dart';
import 'package:uuid/uuid.dart';
import 'package:futsal_booking_app/utils/database_helper.dart'; // Import DatabaseHelper
import 'package:sqflite/sqflite.dart'; // Import untuk ConflictAlgorithm

class FieldService {
  final Uuid _uuid = const Uuid();
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<List<Field>> getFields() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('fields');
    return List.generate(maps.length, (i) {
      return Field.fromSqliteMap(maps[i]);
    });
  }

  Future<Field?> getFieldById(String id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'fields',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return Field.fromSqliteMap(maps.first);
    }
    return null;
  }

  Future<void> addField(Field field) async {
    final db = await _dbHelper.database;
    // Pastikan ID digenerate jika belum ada (opsional jika model sudah handle)
    final fieldToInsert = Field(
      id: _uuid.v4(),
      name: field.name,
      type: field.type,
      description: field.description,
      pricePerHour: field.pricePerHour,
      imageUrl: field.imageUrl,
    );
    await db.insert(
      'fields',
      fieldToInsert.toSqliteMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateField(Field updatedField) async {
    final db = await _dbHelper.database;
    await db.update(
      'fields',
      updatedField.toSqliteMap(),
      where: 'id = ?',
      whereArgs: [updatedField.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteField(String id) async {
    final db = await _dbHelper.database;
    await db.delete('fields', where: 'id = ?', whereArgs: [id]);
    // Hapus juga booking terkait jika ingin (diperlukan ON DELETE CASCADE di SQL)
    await db.delete('bookings', where: 'fieldId = ?', whereArgs: [id]);
  }
}
