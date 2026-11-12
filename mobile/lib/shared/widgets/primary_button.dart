import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/shared/constants/app_colors.dart';

class PrimaryButton extends ConsumerWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.outlined = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool outlined;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 18),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    final style = ElevatedButton.styleFrom(
      backgroundColor: outlined ? Colors.white : AppColors.primary,
      foregroundColor: outlined ? AppColors.primary : AppColors.textOnPrimary,
      elevation: 0,
      side: outlined ? const BorderSide(color: AppColors.primary) : null,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600),
    );

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(onPressed: onPressed, style: style, child: child),
    );
  }
}
