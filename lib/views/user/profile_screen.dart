// lib/views/user/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:futsal_booking_app/providers/auth_provider.dart';
import 'package:futsal_booking_app/utils/app_styles.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:futsal_booking_app/views/common_widgets/custom_button.dart';
import 'package:futsal_booking_app/views/auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      await authProvider.updateProfileImage(_imageFile!.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Foto profil berhasil diperbarui!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser;

    if (authProvider.isLoading) {
      // Tampilkan loading state
      return Scaffold(
        appBar: AppBar(title: const Text('Profil Saya')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profil Saya')),
        body: const Center(
          child: Text('User tidak ditemukan atau belum login.'),
        ),
      );
    }

    // Periksa apakah imageUrl adalah path lokal atau URL jaringan
    ImageProvider? profileImage;
    if (user.profileImageUrl != null) {
      if (user.profileImageUrl!.startsWith('http')) {
        profileImage = NetworkImage(user.profileImageUrl!);
      } else if (File(user.profileImageUrl!).existsSync()) {
        // Pastikan file ada
        profileImage = FileImage(File(user.profileImageUrl!));
      }
    }

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(title: const Text('Profil Saya')),
      body: Padding(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundColor: AppStyles.primaryColor,
                  backgroundImage: profileImage,
                  child:
                      profileImage == null
                          ? const Icon(
                            Icons.person,
                            size: 80,
                            color: Colors.white,
                          )
                          : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppStyles.secondaryColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(user.username, style: AppStyles.headingStyle),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: AppStyles.bodyTextStyle.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppStyles.defaultBorderRadius,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppStyles.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileInfoRow(
                      Icons.person,
                      'Username',
                      user.username,
                    ),
                    const Divider(),
                    _buildProfileInfoRow(Icons.email, 'Email', user.email),
                    const Divider(),
                    _buildProfileInfoRow(
                      Icons.account_balance_wallet,
                      'Saldo',
                      'Rp ${user.balance.toInt()}',
                    ), // Menampilkan saldo
                    const Divider(),
                    _buildProfileInfoRow(
                      Icons.shield,
                      'Role',
                      user.role.toString().split('.').last.toUpperCase(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: 'Logout',
              onPressed: () async {
                await authProvider.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              buttonColor: AppStyles.errorColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppStyles.primaryColor),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppStyles.smallTextStyle.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: AppStyles.bodyTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
