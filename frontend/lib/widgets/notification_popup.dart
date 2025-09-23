import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/driver_shift_service.dart';
import 'order_notification_dialog.dart';

class NotificationPopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DriverShiftService>(
      builder: (context, shiftService, child) {
        final notifications = shiftService.notifications;
        
        if (notifications.isEmpty) {
          return Container(
            width: 300,
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              'Tidak ada notifikasi',
              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
              textAlign: TextAlign.center,
            ),
          );
        }
        
        return Container(
          width: 320,
          constraints: BoxConstraints(maxHeight: 400),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifikasi',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (notifications.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          shiftService.clearAllNotifications();
                        },
                        child: Text(
                          'Hapus Semua',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                  ],
                ),
              ),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final isRead = notification['read'] ?? false;
                    
                    return InkWell(
                      onTap: () {
                        shiftService.markNotificationAsRead(index);
                        if (notification['type'] == 'order') {
                          Navigator.of(context).pop();
                          showDialog(
                            context: context,
                            builder: (context) => OrderNotificationDialog(
                              orderData: notification,
                            ),
                          );
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isRead 
                            ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
                            : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          border: Border(
                            bottom: BorderSide(
                              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            ),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.local_shipping,
                                  size: 16,
                                  color: isRead 
                                    ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                                    : Theme.of(context).colorScheme.primary,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Pesanan Baru #${notification['order_id']}',
                                    style: TextStyle(
                                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                  ),
                                ),
                                if (!isRead)
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Dari: ${notification['pickup'] ?? 'Alamat pickup'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              'Ke: ${notification['tujuan'] ?? 'Alamat tujuan'}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                              ),
                            ),
                            Text(
                              'Ongkos: Rp${notification['ongkos'] ?? 0}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}