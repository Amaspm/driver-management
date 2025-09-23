from rest_framework import permissions

class IsAdminOrDriverOwner(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_authenticated
    
    def has_object_permission(self, request, view, obj):
        if request.user.is_staff:
            return True
        
        # Driver can only access their own data
        if hasattr(obj, 'email'):
            return obj.email == request.user.email
        return False

class IsAdminOnly(permissions.BasePermission):
    def has_permission(self, request, view):
        return request.user and request.user.is_staff