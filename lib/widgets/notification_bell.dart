import 'package:flutter/material.dart';

class NotificationBell extends StatelessWidget {
  final bool hasNotification;
  final VoidCallback onTap;
  final Color iconColor;
  final Color? backgroundColor;

  const NotificationBell({
    super.key,
    required this.onTap,
    this.hasNotification = false,
    this.iconColor = Colors.black87,
    this.backgroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Stack(
            children: [
              Icon(
                Icons.notifications_none_outlined,
                color: iconColor,
                size: 26,
              ),
              if (hasNotification)
                Positioned(
                  right: 2,
                  top: 2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
