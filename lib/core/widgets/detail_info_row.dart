import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class DetailInfoRow extends StatelessWidget {
  final String label;
  final Widget child;
  final bool centered;

  const DetailInfoRow({
    super.key,
    required this.label,
    required this.child,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          centered ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: centered ? TextAlign.center : TextAlign.start,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: AppTheme.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}
