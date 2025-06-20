// lib/views/user/user_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:futsal_booking_app/providers/auth_provider.dart';
import 'package:futsal_booking_app/views/auth/login_screen.dart';
import 'package:futsal_booking_app/views/user/field_list_screen.dart';
import 'package:futsal_booking_app/views/user/booking_history_screen.dart';
import 'package:futsal_booking_app/views/user/profile_screen.dart';
import 'package:futsal_booking_app/utils/app_styles.dart';
import 'dart:io';

class UserDashboardScreen extends StatelessWidget {
  const UserDashboardScreen({super.key});

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
      backgroundColor: AppStyles.backgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard Pengguna'),
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
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Consumer<AuthProvider>(
              builder: (context, auth, child) {
                return UserAccountsDrawerHeader(
                  accountName: Text(
                    auth.currentUser?.username ?? 'Pengguna',
                    style: AppStyles.subHeadingStyle.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  accountEmail: Column(
                    // Menggunakan Column untuk email dan saldo
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.currentUser?.email ?? '',
                        style: AppStyles.smallTextStyle.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Saldo: Rp ${auth.userBalance.toInt()}', // Menampilkan saldo user
                        style: AppStyles.smallTextStyle.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  currentAccountPicture: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage:
                          auth.currentUser?.profileImageUrl != null
                              ? (auth.currentUser!.profileImageUrl!.startsWith(
                                    'http',
                                  )
                                  ? NetworkImage(
                                    auth.currentUser!.profileImageUrl!,
                                  )
                                  : FileImage(
                                        File(
                                          auth.currentUser!.profileImageUrl!,
                                        ),
                                      )
                                      as ImageProvider)
                              : null,
                      child:
                          auth.currentUser?.profileImageUrl == null
                              ? const Icon(
                                Icons.person,
                                size: 50,
                                color: AppStyles.primaryColor,
                              )
                              : null,
                    ),
                  ),
                  decoration: const BoxDecoration(
                    color: AppStyles.primaryColor,
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.sports_soccer,
                color: AppStyles.primaryColor,
              ),
              title: Text('Daftar Lapangan', style: AppStyles.bodyTextStyle),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const FieldListScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: AppStyles.primaryColor),
              title: Text('Riwayat Booking', style: AppStyles.bodyTextStyle),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BookingHistoryScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.person, color: AppStyles.primaryColor),
              title: Text('Profil Saya', style: AppStyles.bodyTextStyle),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: AppStyles.errorColor),
              title: Text('Logout', style: AppStyles.bodyTextStyle),
              onTap: () async {
                await authProvider.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppStyles.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Halo, ${authProvider.currentUser?.username ?? 'Pengguna'}!',
              style: AppStyles.headingStyle,
            ),
            const SizedBox(height: 10),
            Text(
              'Selamat datang di aplikasi booking lapangan futsal.',
              style: AppStyles.bodyTextStyle.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppStyles.defaultPadding,
                mainAxisSpacing: AppStyles.defaultPadding,
                children: [
                  _buildDashboardCard(
                    context,
                    icon: Icons.sports_soccer,
                    title: 'Booking Lapangan',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const FieldListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.history,
                    title: 'Riwayat Booking',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const BookingHistoryScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.person,
                    title: 'Profil Saya',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    icon: Icons.help_outline,
                    title: 'Bantuan',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fitur bantuan akan segera hadir!'),
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

  Widget _buildDashboardCard(
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
              Icon(icon, size: 50, color: AppStyles.primaryColor),
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
