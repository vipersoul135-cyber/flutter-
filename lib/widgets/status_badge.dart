import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class StatusBadge extends StatefulWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    Key? key,
    required this.status,
    this.fontSize = 11.0,
  }) : super(key: key);

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.status.toLowerCase() == 'live' || widget.status.toLowerCase() == 'online') {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant StatusBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status.toLowerCase() == 'live' || widget.status.toLowerCase() == 'online') {
      if (!_pulseController.isAnimating) {
        _pulseController.repeat(reverse: true);
      }
    } else {
      _pulseController.stop();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color badgeColor;
    String displayLabel;

    switch (widget.status.toLowerCase()) {
      case 'live':
      case 'online':
        badgeColor = AppTheme.liveColor;
        displayLabel = '🟢 LIVE';
        break;
      case 'at_stop':
        badgeColor = AppTheme.atStopColor;
        displayLabel = '🔵 AT STOP';
        break;
      case 'delayed':
        badgeColor = AppTheme.delayedColor;
        displayLabel = '🟠 DELAYED';
        break;
      case 'offline':
        badgeColor = AppTheme.offlineColor;
        displayLabel = '🔴 OFFLINE';
        break;
      case 'not_started':
      default:
        badgeColor = AppTheme.notStartedColor;
        displayLabel = '⚫ NOT STARTED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withOpacity(0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.status.toLowerCase() == 'live' || widget.status.toLowerCase() == 'online')
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _pulseAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: badgeColor,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.glowShadow(badgeColor),
                    ),
                  ),
                );
              },
            ),
          Text(
            displayLabel,
            style: TextStyle(
              color: badgeColor,
              fontWeight: FontWeight.bold,
              fontSize: widget.fontSize,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
