from rest_framework import serializers
from .models import *

class DriverSerializer(serializers.ModelSerializer):
    class Meta:
        model = Driver
        fields = '__all__'

class VehicleSerializer(serializers.ModelSerializer):
    class Meta:
        model = Vehicle
        fields = '__all__'

class ArmadaSerializer(serializers.ModelSerializer):
    class Meta:
        model = Armada
        fields = '__all__'

class SalesOrderSerializer(serializers.ModelSerializer):
    class Meta:
        model = SalesOrder
        fields = '__all__'

class DeliveryOrderSerializer(serializers.ModelSerializer):
    class Meta:
        model = DeliveryOrder
        fields = '__all__'

class RiwayatPerjalananSerializer(serializers.ModelSerializer):
    class Meta:
        model = RiwayatPerjalanan
        fields = '__all__'

class PembayaranFeeSerializer(serializers.ModelSerializer):
    class Meta:
        model = PembayaranFee
        fields = '__all__'

class ArmadaDeliveryorderSerializer(serializers.ModelSerializer):
    class Meta:
        model = ArmadaDeliveryorder
        fields = '__all__'

class DriverArmadaSerializer(serializers.ModelSerializer):
    class Meta:
        model = DriverArmada
        fields = '__all__'

# Training Content Serializers
class TrainingContentSerializer(serializers.ModelSerializer):
    media_url = serializers.SerializerMethodField()
    youtube_embed_url = serializers.SerializerMethodField()
    youtube_thumbnail = serializers.SerializerMethodField()
    
    class Meta:
        model = TrainingContent
        fields = '__all__'
    
    def get_media_url(self, obj):
        """Return appropriate media URL based on content type"""
        if obj.youtube_url:
            return obj.youtube_url
        elif obj.media_file:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.media_file.url)
            return obj.media_file.url
        elif obj.media_content:
            return obj.media_content
        return None
    
    def get_youtube_embed_url(self, obj):
        """Return YouTube embed URL if it's a YouTube video"""
        if obj.youtube_url:
            # Simple YouTube URL conversion
            if 'youtube.com/watch?v=' in obj.youtube_url:
                video_id = obj.youtube_url.split('v=')[1].split('&')[0]
                return f'https://www.youtube.com/embed/{video_id}'
        return None
    
    def get_youtube_thumbnail(self, obj):
        """Return YouTube thumbnail URL if it's a YouTube video"""
        if obj.youtube_url:
            # Simple YouTube thumbnail URL
            if 'youtube.com/watch?v=' in obj.youtube_url:
                video_id = obj.youtube_url.split('v=')[1].split('&')[0]
                return f'https://img.youtube.com/vi/{video_id}/maxresdefault.jpg'
        return None

class TrainingQuizSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrainingQuiz
        fields = '__all__'

class TrainingModuleSerializer(serializers.ModelSerializer):
    class Meta:
        model = TrainingModule
        fields = '__all__'

class DriverTrainingProgressSerializer(serializers.ModelSerializer):
    module_title = serializers.CharField(source='module.title', read_only=True)
    
    class Meta:
        model = DriverTrainingProgress
        fields = '__all__'

class OrderSerializer(serializers.ModelSerializer):
    driver_name = serializers.CharField(source='driver.nama', read_only=True)
    
    class Meta:
        model = Order
        fields = '__all__'