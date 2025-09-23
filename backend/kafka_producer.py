import json
import requests
from django.conf import settings

class KafkaProducer:
    def __init__(self):
        self.driver_service_url = getattr(settings, 'DRIVER_SERVICE_URL', 'http://driver-service:8080')
    
    def publish_order_request(self, order_data):
        """Publish order request to driver service"""
        try:
            response = requests.post(
                f"{self.driver_service_url}/order/request",
                json=order_data,
                timeout=5
            )
            return response.status_code == 200
        except Exception as e:
            print(f"Error publishing order request: {e}")
            return False
    
    def publish_driver_status(self, driver_data):
        """Publish driver status to driver service"""
        try:
            response = requests.post(
                f"{self.driver_service_url}/driver/status",
                json=driver_data,
                timeout=5
            )
            return response.status_code == 200
        except Exception as e:
            print(f"Error publishing driver status: {e}")
            return False