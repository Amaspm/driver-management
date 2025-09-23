from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import DriverViewSet, VehicleViewSet, ArmadaViewSet, SalesOrderViewSet, DeliveryOrderViewSet, RiwayatPerjalananViewSet, PembayaranFeeViewSet, ArmadaDeliveryorderViewSet, DriverArmadaViewSet, UserProfileView, register_driver, login_driver, check_driver_status, TrainingModuleViewSet, TrainingContentViewSet, TrainingQuizViewSet, DriverTrainingProgressViewSet, complete_training, create_driver_account, update_rejected_documents, complete_rejected_documents, cleanup_orphaned_users, check_database_sync, get_driver_statistics, get_driver_trips
from .authentication import CustomAuthToken, AdminAuthToken
import driver_api
router = DefaultRouter()
router.register(r'drivers', DriverViewSet)
router.register(r'vehicles', VehicleViewSet)
router.register(r'armada', ArmadaViewSet)
router.register(r'sales-orders', SalesOrderViewSet)
router.register(r'delivery-orders', DeliveryOrderViewSet)
router.register(r'riwayat-perjalanan', RiwayatPerjalananViewSet)
router.register(r'pembayaran-fee', PembayaranFeeViewSet)
router.register(r'armada-delivery-orders', ArmadaDeliveryorderViewSet)
router.register(r'driver-armada', DriverArmadaViewSet)
router.register(r'training-modules', TrainingModuleViewSet)
router.register(r'training-contents', TrainingContentViewSet)
router.register(r'training-quizzes', TrainingQuizViewSet)
router.register(r'training-progress', DriverTrainingProgressViewSet)

urlpatterns = [
    # API endpoints for mobile/web
    path('auth/login/', CustomAuthToken.as_view(), name='api_token_auth'),
    path('auth/admin-login/', AdminAuthToken.as_view(), name='admin_token_auth'),
    path('auth/user/', UserProfileView.as_view(), name='user_profile'),
    
    # Driver registration and status endpoints
    path('drivers/register/', register_driver, name='register_driver'),
    path('drivers/login/', login_driver, name='login_driver'),
    path('drivers/status/', check_driver_status, name='check_driver_status'),
    path('drivers/update-documents/', update_rejected_documents, name='update_rejected_documents'),
    path('drivers/complete-documents/', complete_rejected_documents, name='complete_rejected_documents'),
    path('training/complete/', complete_training, name='complete_training'),
    path('auth/create-driver/', create_driver_account, name='create_driver_account'),
    path('drivers/statistics/', get_driver_statistics, name='get_driver_statistics'),
    path('drivers/trips/', get_driver_trips, name='get_driver_trips'),
    path('admin/cleanup-users/', cleanup_orphaned_users, name='cleanup_orphaned_users'),
    path('admin/check-sync/', check_database_sync, name='check_database_sync'),
    
    # Driver shift endpoints
    path('driver/online/', driver_api.driver_online, name='driver_online'),
    path('driver/offline/', driver_api.driver_offline, name='driver_offline'),
    path('order/create/', driver_api.create_order, name='create_order'),
    path('order/confirmed/', driver_api.order_confirmed, name='order_confirmed'),
    path('order/response/', driver_api.order_response, name='order_response'),
    path('orders/', driver_api.get_orders, name='get_orders'),
    
    path('', include(router.urls)),
]