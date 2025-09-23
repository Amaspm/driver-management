from django.shortcuts import redirect
from django.urls import reverse
from django.contrib.auth.decorators import user_passes_test

class AdminOnlyMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        # Allow access to login page, static files, and API endpoints
        allowed_paths = ['/login/', '/static/', '/media/', '/api/']
        
        if any(request.path.startswith(path) for path in allowed_paths):
            response = self.get_response(request)
            return response
        
        # Check if user is authenticated and is admin
        if not request.user.is_authenticated:
            return redirect('/login/')
        
        if not (request.user.is_staff and request.user.is_superuser):
            return redirect('/login/')
        
        response = self.get_response(request)
        return response