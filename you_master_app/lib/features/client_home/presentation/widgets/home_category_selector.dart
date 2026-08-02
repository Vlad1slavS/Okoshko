import 'package:flutter/material.dart';
import 'package:you_master_app/design_system/theme/app_colors.dart';
import 'package:you_master_app/features/client_home/domain/home_category.dart';

class HomeCategorySelector extends StatelessWidget {
  const HomeCategorySelector({
    required this.selectedCategory,
    required this.onSelected,
    super.key,
  });

  final HomeCategory selectedCategory;
  final ValueChanged<HomeCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero,
        itemCount: HomeCategory.values.length,
        separatorBuilder: (_, _) => const SizedBox(width: 18),
        itemBuilder: (context, index) {
          final category = HomeCategory.values[index];
          final isSelected = category == selectedCategory;
          return Semantics(
            button: true,
            selected: isSelected,
            label: category.label,
            child: InkWell(
              key: Key('category-${category.name}'),
              borderRadius: BorderRadius.circular(48),
              onTap: () => onSelected(category),
              child: SizedBox(
                width: 65,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceMuted,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: category.imageAsset != null
                              ? Image.asset(
                                  category.imageAsset!,
                                  width: 30,
                                  height: 30,
                                  fit: BoxFit.contain,
                                )
                              : Icon(
                                  category.icon,
                                  size: 22,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textPrimary,
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),
                    Text(
                      category.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
