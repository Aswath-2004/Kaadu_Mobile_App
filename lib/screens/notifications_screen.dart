// notifications_screen.dart (New File)
import 'package:flutter/material.dart';
import 'package:kaadu_organics_app/models.dart'; // Import the NotificationItem model

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Local state for notifications, allowing them to be marked as read
  // In a real app, this would be managed by a state management solution
  // and persist across app launches.
  List<NotificationItem> _notifications = List.from(dummyNotifications);

  void _markAsRead(String notificationId) {
    setState(() {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationItem(
          id: _notifications[index].id,
          title: _notifications[index].title,
          message: _notifications[index].message,
          type: _notifications[index].type,
          timestamp: _notifications[index].timestamp,
          isRead: true,
        );
      }
    });
  }

  void _deleteAllNotifications() {
    setState(() {
      _notifications.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All notifications cleared!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: _deleteAllNotifications,
            child: const Text(
              'Clear All',
              style: TextStyle(color: Color(0xFF5CB85C)),
            ),
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_rounded,
                      size: 80,
                      color: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.color
                          ?.withAlpha((255 * 0.3).round())),
                  const SizedBox(height: 16.0),
                  Text(
                    'No New Notifications',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodyLarge
                            ?.color
                            ?.withAlpha((255 * 0.5).round())),
                  ),
                  const SizedBox(height: 8.0),
                  Text(
                    'You\'re all caught up!',
                    style: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withAlpha((255 * 0.7).round())),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _notifications.length,
              itemBuilder: (context, index) {
                final notification = _notifications[index];
                return NotificationCard(
                  notification: notification,
                  onTap: () => _markAsRead(notification.id),
                );
              },
            ),
    );
  }
}

class NotificationCard extends StatelessWidget {
  final NotificationItem notification;
  final VoidCallback onTap;

  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    IconData icon;
    Color iconColor;
    Color cardColor;

    switch (notification.type) {
      case 'offer':
        icon = Icons.local_offer_rounded;
        iconColor = Colors.redAccent;
        cardColor = Colors.redAccent.withOpacity(0.1);
        break;
      case 'delivery':
        icon = Icons.delivery_dining_rounded;
        iconColor = const Color(0xFF5CB85C);
        cardColor = const Color(0xFF5CB85C).withOpacity(0.1);
        break;
      default:
        icon = Icons.info_rounded;
        iconColor = Colors.blueAccent;
        cardColor = Colors.blueAccent.withOpacity(0.1);
    }

    // Adjust card background based on read status
    final effectiveCardColor = notification.isRead
        ? Theme.of(context).cardColor // Default card color if read
        : cardColor; // Highlight if unread

    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: effectiveCardColor,
        margin: const EdgeInsets.only(bottom: 12.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: BorderSide(
            color: notification.isRead
                ? Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withAlpha((255 * 0.1).round()) ??
                    Colors.white10
                : iconColor.withOpacity(0.5), // Stronger border for unread
            width: notification.isRead ? 0.5 : 1.0,
          ),
        ),
        elevation:
            notification.isRead ? 1 : 3, // Slightly more elevation for unread
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 30),
              const SizedBox(width: 16.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      notification.message,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withAlpha((255 * 0.8).round()),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      notification.timestamp,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withAlpha((255 * 0.6).round()),
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(
                    radius: 5,
                    backgroundColor: iconColor, // Unread indicator
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
