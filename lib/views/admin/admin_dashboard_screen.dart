// lib/views/admin/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:futsal_booking_app/providers/auth_provider.dart';
import 'package:futsal_booking_app/views/auth/login_screen.dart';
import 'package:futsal_booking_app/views/admin/admin_booking_management_screen.dart';
import 'package:futsal_booking_app/views/admin/admin_schedule_management_screen.dart';
import 'package:futsal_booking_app/views/admin/admin_field_management_screen.dart';
import 'package:futsal_booking_app/utils/app_styles.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (Route<dynamic> route) => false,
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor:
          AppStyles.backgroundColor, // Menambahkan background color
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo Admin, ${authProvider.currentUser?.username ?? ''}!',
              style: AppStyles.headingStyle,
            ),
            const SizedBox(height: 10),
            Text(
              'Kelola sistem booking lapangan futsal Anda.',
              style: AppStyles.bodyTextStyle.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing:
                    AppStyles.defaultPadding, // Baris ini saja yang dibutuhkan
                mainAxisSpacing: AppStyles.defaultPadding,
                children: [
                  _buildAdminDashboardCard(
                    context,
                    icon: Icons.calendar_today,
                    title: 'Manajemen Jadwal',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AdminScheduleManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAdminDashboardCard(
                    context,
                    icon: Icons.book_online,
                    title: 'Manajemen Booking',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AdminBookingManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAdminDashboardCard(
                    context,
                    icon: Icons.sports_score,
                    title: 'Manajemen Lapangan',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AdminFieldManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _buildAdminDashboardCard(
                    context,
                    icon: Icons.settings,
                    title: 'Pengaturan',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur pengaturan akan segera hadir!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminDashboardCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.defaultBorderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppStyles.defaultBorderRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppStyles.defaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: AppStyles.secondaryColor),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppStyles.subHeadingStyle.copyWith(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
