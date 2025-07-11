// lib/providers/field_provider.dart
import 'package:flutter/material.dart';
import 'package:futsal_booking_app/models/field.dart';
import 'package:futsal_booking_app/services/field_service.dart';

class FieldProvider with ChangeNotifier {
  List<Field> _fields = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Field> get fields => _fields;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final FieldService _fieldService = FieldService();

  FieldProvider() {
    fetchFields(); // Muat data saat provider diinisialisasi
  }

  Future<void> fetchFields() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _fields = await _fieldService.getFields();
    } catch (e) {
      _errorMessage = 'Gagal memuat daftar lapangan: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addField(Field field) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _fieldService.addField(field);
      await fetchFields(); // Refresh list after adding
    } catch (e) {
      _errorMessage = 'Gagal menambah lapangan: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateField(Field field) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _fieldService.updateField(field);
      await fetchFields(); // Refresh list after updating
    } catch (e) {
      _errorMessage = 'Gagal memperbarui lapangan: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteField(String fieldId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _fieldService.deleteField(fieldId);
      await fetchFields(); // Refresh list after deleting
    } catch (e) {
      _errorMessage = 'Gagal menghapus lapangan: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
