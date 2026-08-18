import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_typography.dart';
import '../constants/app_spacing.dart';

class AccessDeniedPage extends StatelessWidget {
  const AccessDeniedPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Akses Ditolak'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 80,
                color: Colors.grey,
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Akses Ditolak',
                style: AppTypography.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Anda tidak memiliki izin untuk mengakses halaman ini.',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
