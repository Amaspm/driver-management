import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/driver_shift_service.dart';

class OrderNotificationDialog extends StatelessWidget {
  final Map<String, dynamic> orderData;

  const OrderNotificationDialog({
    Key? key,
    required this.orderData,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_shipping,
              size: 48,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Pesanan Baru!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.location_on, 'Pickup', orderData['pickup'] ?? 'Alamat Pickup'),
                  SizedBox(height: 8),
                  _buildInfoRow(Icons.flag, 'Tujuan', orderData['tujuan'] ?? 'Alamat Tujuan'),
                  SizedBox(height: 8),
                  _buildInfoRow(Icons.attach_money, 'Bayaran', 'Rp ${orderData['ongkos'] ?? 0}'),
                  SizedBox(height: 8),
                  _buildInfoRow(Icons.access_time, 'Estimasi', '15 menit'),
                ],
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleReject(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      foregroundColor: Theme.of(context).colorScheme.onSurface,
                      side: BorderSide(color: Theme.of(context).colorScheme.outline),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Abaikan'),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleAccept(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Terima'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleAccept(BuildContext context) async {
    Navigator.of(context).pop();
    final shiftService = Provider.of<DriverShiftService>(context, listen: false);
    final success = await shiftService.acceptOrder(orderData['order_id']);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Pesanan berhasil diterima!' : 'Gagal menerima pesanan'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }
  
  void _handleReject(BuildContext context) async {
    Navigator.of(context).pop();
    final shiftService = Provider.of<DriverShiftService>(context, listen: false);
    
    // Remove notification from list when rejected
    shiftService.removeNotificationByOrderId(orderData['order_id']);
    
    final success = await shiftService.rejectOrder(orderData['order_id']);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Pesanan diabaikan' : 'Pesanan diabaikan (offline)'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Builder(
      builder: (context) => Row(
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}