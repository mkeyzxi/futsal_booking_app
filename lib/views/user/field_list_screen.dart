// lib/views/user/field_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:futsal_booking_app/providers/field_provider.dart';
import 'package:futsal_booking_app/models/field.dart';
import 'package:futsal_booking_app/views/user/field_detail_screen.dart';
import 'package:futsal_booking_app/utils/app_styles.dart';

class FieldListScreen extends StatefulWidget {
  const FieldListScreen({super.key});

  @override
  State<FieldListScreen> createState() => _FieldListScreenState();
}

class _FieldListScreenState extends State<FieldListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FieldProvider>(context, listen: false).fetchFields();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(title: const Text('Daftar Lapangan')),
      body: Consumer<FieldProvider>(
        builder: (context, fieldProvider, child) {
          if (fieldProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (fieldProvider.errorMessage != null) {
            return Center(child: Text(fieldProvider.errorMessage!));
          }
          if (fieldProvider.fields.isEmpty) {
            return const Center(
              child: Text('Belum ada lapangan yang terdaftar.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppStyles.defaultPadding),
            itemCount: fieldProvider.fields.length,
            itemBuilder: (context, index) {
              final field = fieldProvider.fields[index];
              return _buildFieldCard(context, field);
            },
          );
        },
      ),
    );
  }

  Widget _buildFieldCard(BuildContext context, Field field) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppStyles.defaultPadding),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.defaultBorderRadius),
      ),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => FieldDetailScreen(field: field)),
          );
        },
        borderRadius: BorderRadius.circular(AppStyles.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (field.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                    AppStyles.defaultBorderRadius,
                  ),
                  child: Image.asset(
                    // Menggunakan Image.asset karena path lokal
                    field.imageUrl!,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: 150,
                          color: Colors.grey[300],
                          child: const Center(
                            child: Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(
                field.name,
                style: AppStyles.subHeadingStyle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 8),
              Text(
                field.type,
                style: AppStyles.bodyTextStyle.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                field.description,
                style: AppStyles.smallTextStyle.copyWith(
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  'Rp ${field.pricePerHour.toInt()}/jam',
                  style: AppStyles.subHeadingStyle.copyWith(
                    color: AppStyles.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
