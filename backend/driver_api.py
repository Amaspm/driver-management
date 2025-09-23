from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.views.decorators.http import require_http_methods
import json
from kafka_producer import KafkaProducer
from drivers.models import Order, Driver
from django.utils import timezone

kafka_producer = KafkaProducer()

@csrf_exempt
@require_http_methods(["POST"])
def driver_online(request):
    """API endpoint for driver to go online"""
    try:
        data = json.loads(request.body)
        driver_id = data.get('driver_id')
        kota = data.get('kota')
        
        if not driver_id or not kota:
            return JsonResponse({'error': 'driver_id and kota required'}, status=400)
        
        # Publish to Kafka
        status_data = {
            'driver_id': driver_id,
            'kota': kota,
            'status': 'online'
        }
        
        success = kafka_producer.publish_driver_status(status_data)
        
        if success:
            return JsonResponse({'message': 'Driver is now online'})
        else:
            return JsonResponse({'error': 'Failed to update status'}, status=500)
            
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

@csrf_exempt
@require_http_methods(["POST"])
def driver_offline(request):
    """API endpoint for driver to go offline"""
    try:
        data = json.loads(request.body)
        driver_id = data.get('driver_id')
        
        if not driver_id:
            return JsonResponse({'error': 'driver_id required'}, status=400)
        
        # Publish to Kafka
        status_data = {
            'driver_id': driver_id,
            'status': 'offline'
        }
        
        success = kafka_producer.publish_driver_status(status_data)
        
        if success:
            return JsonResponse({'message': 'Driver is now offline'})
        else:
            return JsonResponse({'error': 'Failed to update status'}, status=500)
            
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

@csrf_exempt
@require_http_methods(["POST"])
def create_order(request):
    """API endpoint to create new order from user"""
    try:
        data = json.loads(request.body)
        barang = data.get('barang')
        kota = data.get('kota')
        
        if not all([barang, kota]):
            return JsonResponse({'error': 'barang and kota required'}, status=400)
        
        # Generate order ID
        order_id = f"order_{int(timezone.now().timestamp())}"
        
        # Create order in database
        order = Order.objects.create(
            order_id=order_id,
            barang=barang,
            pickup='Alamat Pickup Dummy',
            tujuan=f'{barang} ke {kota}',
            kota=kota,
            status='menunggu_konfirmasi'
        )
        
        return JsonResponse({
            'order_id': order.order_id,
            'message': 'Order created successfully',
            'status': order.status
        })
        
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

@csrf_exempt
@require_http_methods(["POST"])
def order_confirmed(request):
    """API endpoint when seller confirms order"""
    try:
        data = json.loads(request.body)
        order_id = data.get('order_id')
        pickup = data.get('pickup', 'Alamat Pickup')
        tujuan = data.get('tujuan')
        kota = data.get('kota')
        
        if not all([order_id, tujuan, kota]):
            return JsonResponse({'error': 'order_id, tujuan, and kota required'}, status=400)
        
        # Update or create order in database
        order, created = Order.objects.get_or_create(
            order_id=order_id,
            defaults={
                'barang': 'Barang',
                'pickup': pickup,
                'tujuan': tujuan,
                'kota': kota,
                'status': 'menunggu_driver'
            }
        )
        
        if not created:
            order.status = 'menunggu_driver'
            order.pickup = pickup
            order.tujuan = tujuan
            order.save()
        
        # Publish order request to Kafka
        order_data = {
            'order_id': order_id,
            'pickup': pickup,
            'tujuan': tujuan,
            'ongkos': order.ongkos,
            'kota': kota
        }
        
        # Try Kafka first, then fallback to direct HTTP
        success = kafka_producer.publish_order_request(order_data)
        print(f"Kafka publish result: {success}")
        
        if not success:
            # Fallback: send directly to driver-service
            try:
                import requests
                print(f"Sending order to driver-service: {order_data}")
                response = requests.post(
                    'http://driver-service:8080/order/request',
                    json=order_data,
                    timeout=5
                )
                print(f"Driver-service response: {response.status_code}")
                success = response.status_code == 200
            except Exception as e:
                print(f"Direct HTTP to driver-service failed: {e}")
                success = False
        
        if success:
            return JsonResponse({'message': 'Order sent to drivers'})
        else:
            return JsonResponse({'error': 'Failed to send order'}, status=500)
            
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

@csrf_exempt
@require_http_methods(["POST"])
def order_response(request):
    """API endpoint for driver order response"""
    try:
        data = json.loads(request.body)
        driver_id = data.get('driver_id')
        order_id = data.get('order_id')
        action = data.get('action')
        
        if not all([driver_id, order_id, action]):
            return JsonResponse({'error': 'driver_id, order_id, and action required'}, status=400)
        
        # Update order in database if accepted
        if action == 'terima':
            try:
                order = Order.objects.get(order_id=order_id)
                driver = Driver.objects.get(id_driver=driver_id)
                order.driver = driver
                order.status = 'sedang_dikirim'
                order.save()
                print(f"Order {order_id} assigned to driver {driver.nama}")
            except (Order.DoesNotExist, Driver.DoesNotExist) as e:
                print(f"Error updating order: {e}")
        
        # Publish response to Kafka
        response_data = {
            'driver_id': driver_id,
            'order_id': order_id,
            'action': action
        }
        
        # Send to Go service via HTTP (since it handles Kafka publishing)
        import requests
        try:
            response = requests.post(
                'http://driver-service:8080/order/response',
                json=response_data,
                timeout=5
            )
            if response.status_code == 200:
                return JsonResponse({'message': f'Order {action} successfully'})
            else:
                return JsonResponse({'error': 'Failed to process response'}, status=500)
        except Exception as e:
            return JsonResponse({'error': f'Service unavailable: {str(e)}'}, status=503)
            
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)

@csrf_exempt
@require_http_methods(["GET"])
def get_orders(request):
    """API endpoint to get orders by status"""
    try:
        status_filter = request.GET.get('status', 'menunggu_konfirmasi')
        orders = Order.objects.filter(status=status_filter).order_by('-created_at')
        
        orders_data = []
        for order in orders:
            orders_data.append({
                'order_id': order.order_id,
                'barang': order.barang,
                'pickup': order.pickup,
                'tujuan': order.tujuan,
                'kota': order.kota,
                'ongkos': order.ongkos,
                'status': order.status,
                'driver_name': order.driver.nama if order.driver else None,
                'created_at': order.created_at.isoformat(),
                'updated_at': order.updated_at.isoformat()
            })
        
        return JsonResponse({'orders': orders_data})
        
    except Exception as e:
        return JsonResponse({'error': str(e)}, status=500)