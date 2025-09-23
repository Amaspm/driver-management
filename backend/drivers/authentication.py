from rest_framework.authtoken.views import ObtainAuthToken
from rest_framework.authtoken.models import Token
from rest_framework.response import Response
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from .models import Driver

class AdminAuthToken(ObtainAuthToken):
    def post(self, request, *args, **kwargs):
        username = request.data.get('username')
        password = request.data.get('password')
        
        if not username or not password:
            return Response({'error': 'Username dan password harus diisi'}, status=400)
        
        user = authenticate(username=username, password=password)
        
        if user and user.is_active and (user.is_staff or user.is_superuser):
            token, created = Token.objects.get_or_create(user=user)
            return Response({
                'token': token.key,
                'user_id': user.id,
                'username': user.username,
                'email': user.email,
                'role': 'admin'
            })
        
        return Response({'error': 'Username atau password salah'}, status=400)

class CustomAuthToken(ObtainAuthToken):
    def post(self, request, *args, **kwargs):
        email = request.data.get('username')  # Frontend sends as 'username' but we treat as email
        password = request.data.get('password')
        
        if not email or '@' not in email:
            return Response({'error': 'Email harus diisi dengan format yang benar'}, status=400)
        
        try:
            user_obj = User.objects.get(email=email)
            user = authenticate(username=user_obj.username, password=password)
        except User.DoesNotExist:
            return Response({'error': 'Email atau password salah'}, status=400)
        
        if user and user.is_active:
            # Block admin from mobile login
            if user.is_staff or user.is_superuser:
                return Response({'error': 'Akun admin tidak dapat login melalui aplikasi mobile'}, status=403)
            
            # Check if driver exists and is active
            try:
                driver = Driver.objects.get(email=user.email)
                if driver.status != 'active':
                    return Response({'error': 'Akun driver belum diaktivasi oleh admin'}, status=403)
            except Driver.DoesNotExist:
                return Response({'error': 'Data driver tidak ditemukan'}, status=404)
            
            token, created = Token.objects.get_or_create(user=user)
            
            return Response({
                'token': token.key,
                'user_id': user.id,
                'username': user.username,
                'email': user.email,
                'role': 'driver',
                'driver': {
                    'id': driver.id_driver,
                    'name': driver.nama,
                    'status': driver.status
                }
            })
        
        return Response({'error': 'Email atau password salah'}, status=400)