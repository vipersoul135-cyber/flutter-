import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SearchWidget extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final String hintText;
  final TextEditingController? controller;

  const SearchWidget({
    Key? key,
    required this.onChanged,
    this.hintText = 'Search bus, route or stop...',
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1D2A) : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: AppTheme.softShadow,
        border: Border.all(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: TextStyle(
          color: isDark ? Colors.white : const Color(0xFF2C3E50),
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF6A11CB),
            size: 20,
          ),
          suffixIcon: controller != null && controller!.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear_rounded, size: 18),
                  onPressed: () {
                    controller!.clear();
                    onChanged('');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
