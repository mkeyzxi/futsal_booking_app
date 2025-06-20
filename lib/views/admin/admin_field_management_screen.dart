// lib/views/admin/admin_field_management_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:futsal_booking_app/providers/field_provider.dart';
import 'package:futsal_booking_app/models/field.dart';
import 'package:futsal_booking_app/utils/app_styles.dart';
import 'package:futsal_booking_app/views/common_widgets/custom_text_field.dart';
import 'package:futsal_booking_app/views/common_widgets/custom_button.dart';

class AdminFieldManagementScreen extends StatefulWidget {
  const AdminFieldManagementScreen({super.key});

  @override
  State<AdminFieldManagementScreen> createState() =>
      _AdminFieldManagementScreenState();
}

class _AdminFieldManagementScreenState
    extends State<AdminFieldManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FieldProvider>(context, listen: false).fetchFields();
    });
  }

  void _showFieldForm({Field? field}) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: field?.name);
    final _typeController = TextEditingController(text: field?.type);
    final _descriptionController = TextEditingController(
      text: field?.description,
    );
    final _priceController = TextEditingController(
      text: field?.pricePerHour.toString(),
    );
    final _imageUrlController = TextEditingController(text: field?.imageUrl);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: AppStyles.defaultPadding,
            right: AppStyles.defaultPadding,
            top: AppStyles.defaultPadding,
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    field == null ? 'Tambah Lapangan Baru' : 'Edit Lapangan',
                    style: AppStyles.headingStyle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Nama Lapangan',
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Nama lapangan tidak boleh kosong'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _typeController,
                    hintText: 'Jenis Lapangan (misal: Rumput Sintetis)',
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Jenis lapangan tidak boleh kosong'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _descriptionController,
                    hintText: 'Deskripsi Lapangan',
                    maxLines: 3,
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Deskripsi tidak boleh kosong'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _priceController,
                    hintText: 'Harga per Jam (Rp)',
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value!.isEmpty) return 'Harga tidak boleh kosong';
                      if (double.tryParse(value) == null)
                        return 'Harga harus angka';
                      if (double.parse(value) <= 0)
                        return 'Harga harus lebih dari 0';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _imageUrlController,
                    hintText: 'URL Gambar Lapangan (opsional)',
                  ),
                  const SizedBox(height: 24),
                  Consumer<FieldProvider>(
                    builder: (context, fieldProvider, child) {
                      return CustomButton(
                        text:
                            field == null
                                ? 'Simpan Lapangan'
                                : 'Update Lapangan',
                        isLoading: fieldProvider.isLoading,
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            final newField = Field(
                              id:
                                  field?.id ??
                                  '', // Gunakan ID lama jika edit, atau kosong jika tambah baru
                              name: _nameController.text.trim(),
                              type: _typeController.text.trim(),
                              description: _descriptionController.text.trim(),
                              pricePerHour: double.parse(_priceController.text),
                              imageUrl:
                                  _imageUrlController.text.trim().isEmpty
                                      ? null
                                      : _imageUrlController.text.trim(),
                            );

                            if (field == null) {
                              await fieldProvider.addField(newField);
                            } else {
                              await fieldProvider.updateField(newField);
                            }

                            if (fieldProvider.errorMessage == null) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    field == null
                                        ? 'Lapangan berhasil ditambahkan!'
                                        : 'Lapangan berhasil diperbarui!',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(fieldProvider.errorMessage!),
                                ),
                              );
                            }
                          }
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteField(BuildContext context, Field field) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Lapangan?'),
          content: Text('Anda yakin ingin menghapus lapangan "${field.name}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            Consumer<FieldProvider>(
              builder: (context, fieldProvider, child) {
                return TextButton(
                  onPressed:
                      fieldProvider.isLoading
                          ? null
                          : () async {
                            Navigator.pop(context);
                            await fieldProvider.deleteField(field.id);
                            if (fieldProvider.errorMessage == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Lapangan berhasil dihapus!'),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(fieldProvider.errorMessage!),
                                ),
                              );
                            }
                          },
                  child:
                      fieldProvider.isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Text(
                            'Hapus',
                            style: TextStyle(color: AppStyles.errorColor),
                          ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(title: const Text('Manajemen Lapangan')),
      body: Consumer<FieldProvider>(
        builder: (context, fieldProvider, child) {
          if (fieldProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (fieldProvider.errorMessage != null) {
            return Center(child: Text(fieldProvider.errorMessage!));
          }
          if (fieldProvider.fields.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sports_score, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  Text(
                    'Belum ada lapangan yang terdaftar.',
                    style: AppStyles.bodyTextStyle.copyWith(
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Tambahkan lapangan baru untuk mulai.',
                    style: AppStyles.smallTextStyle.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            itemCount: fieldProvider.fields.length,
            itemBuilder: (context, index) {
              final field = fieldProvider.fields[index];
              return Card(
                margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppStyles.defaultBorderRadius,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(
                    AppStyles.defaultPadding,
                  ),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppStyles.defaultBorderRadius,
                    ),
                    child: Image.network(
                      field.imageUrl ?? 'https://via.placeholder.com/50',
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.broken_image,
                              color: Colors.grey,
                            ),
                          ),
                    ),
                  ),
                  title: Text(
                    field.name,
                    style: AppStyles.subHeadingStyle.copyWith(fontSize: 16),
                  ),
                  subtitle: Text(
                    '${field.type}\nRp ${field.pricePerHour.toInt()}/jam',
                    style: AppStyles.smallTextStyle,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.edit,
                          color: AppStyles.primaryColor,
                        ),
                        onPressed: () => _showFieldForm(field: field),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: AppStyles.errorColor,
                        ),
                        onPressed: () => _confirmDeleteField(context, field),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFieldForm(),
        backgroundColor: AppStyles.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
