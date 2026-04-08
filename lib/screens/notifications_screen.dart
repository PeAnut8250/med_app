import 'package:flutter/material.dart';
import '../widgets/notification_bell.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color primaryTeal = Color(0xFF26A9B1);
  static const Color accentBlue = Color(0xFF2196F3);

  // Initial mock data
  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'appointment',
      'title': 'Appointment Reminder',
      'description': 'Your appointment with Dr. Sarah Mitchell is today at 1:00 PM.',
      'time': '10m ago',
      'icon': Icons.calendar_today,
      'iconColor': accentBlue,
    },
    {
      'type': 'message',
      'title': 'New Message',
      'description': 'Dr. Aris Thorne sent you a message regarding your blood test.',
      'time': '2h ago',
      'icon': Icons.chat_bubble,
      'iconColor': Colors.green,
    },
    {
      'type': 'tip',
      'title': 'Health Tip',
      'description': 'Stay hydrated! Drinking enough water is essential for your kidney health.',
      'time': 'Yesterday',
      'icon': Icons.opacity,
      'iconColor': Colors.orange,
      'isGradient': true,
    },
    {
      'type': 'system',
      'title': 'System Update',
      'description': 'Your medical records have been successfully uploaded.',
      'time': 'Yesterday',
      'icon': Icons.cloud_done,
      'iconColor': Colors.blueGrey,
      'isModern': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _notifications.isEmpty 
                ? _buildEmptyState()
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildSectionHeader('TODAY', showBadge: true),
                      ..._notifications.where((n) => n['time'].contains('ago')).map((n) => NotificationCard(
                        title: n['title'],
                        description: n['description'],
                        time: n['time'],
                        icon: n['icon'],
                        iconColor: n['iconColor'],
                        showActions: n['type'] == 'appointment',
                        isGradient: n['isGradient'] ?? false,
                        isModern: n['isModern'] ?? false,
                      )),
                      const SizedBox(height: 24),
                      _buildSectionHeader('YESTERDAY', showBadge: false),
                      ..._notifications.where((n) => n['time'].contains('Yesterday')).map((n) => NotificationCard(
                        title: n['title'],
                        description: n['description'],
                        time: n['time'],
                        icon: n['icon'],
                        iconColor: n['iconColor'],
                        showActions: n['type'] == 'appointment',
                        isGradient: n['isGradient'] ?? false,
                        isModern: n['isModern'] ?? false,
                      )),
                    ],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: primaryTeal.withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.done_all,
              size: 80,
              color: primaryTeal,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'You’re all caught up!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No new notifications for now.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircularBtn(context, Icons.chevron_left, () => Navigator.pop(context)),
          const Text(
            'Notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          NotificationBell(
            hasNotification: _notifications.isNotEmpty,
            onTap: () {}, // Already on notifications screen
          ),
        ],
      ),
    );
  }

  Widget _buildCircularBtn(BuildContext context, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Icon(icon, color: Colors.black87, size: 24),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool showBadge = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20, top: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Colors.black87,
            ),
          ),
          if (showBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: primaryTeal.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '2 New',
                style: TextStyle(
                  color: primaryTeal,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class NotificationCard extends StatefulWidget {
  final String title;
  final String description;
  final String time;
  final IconData icon;
  final Color iconColor;
  final bool showActions;
  final bool isGradient;
  final bool isModern;

  const NotificationCard({
    super.key,
    required this.title,
    required this.description,
    required this.time,
    required this.icon,
    required this.iconColor,
    this.showActions = false,
    this.isGradient = false,
    this.isModern = false,
  });

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  bool _isConfirmed = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: widget.isModern ? const Color(0xFFE0E0E0).withOpacity(0.4) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        gradient: widget.isGradient 
          ? LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange.withOpacity(0.15),
                Colors.orange.withOpacity(0.05),
              ],
            )
          : null,
        boxShadow: widget.isModern || widget.isGradient ? null : [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(widget.icon, color: widget.iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          widget.time,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (widget.showActions) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                const SizedBox(width: 56), // Align with text
                ElevatedButton(
                  onPressed: _isConfirmed ? null : () {
                    setState(() {
                      _isConfirmed = true;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Appointment Confirmed!'),
                        backgroundColor: Color(0xFF26A9B1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isConfirmed ? Colors.grey[200] : const Color(0xFF2196F3),
                    foregroundColor: _isConfirmed ? Colors.grey[600] : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  ),
                  child: Text(
                    _isConfirmed ? 'Confirmed' : 'Confirm', 
                    style: const TextStyle(fontWeight: FontWeight.bold)
                  ),
                ),
                if (!_isConfirmed) ...[
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Reschedule',
                      style: TextStyle(
                        color: Color(0xFF2196F3),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
