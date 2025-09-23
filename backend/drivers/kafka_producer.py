import json
from kafka import KafkaProducer
from django.conf import settings
from django.utils import timezone

producer = None

def get_producer():
    global producer
    if producer is None:
        try:
            producer = KafkaProducer(
                bootstrap_servers=settings.KAFKA_BOOTSTRAP_SERVERS,
                value_serializer=lambda v: json.dumps(v).encode('utf-8')
            )
        except Exception as e:
            print(f"Kafka not available: {e}")
            return None
    return producer

def send_driver_event(event_type, driver_id):
    try:
        kafka_producer = get_producer()
        if kafka_producer:
            message = {
                'event_type': event_type,
                'driver_id': driver_id,
                'timestamp': str(timezone.now())
            }
            kafka_producer.send('driver_events', value=message)
            kafka_producer.flush()
    except Exception as e:
        print(f"Error sending Kafka message: {e}")