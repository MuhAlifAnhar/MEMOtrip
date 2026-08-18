import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/enums/user_role.dart';
import '../../../../core/providers/auth_provider.dart';

class UsersManagementPage extends ConsumerStatefulWidget {
  const UsersManagementPage({super.key});

  @override
  ConsumerState<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends ConsumerState<UsersManagementPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animCtrl;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _changeRole(String userId, String userName, UserRole currentRole, UserRole newRole) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusCard),
        title: Text('Ubah Role Pengguna', style: AppTypography.headlineSmall),
        content: Text(
          'Apakah Anda yakin ingin mengubah role $userName menjadi ${newRole.label}?',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMedium),
            ),
            child: const Text('Ya, Ubah'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'role': newRole.toFirestore(),
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Role $userName berhasil diubah menjadi ${newRole.label}'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal mengubah role: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteUser(String userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusCard),
        title: Text('Hapus Pengguna', style: AppTypography.headlineSmall),
        content: Text(
          'Apakah Anda yakin ingin menghapus pengguna $userName? Tindakan ini tidak dapat dibatalkan.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Batal', style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMedium),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance.collection('users').doc(userId).delete();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Pengguna $userName berhasil dihapus'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menghapus pengguna: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(authUserProvider).value;

    return Container(
      decoration: const BoxDecoration(gradient: AppColors.backgroundGradientDeep),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header & Search
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kelola User', style: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimary)),
                const SizedBox(height: AppSpacing.md),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: AppSpacing.borderRadiusMedium,
                    border: Border.all(color: Colors.grey.shade300, width: 1),
                  ),
                  child: TextField(
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'Cari berdasarkan nama atau email...',
                      hintStyle: AppTypography.bodyMedium.copyWith(color: Colors.grey.shade600),
                      prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade700),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val.toLowerCase()),
                  ),
                ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Terjadi kesalahan: ${snapshot.error}',
                        style: const TextStyle(color: Colors.white)),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                final docs = snapshot.data?.docs ?? [];
                
                final filteredDocs = docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final name = (data['name'] as String?)?.toLowerCase() ?? '';
                  final email = (data['email'] as String?)?.toLowerCase() ?? '';
                  if (_searchQuery.isEmpty) return true;
                  return name.contains(_searchQuery) || email.contains(_searchQuery);
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                      child: Text(
                        'Total: ${filteredDocs.length} Pengguna',
                        style: AppTypography.labelMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final userId = doc.id;
                          final name = data['name'] ?? 'Traveler';
                          final email = data['email'] ?? 'No Email';
                          final roleStr = data['role'] as String?;
                          final role = UserRole.fromFirestore(roleStr);
                          
                          final isMe = currentUser?.uid == userId;
                          
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: 300 + (index * 50).clamp(0, 500)),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, child) {
                              return Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: Opacity(opacity: value, child: child),
                              );
                            },
                            child: Card(
                              margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                              color: AppColors.cardBackground,
                              shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusCard),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                                leading: CircleAvatar(
                                  backgroundColor: AppColors.primarySurface,
                                  child: Text(
                                    name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
                                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: AppTypography.titleMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: role == UserRole.superAdmin 
                                            ? Colors.amber.shade700 
                                            : (role == UserRole.admin ? AppColors.primary : Colors.grey.shade600),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        role.label,
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Text(email, style: AppTypography.bodySmall),
                                trailing: isMe || role == UserRole.superAdmin
                                    ? const SizedBox(width: 48) // placeholder to align properly if not changing role
                                    : PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                                        onSelected: (action) {
                                          if (action == 'make_user' && role != UserRole.user) {
                                            _changeRole(userId, name, role, UserRole.user);
                                          } else if (action == 'make_admin' && role != UserRole.admin) {
                                            _changeRole(userId, name, role, UserRole.admin);
                                          } else if (action == 'delete') {
                                            _deleteUser(userId, name);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          if (role != UserRole.user)
                                            const PopupMenuItem(
                                              value: 'make_user',
                                              child: Text('Jadikan User', style: TextStyle(fontSize: 14)),
                                            ),
                                          if (role != UserRole.admin)
                                            const PopupMenuItem(
                                              value: 'make_admin',
                                              child: Text('Jadikan Admin', style: TextStyle(fontSize: 14)),
                                            ),
                                          const PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Hapus User', style: TextStyle(fontSize: 14, color: Colors.red)),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
