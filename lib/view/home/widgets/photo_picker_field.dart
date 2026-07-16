import 'dart:io';

import 'package:flutter/material.dart';
import 'package:renttie/core/constants/app_colors.dart';
import 'package:renttie/core/constants/app_spacing.dart';
import 'package:renttie/core/constants/app_typography.dart';

class PhotoPickerField extends StatelessWidget {
  const PhotoPickerField({
    super.key,
    required this.photoPath,
    required this.onPick,
    this.isCircular = false,
  });

  final String? photoPath;
  final VoidCallback onPick;
  final bool isCircular;

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        photoPath != null && File(photoPath!).existsSync();

    return Center(
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(isCircular ? 70 : 18),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: isCircular ? 112 : double.infinity,
              height: isCircular ? 112 : 180,
              decoration: BoxDecoration(
                color: AppColors.surface(context),
                borderRadius: BorderRadius.circular(isCircular ? 56 : 18),
                border: Border.all(color: AppColors.border(context)),
                image: hasPhoto
                    ? DecorationImage(
                        image: FileImage(File(photoPath!)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: hasPhoto
                  ? null
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          color: AppColors.secondary,
                          size: 32,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Fotoğraf seç (isteğe bağlı)',
                          style: AppTypography.label(
                            color: AppColors.textSecondary(context),
                          ),
                        ),
                      ],
                    ),
            ),
            if (hasPhoto)
              Positioned(
                right: isCircular ? -4 : 10,
                bottom: isCircular ? -4 : 10,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.secondary,
                  child: const Icon(
                    Icons.edit_outlined,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
