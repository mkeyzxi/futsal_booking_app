// lib/services/field_service.dart
import 'package:futsal_booking_app/models/field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:uuid/uuid.dart';

class FieldService {
  final Uuid _uuid = const Uuid();
  static const String _fieldsKey = 'app_fields';

  Future<List<Field>> _loadFields() async {
    final prefs = await SharedPreferences.getInstance();
    final String? fieldsJson = prefs.getString(_fieldsKey);
    if (fieldsJson != null) {
      Iterable decoded = jsonDecode(fieldsJson);
      return decoded.map((model) => Field.fromJson(model)).toList();
    }
    // Jika belum ada data, inisialisasi dengan data dummy
    return _initialFields();
  }

  Future<void> _saveFields(List<Field> fields) async {
    final prefs = await SharedPreferences.getInstance();
    String encoded = jsonEncode(fields.map((f) => f.toJson()).toList());
    await prefs.setString(_fieldsKey, encoded);
  }

  List<Field> _initialFields() {
    return [
      Field(
        id: _uuid.v4(),
        name: 'Lapangan 1',
        type: 'Rumput Sintetis',
        description:
            'Lapangan modern dengan rumput sintetis berkualitas tinggi, cocok untuk pertandingan santai.',
        pricePerHour: 75000,
        imageUrl:
            'https://via.placeholder.com/150/42A5F5/FFFFFF?text=Lapangan+1', // Placeholder image
      ),
      Field(
        id: _uuid.v4(),
        name: 'Lapangan 2',
        type: 'Karpet Vinyl',
        description:
            'Permukaan karpet vinyl yang nyaman dan aman, ideal untuk segala jenis pemain.',
        pricePerHour: 60000,
        imageUrl:
            'https://via.placeholder.com/150/FFC107/FFFFFF?text=Lapangan+2', // Placeholder image
      ),
      Field(
        id: _uuid.v4(),
        name: 'Lapangan 3',
        type: 'Profesional',
        description:
            'Lapangan standar profesional dengan fasilitas lengkap, cocok untuk turnamen dan latihan intensif.',
        pricePerHour: 100000,
        imageUrl:
            'https://via.placeholder.com/150/66BB6A/FFFFFF?text=Lapangan+3', // Placeholder image
      ),
    ];
  }

  Future<List<Field>> getFields() async {
    List<Field> fields = await _loadFields();
    // Pastikan dummy data disimpan jika ini adalah pertama kali dimuat
    if (fields.isEmpty) {
      fields = _initialFields();
      await _saveFields(fields);
    }
    return fields;
  }

  Future<Field?> getFieldById(String id) async {
    List<Field> fields = await _loadFields();
    try {
      return fields.firstWhere((field) => field.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> addField(Field field) async {
    List<Field> fields = await _loadFields();
    fields.add(
      Field(
        id: _uuid.v4(),
        name: field.name,
        type: field.type,
        description: field.description,
        pricePerHour: field.pricePerHour,
        imageUrl: field.imageUrl,
      ),
    );
    await _saveFields(fields);
  }

  Future<void> updateField(Field updatedField) async {
    List<Field> fields = await _loadFields();
    int index = fields.indexWhere((f) => f.id == updatedField.id);
    if (index != -1) {
      fields[index] = updatedField;
      await _saveFields(fields);
    }
  }

  Future<void> deleteField(String id) async {
    List<Field> fields = await _loadFields();
    fields.removeWhere((f) => f.id == id);
    await _saveFields(fields);
  }
}
