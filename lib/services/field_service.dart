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
    // PENTING: Gunakan asset lokal di sini
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
        name: 'Lapangan Vinyl', // Sesuai dengan nama gambar
        type: 'Karpet Vinyl', // Sesuai dengan jenis lapangan
        description:
            'Lapangan futsal modern dengan permukaan vinyl berkualitas tinggi, ideal untuk permainan cepat dan meminimalkan cedera.',
        pricePerHour: 120000,
        imageUrl: 'assets/images/futsal_field_vinyl.png', // <-- Path aset lokal
      ),
      Field(
        id: _uuid.v4(),
        name: 'Lapangan Sintetis', // Sesuai dengan nama gambar
        type: 'Rumput Sintetis', // Sesuai dengan jenis lapangan
        description:
            'Lapangan dengan rumput sintetis yang menyerupai asli, memberikan pengalaman bermain yang nyaman dan realistis.',
        pricePerHour: 150000,
        imageUrl:
            'assets/images/futsal_field_synthetic.png', // <-- Path aset lokal
      ),
      Field(
        id: _uuid.v4(),
        name: 'Lapangan Standar', // Sesuai dengan nama gambar
        type: 'Standar Umum', // Sesuai dengan jenis lapangan
        description:
            'Lapangan futsal standar dengan harga terjangkau, cocok untuk bermain santai bersama teman-teman.',
        pricePerHour: 100000,
        imageUrl:
            'assets/images/futsal_field_standard.png', // <-- Path aset lokal
      ),
      // Tambahan 1 lapangan baru
      Field(
        id: _uuid.v4(),
        name: 'Lapangan Premier',
        type: 'Indoor Sport',
        description:
            'Lapangan indoor serbaguna dengan pencahayaan optimal dan sistem pendingin udara, cocok untuk berbagai aktivitas olahraga.',
        pricePerHour: 180000,
        imageUrl:
            'assets/images/futsal_field_synthetic.png', // Bisa pakai gambar yang sudah ada atau tambahkan baru
      ),
    ];
  }

  Future<List<Field>> getFields() async {
    List<Field> fields = await _loadFields();
    // Pastikan dummy data disimpan jika ini adalah pertama kali dimuat
    if (fields.isEmpty) {
      // Perlu dicek isian, bukan hanya null
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
