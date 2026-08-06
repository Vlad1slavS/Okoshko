import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/client_profile/domain/client_profile.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({required this.profile, required this.onEdit, super.key});

  final ClientProfile profile;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: AppColors.primaryContainer,
          backgroundImage: profile.avatarAsset == null
              ? null
              : AssetImage(profile.avatarAsset!),
          child: profile.avatarAsset == null
              ? const Icon(
                  Icons.person_outline_rounded,
                  size: 42,
                  color: AppColors.primary,
                )
              : null,
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                profile.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (profile.isPhoneVerified) ...[
              const SizedBox(width: 5),
              const Icon(
                Icons.verified_rounded,
                size: 18,
                color: AppColors.primary,
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        if (profile.phone.isNotEmpty)
          Text(profile.phone, style: Theme.of(context).textTheme.bodyMedium),
        if (profile.email?.isNotEmpty == true) ...[
          const SizedBox(height: 2),
          Text(profile.email!, style: Theme.of(context).textTheme.bodyMedium),
        ],
        const SizedBox(height: 10),
        TextButton.icon(
          key: const Key('edit-client-profile'),
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined, size: 18),
          label: const Text('Редактировать'),
        ),
      ],
    );
  }
}
