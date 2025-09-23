from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.views import APIView
from rest_framework.authtoken.models import Token
from rest_framework.exceptions import ValidationError
from django.contrib.auth import authenticate
from django.contrib.auth.models import User
from datetime import datetime
from django.utils import timezone
from .models import Driver, Vehicle, Armada, SalesOrder, DeliveryOrder, RiwayatPerjalanan, PembayaranFee, ArmadaDeliveryorder, DriverArmada, TrainingModule, TrainingContent, TrainingQuiz, DriverTrainingProgress, RatingDriver
from .serializers import DriverSerializer, VehicleSerializer, ArmadaSerializer, SalesOrderSerializer, DeliveryOrderSerializer, RiwayatPerjalananSerializer, PembayaranFeeSerializer, ArmadaDeliveryorderSerializer, DriverArmadaSerializer, TrainingModuleSerializer, TrainingContentSerializer, TrainingQuizSerializer, DriverTrainingProgressSerializer
from .permissions import IsAdminOrDriverOwner, IsAdminOnly
def send_driver_event(event_type, driver_id):
    print(f"Event: {event_type} for driver {driver_id}")

class DriverViewSet(viewsets.ModelViewSet):
    queryset = Driver.objects.all()
    serializer_class = DriverSerializer
    permission_classes = [IsAdminOrDriverOwner]
    
    def destroy(self, request, *args, **kwargs):
        instance = self.get_object()
        driver_name = instance.nama
        driver_id = instance.id_driver
        driver_email = instance.email
        print(f"DELETE request received for driver: {driver_name} (ID: {driver_id}, Email: {driver_email})")
        print(f"Request user: {request.user.username}, is_staff: {request.user.is_staff}")
        
        # Call the parent destroy method which will call perform_destroy
        response = super().destroy(request, *args, **kwargs)
        
        print(f"Driver {driver_name} (ID: {driver_id}) deletion completed successfully")
        return response
    
    def get_permissions(self):
        if self.action == 'create':
            return [AllowAny()]
        elif self.action == 'destroy':
            return [IsAdminOnly()]
        return [IsAuthenticated()]
    
    def get_queryset(self):
        if self.request.user.is_staff:
            return Driver.objects.all()
        return Driver.objects.filter(email=self.request.user.email)
    
    def update(self, request, *args, **kwargs):
        instance = self.get_object()
        
        # Check if user can update this driver
        if not request.user.is_staff and instance.email != request.user.email:
            return Response({'error': 'Permission denied'}, status=status.HTTP_403_FORBIDDEN)
        
        # Update driver data
        serializer = self.get_serializer(instance, data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        self.perform_update(serializer)
        
        return Response(serializer.data)
    
    def perform_create(self, serializer):
        # Create user account for new driver
        from django.contrib.auth.models import User
        username = serializer.validated_data.get('username')
        email = serializer.validated_data.get('email')
        password = serializer.validated_data.get('password', 'defaultpassword123')
        
        user, created = User.objects.get_or_create(
            username=username,
            defaults={'email': email}
        )
        if created:
            user.set_password(password)
            user.save()
        
        driver = serializer.save(status='pending')
        send_driver_event('driver_created', driver.id_driver)
    
    def perform_update(self, serializer):
        driver = serializer.save()
        send_driver_event('driver_updated', driver.id_driver)
    
    def perform_destroy(self, instance):
        driver_id = instance.id_driver
        driver_email = instance.email
        driver_name = instance.nama
        
        print(f"Attempting to delete driver: ID={driver_id}, Email={driver_email}, Name={driver_name}")
        
        # Delete associated user account and tokens when deleting driver
        try:
            user = User.objects.get(email=driver_email)
            print(f"Found user account for {driver_email}, deleting...")
            # Delete auth tokens first
            tokens_deleted = Token.objects.filter(user=user).delete()
            print(f"Deleted {tokens_deleted[0]} tokens")
            # Then delete the user
            user.delete()
            print(f"User account {driver_email} deleted successfully")
        except User.DoesNotExist:
            print(f"No user account found for {driver_email}")
        
        # Delete any vehicle assignments
        try:
            from .models import DriverArmada
            assignments = DriverArmada.objects.filter(id_driver=instance)
            assignments_count = assignments.count()
            if assignments_count > 0:
                assignments.delete()
                print(f"Deleted {assignments_count} vehicle assignments")
        except Exception as e:
            print(f"Error deleting vehicle assignments: {e}")
        
        # Delete the driver instance
        instance.delete()
        print(f"Driver {driver_name} (ID: {driver_id}) deleted successfully from database")
        send_driver_event('driver_deleted', driver_id)
    
    @action(detail=True, methods=['post'], permission_classes=[IsAdminOnly])
    def activate(self, request, pk=None):
        driver = self.get_object()
        driver.status = 'active'
        driver.save()
        send_driver_event('driver_activated', driver.id_driver)
        return Response({'status': 'activated'})
    
    @action(detail=True, methods=['post'], permission_classes=[IsAdminOnly])
    def suspend(self, request, pk=None):
        driver = self.get_object()
        driver.status = 'suspended'
        driver.save()
        send_driver_event('driver_suspended', driver.id_driver)
        return Response({'status': 'suspended'})
    
    @action(detail=True, methods=['post'], permission_classes=[IsAdminOnly])
    def accept(self, request, pk=None):
        driver = self.get_object()
        if driver.status == 'pending':
            driver.status = 'active'
            driver.save()
            send_driver_event('driver_accepted', driver.id_driver)
            return Response({'status': 'accepted and activated'})
        return Response({'error': 'Driver is not in pending status'}, status=400)
    
    @action(detail=False, methods=['post'], permission_classes=[IsAdminOnly])
    def bulk_activate(self, request):
        driver_ids = request.data.get('driver_ids', [])
        updated = Driver.objects.filter(id_driver__in=driver_ids).update(status='active')
        for driver_id in driver_ids:
            send_driver_event('driver_activated', driver_id)
        return Response({'message': f'{updated} drivers activated'})
    
    @action(detail=False, methods=['post'], permission_classes=[IsAdminOnly])
    def bulk_suspend(self, request):
        driver_ids = request.data.get('driver_ids', [])
        updated = Driver.objects.filter(id_driver__in=driver_ids).update(status='suspended')
        for driver_id in driver_ids:
            send_driver_event('driver_suspended', driver_id)
        return Response({'message': f'{updated} drivers suspended'})
    
    @action(detail=False, methods=['post'], permission_classes=[IsAdminOnly])
    def bulk_accept(self, request):
        driver_ids = request.data.get('driver_ids', [])
        updated = Driver.objects.filter(id_driver__in=driver_ids, status='pending').update(status='active')
        for driver_id in driver_ids:
            send_driver_event('driver_accepted', driver_id)
        return Response({'message': f'{updated} pending drivers accepted and activated'})
    
    @action(detail=True, methods=['post'], permission_classes=[IsAdminOnly])
    def update_status(self, request, pk=None):
        """Update driver status with optional rejection reason"""
        driver = self.get_object()
        new_status = request.data.get('status')
        rejection_reason = request.data.get('rejection_reason', '')
        
        if new_status not in ['active', 'pending', 'training', 'suspended', 'rejected']:
            return Response({'error': 'Invalid status'}, status=400)
        
        driver.status = new_status
        
        if new_status == 'rejected' and rejection_reason:
            driver.alasan_penolakan = rejection_reason
        elif new_status != 'rejected':
            driver.alasan_penolakan = None
        
        driver.save()
        
        event_map = {
            'active': 'driver_activated',
            'suspended': 'driver_suspended',
            'rejected': 'driver_rejected',
            'pending': 'driver_pending',
            'training': 'driver_training'
        }
        
        send_driver_event(event_map.get(new_status, 'driver_updated'), driver.id_driver)
        
        return Response({
            'status': new_status,
            'message': f'Driver status updated to {new_status}',
            'rejection_reason': driver.alasan_penolakan
        })

class VehicleViewSet(viewsets.ModelViewSet):
    queryset = Vehicle.objects.all()
    serializer_class = VehicleSerializer
    permission_classes = [IsAdminOrDriverOwner]
    
    def get_queryset(self):
        if self.request.user.is_staff:
            return Vehicle.objects.all()
        return Vehicle.objects.filter(driver__email=self.request.user.email)

class ArmadaViewSet(viewsets.ModelViewSet):
    queryset = Armada.objects.all()
    serializer_class = ArmadaSerializer
    permission_classes = [IsAuthenticated]
    
    def get_permissions(self):
        if self.action in ['list', 'retrieve']:
            return [IsAuthenticated()]
        elif self.action == 'create':
            return [IsAuthenticated()]  # Allow drivers to create their own vehicles
        return [IsAdminOnly()]

class SalesOrderViewSet(viewsets.ModelViewSet):
    queryset = SalesOrder.objects.all()
    serializer_class = SalesOrderSerializer
    permission_classes = [IsAdminOnly]

class DeliveryOrderViewSet(viewsets.ModelViewSet):
    queryset = DeliveryOrder.objects.all()
    serializer_class = DeliveryOrderSerializer
    permission_classes = [IsAdminOrDriverOwner]
    
    def get_queryset(self):
        if self.request.user.is_staff:
            return DeliveryOrder.objects.all()
        return DeliveryOrder.objects.filter(id_driver__email=self.request.user.email)

class RiwayatPerjalananViewSet(viewsets.ModelViewSet):
    queryset = RiwayatPerjalanan.objects.all()
    serializer_class = RiwayatPerjalananSerializer
    permission_classes = [IsAdminOrDriverOwner]

class PembayaranFeeViewSet(viewsets.ModelViewSet):
    queryset = PembayaranFee.objects.all()
    serializer_class = PembayaranFeeSerializer
    permission_classes = [IsAdminOnly]

class ArmadaDeliveryorderViewSet(viewsets.ModelViewSet):
    queryset = ArmadaDeliveryorder.objects.all()
    serializer_class = ArmadaDeliveryorderSerializer
    permission_classes = [IsAdminOnly]

class DriverArmadaViewSet(viewsets.ModelViewSet):
    queryset = DriverArmada.objects.all()
    serializer_class = DriverArmadaSerializer
    permission_classes = [IsAuthenticated]
    
    def get_permissions(self):
        if self.action in ['create', 'list', 'retrieve', 'destroy']:
            return [IsAuthenticated()]
        return [IsAdminOnly()]
    
    def get_queryset(self):
        if self.request.user.is_staff:
            return DriverArmada.objects.all()
        try:
            driver = Driver.objects.get(email=self.request.user.email)
            return DriverArmada.objects.filter(id_driver=driver)
        except Driver.DoesNotExist:
            return DriverArmada.objects.none()
    
    def create(self, request, *args, **kwargs):
        # Get driver from authenticated user
        try:
            driver = Driver.objects.get(email=request.user.email)
            
            # Check if driver already has an assignment for this vehicle
            armada_id = request.data.get('id_armada')
            existing = DriverArmada.objects.filter(
                id_driver=driver,
                id_armada=armada_id
            ).first()
            
            if existing:
                # Return existing assignment
                serializer = self.get_serializer(existing)
                return Response(serializer.data, status=status.HTTP_200_OK)
            else:
                # Create new assignment
                serializer = self.get_serializer(data=request.data)
                serializer.is_valid(raise_exception=True)
                instance = serializer.save(id_driver=driver)
                return Response(serializer.data, status=status.HTTP_201_CREATED)
                
        except Driver.DoesNotExist:
            return Response({'error': 'Driver not found'}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
    
    def perform_create(self, serializer):
        # Get driver from authenticated user
        try:
            driver = Driver.objects.get(email=self.request.user.email)
            
            # Check if driver already has an assignment for this vehicle
            armada_id = serializer.validated_data.get('id_armada')
            existing = DriverArmada.objects.filter(
                id_driver=driver,
                id_armada=armada_id
            ).first()
            
            if existing:
                # Return existing assignment without creating new one
                return existing
            else:
                # Create new assignment
                return serializer.save(id_driver=driver)
                
        except Driver.DoesNotExist:
            raise ValidationError('Driver not found')

class UserProfileView(APIView):
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        user = request.user
        try:
            driver = Driver.objects.get(email=user.email)
            return Response({
                'id': driver.id_driver,  # Return driver ID, not user ID
                'user_id': user.id,
                'username': user.username,
                'email': user.email,
                'nama': driver.nama,
                'no_hp': driver.no_hp,
                'status': driver.status,
                'alasan_penolakan': driver.alasan_penolakan,
            })
        except Driver.DoesNotExist:
            return Response({
                'id': user.id,
                'username': user.username,
                'email': user.email,
                'nama': user.first_name + ' ' + user.last_name,
                'no_hp': '',
                'status': 'admin' if user.is_staff else 'unknown',
                'alasan_penolakan': None,
            })

@api_view(['POST'])
@permission_classes([AllowAny])
def register_driver(request):
    """Register new driver - save data immediately after photo upload"""
    try:
        data = request.data
        print(f"Registration data received: {data}")
        email = data.get('email')
        
        # Check if driver already exists
        try:
            existing_driver = Driver.objects.get(email=email)
            if existing_driver.status in ['rejected', 'training']:
                # Update existing driver
                existing_driver.nama = data.get('nama')
                existing_driver.no_hp = data.get('no_hp')
                existing_driver.kota = data.get('kota')
                existing_driver.alamat = data.get('alamat')
                existing_driver.ttl = datetime.strptime(data.get('ttl', '1990-01-01'), '%Y-%m-%d').date()
                existing_driver.nik = data.get('nik', '0000000000000000')
                existing_driver.no_sim = data.get('no_sim')
                existing_driver.jenis_sim = data.get('jenis_sim')
                existing_driver.no_bpjs = data.get('no_bpjs')
                existing_driver.nama_kontak_darurat = data.get('nama_kontak_darurat')
                existing_driver.nomor_kontak_darurat = data.get('nomor_kontak_darurat')
                existing_driver.hubungan_kontak_darurat = data.get('hubungan_kontak_darurat')
                existing_driver.foto_ktp = data.get('foto_ktp')
                existing_driver.foto_sim = data.get('foto_sim')
                existing_driver.foto_profil = data.get('foto_profil')
                existing_driver.foto_sertifikat = data.get('foto_sertifikat')
                existing_driver.foto_bpjs = data.get('foto_bpjs')
                existing_driver.nama_bank = data.get('nama_bank')
                existing_driver.nomor_rekening = data.get('nomor_rekening')
                existing_driver.status = 'training'
                existing_driver.alasan_penolakan = None
                existing_driver.save()
                
                send_driver_event('driver_updated', existing_driver.id_driver)
                
                return Response({
                    'id': existing_driver.id_driver,
                    'message': 'Driver data updated successfully',
                    'status': 'training'
                }, status=status.HTTP_200_OK)
            else:
                return Response({
                    'error': 'Driver already exists with this email'
                }, status=400)
        except Driver.DoesNotExist:
            pass
        
        # Create new driver record with training status
        driver = Driver.objects.create(
            nama=data.get('nama'),
            email=data.get('email'),
            no_hp=data.get('no_hp'),
            kota=data.get('kota'),
            alamat=data.get('alamat'),
            ttl=datetime.strptime(data.get('ttl', '1990-01-01'), '%Y-%m-%d').date(),
            nik=data.get('nik', '0000000000000000'),
            no_sim=data.get('no_sim', ''),
            jenis_sim=data.get('jenis_sim', ''),
            tanggal_kedaluarsa_sim=datetime.strptime(data.get('tanggal_kedaluarsa_sim'), '%Y-%m-%d').date() if data.get('tanggal_kedaluarsa_sim') else None,
            no_bpjs=data.get('no_bpjs', ''),
            tanggal_kedaluarsa_bpjs=datetime.strptime(data.get('tanggal_kedaluarsa_bpjs'), '%Y-%m-%d').date() if data.get('tanggal_kedaluarsa_bpjs') else None,
            no_sertifikat=data.get('no_sertifikat', ''),
            tanggal_kedaluarsa_sertifikat=datetime.strptime(data.get('tanggal_kedaluarsa_sertifikat'), '%Y-%m-%d').date() if data.get('tanggal_kedaluarsa_sertifikat') else None,
            nama_kontak_darurat=data.get('nama_kontak_darurat', ''),
            nomor_kontak_darurat=data.get('nomor_kontak_darurat', ''),
            hubungan_kontak_darurat=data.get('hubungan_kontak_darurat', ''),
            foto_ktp=data.get('foto_ktp'),
            foto_sim=data.get('foto_sim'),
            foto_profil=data.get('foto_profil'),
            foto_sertifikat=data.get('foto_sertifikat'),
            foto_bpjs=data.get('foto_bpjs'),
            nama_bank=data.get('nama_bank'),
            nomor_rekening=data.get('nomor_rekening'),
            status='training'  # Set to training status initially
        )
        
        # Create user account with provided password
        password = data.get('password', 'driver123')
        user = User.objects.create_user(
            username=data.get('email'),
            email=data.get('email'),
            password=password
        )
        
        send_driver_event('driver_registered', driver.id_driver)
        
        return Response({
            'id': driver.id_driver,
            'message': 'Driver registered successfully',
            'status': 'training'
        }, status=status.HTTP_201_CREATED)
        
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=400)

@api_view(['POST'])
@permission_classes([AllowAny])
def login_driver(request):
    """Login driver"""
    email = request.data.get('email')
    password = request.data.get('password')
    
    if not email or not password:
        return Response({
            'error': 'Email and password are required'
        }, status=400)
    
    user = authenticate(username=email, password=password)
    
    if user:
        try:
            driver = Driver.objects.get(email=email)
            token, created = Token.objects.get_or_create(user=user)
            
            # Check if driver has vehicle assignment
            has_vehicle = DriverArmada.objects.filter(id_driver=driver).exists()
            
            return Response({
                'token': token.key,
                'driver_id': driver.id_driver,
                'status': driver.status,
                'has_vehicle': has_vehicle,
                'message': 'Login successful'
            })
        except Driver.DoesNotExist:
            return Response({
                'error': 'Driver not found'
            }, status=status.HTTP_404_NOT_FOUND)
    else:
        return Response({
            'error': 'Invalid credentials'
        }, status=status.HTTP_401_UNAUTHORIZED)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def check_driver_status(request):
    """Check driver status"""
    try:
        driver = Driver.objects.get(email=request.user.email)
        
        # Check training completion if status is training
        training_completed = False
        if driver.status == 'training':
            total_modules = TrainingModule.objects.filter(is_active=True).count()
            completed_modules = DriverTrainingProgress.objects.filter(
                driver=driver,
                is_completed=True
            ).count()
            training_completed = completed_modules >= total_modules
            
            # Update status to pending if training is completed
            if training_completed:
                driver.status = 'pending'
                driver.save()
        
        # Parse rejection reason for specific documents
        rejected_documents = []
        if driver.status == 'rejected' and driver.alasan_penolakan:
            if 'Dokumen tidak jelas/tidak sesuai:' in driver.alasan_penolakan:
                # Extract document names from rejection reason
                doc_part = driver.alasan_penolakan.split('Dokumen tidak jelas/tidak sesuai:')[1].strip()
                doc_names = [doc.strip() for doc in doc_part.split(',')]
                
                # Map document names to keys
                doc_mapping = {
                    'KTP': 'ktp',
                    'SIM': 'sim', 
                    'BPJS': 'bpjs',
                    'Sertifikat': 'sertifikat',
                    'Foto Profil': 'profil'
                }
                
                for doc_name in doc_names:
                    if doc_name in doc_mapping:
                        rejected_documents.append(doc_mapping[doc_name])
        
        return Response({
            'status': driver.status,
            'driver_id': driver.id_driver,
            'training_completed': training_completed,
            'alasan_penolakan': driver.alasan_penolakan,
            'rejected_documents': rejected_documents
        })
    except Driver.DoesNotExist:
        return Response({
            'error': 'Driver not found'
        }, status=status.HTTP_404_NOT_FOUND)

# Training Content ViewSets
class TrainingModuleViewSet(viewsets.ModelViewSet):
    queryset = TrainingModule.objects.all().order_by('created_at')
    serializer_class = TrainingModuleSerializer
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAuthenticated()]
        return [AllowAny()]

class TrainingContentViewSet(viewsets.ModelViewSet):
    queryset = TrainingContent.objects.all()
    serializer_class = TrainingContentSerializer
    permission_classes = [AllowAny]
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAdminOnly()]
        if self.action in ['list', 'retrieve']:
            return [AllowAny()]
        return [IsAuthenticated()]
    
    def get_queryset(self):
        module_id = self.request.query_params.get('module_id')
        if module_id:
            return TrainingContent.objects.filter(module_id=module_id)
        return TrainingContent.objects.all()

class TrainingQuizViewSet(viewsets.ModelViewSet):
    queryset = TrainingQuiz.objects.all()
    serializer_class = TrainingQuizSerializer
    permission_classes = [AllowAny]
    
    def get_permissions(self):
        if self.action in ['create', 'update', 'partial_update', 'destroy']:
            return [IsAdminOnly()]
        return [AllowAny()]
    
    def get_queryset(self):
        module_id = self.request.query_params.get('module_id')
        if module_id:
            return TrainingQuiz.objects.filter(module_id=module_id)
        return TrainingQuiz.objects.all()

class DriverTrainingProgressViewSet(viewsets.ModelViewSet):
    queryset = DriverTrainingProgress.objects.all()
    serializer_class = DriverTrainingProgressSerializer
    permission_classes = [IsAuthenticated]
    
    def get_permissions(self):
        if self.action in ['start_module_guest', 'complete_content_guest', 'submit_quiz_guest']:
            return [AllowAny()]
        return [IsAuthenticated()]
    
    def get_queryset(self):
        if self.request.user.is_staff:
            return DriverTrainingProgress.objects.all()
        try:
            driver = Driver.objects.get(email=self.request.user.email)
            return DriverTrainingProgress.objects.filter(driver=driver)
        except Driver.DoesNotExist:
            return DriverTrainingProgress.objects.none()
    
    @action(detail=False, methods=['post'])
    def start_module(self, request):
        """Start a training module (authenticated)"""
        try:
            driver = Driver.objects.get(email=request.user.email)
            module_id = request.data.get('module_id')
            module = TrainingModule.objects.get(id=module_id)
            
            progress, created = DriverTrainingProgress.objects.get_or_create(
                driver=driver,
                module=module,
                defaults={
                    'completed_contents': [],
                    'quiz_answers': {},
                    'current_points': 0,
                    'total_points': 0
                }
            )
            
            if created or progress.total_points == 0:
                progress.total_points = progress.calculate_total_points()
                progress.save()
            
            return Response({
                'message': 'Module started' if created else 'Module already started',
                'progress_id': progress.id,
                'current_points': progress.current_points,
                'total_points': progress.total_points,
                'progress_percentage': progress.get_progress_percentage()
            })
        except (Driver.DoesNotExist, TrainingModule.DoesNotExist) as e:
            return Response({'error': str(e)}, status=400)
    
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def start_module_guest(self, request):
        """Start a training module for guest (during registration)"""
        try:
            module_id = request.data.get('module_id')
            module = TrainingModule.objects.get(id=module_id)
            
            # Calculate total points for the module
            contents = TrainingContent.objects.filter(module=module)
            quizzes = TrainingQuiz.objects.filter(module=module)
            total_points = sum(c.points for c in contents) + sum(q.points for q in quizzes)
            
            return Response({
                'message': 'Module data loaded',
                'module_id': module.id,
                'current_points': 0,
                'total_points': total_points,
                'progress_percentage': 0
            })
        except TrainingModule.DoesNotExist as e:
            return Response({'error': str(e)}, status=400)
    
    @action(detail=False, methods=['post'])
    def complete_content(self, request):
        """Mark content as completed (authenticated)"""
        try:
            driver = Driver.objects.get(email=request.user.email)
            module_id = request.data.get('module_id')
            content_id = request.data.get('content_id')
            
            progress = DriverTrainingProgress.objects.get(
                driver=driver,
                module_id=module_id
            )
            
            if content_id not in progress.completed_contents:
                content = TrainingContent.objects.get(id=content_id)
                progress.completed_contents.append(content_id)
                progress.current_points += content.points
                progress.save()
            
            return Response({
                'message': 'Content marked as completed',
                'current_points': progress.current_points,
                'total_points': progress.total_points,
                'progress_percentage': progress.get_progress_percentage()
            })
        except (Driver.DoesNotExist, DriverTrainingProgress.DoesNotExist, TrainingContent.DoesNotExist) as e:
            return Response({'error': str(e)}, status=400)
    
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def complete_content_guest(self, request):
        """Mark content as completed for guest (during registration)"""
        try:
            module_id = request.data.get('module_id')
            content_id = request.data.get('content_id')
            completed_contents = request.data.get('completed_contents', [])
            
            content = TrainingContent.objects.get(id=content_id)
            
            if content_id not in completed_contents:
                completed_contents.append(content_id)
            
            # Calculate current points
            contents = TrainingContent.objects.filter(id__in=completed_contents)
            current_points = sum(c.points for c in contents)
            
            # Calculate total points
            all_contents = TrainingContent.objects.filter(module_id=module_id)
            quizzes = TrainingQuiz.objects.filter(module_id=module_id)
            total_points = sum(c.points for c in all_contents) + sum(q.points for q in quizzes)
            
            progress_percentage = (current_points / total_points * 100) if total_points > 0 else 0
            
            return Response({
                'message': 'Content marked as completed',
                'completed_contents': completed_contents,
                'current_points': current_points,
                'total_points': total_points,
                'progress_percentage': progress_percentage
            })
        except TrainingContent.DoesNotExist as e:
            return Response({'error': str(e)}, status=400)
    
    @action(detail=False, methods=['post'])
    def submit_quiz(self, request):
        """Submit quiz answers (authenticated)"""
        try:
            driver = Driver.objects.get(email=request.user.email)
            module_id = request.data.get('module_id')
            answers = request.data.get('answers', {})  # {quiz_id: answer}
            
            progress = DriverTrainingProgress.objects.get(
                driver=driver,
                module_id=module_id
            )
            
            # Calculate points from quiz
            quizzes = TrainingQuiz.objects.filter(module_id=module_id)
            quiz_points = 0
            correct_answers = 0
            total_questions = quizzes.count()
            
            for quiz in quizzes:
                if str(quiz.id) in answers and answers[str(quiz.id)] == quiz.correct_answer:
                    correct_answers += 1
                    quiz_points += quiz.points
            
            # Update progress with quiz points
            progress.quiz_answers = answers
            progress.current_points += quiz_points
            
            # Check if 100% completion achieved
            progress_percentage = progress.get_progress_percentage()
            if progress_percentage >= 100:
                progress.is_completed = True
                progress.completed_at = timezone.now()
            
            progress.save()
            
            return Response({
                'quiz_points': quiz_points,
                'correct_answers': correct_answers,
                'total_questions': total_questions,
                'current_points': progress.current_points,
                'total_points': progress.total_points,
                'progress_percentage': progress_percentage,
                'completed': progress.is_completed,
                'can_continue': progress_percentage >= 100
            })
        except (Driver.DoesNotExist, DriverTrainingProgress.DoesNotExist) as e:
            return Response({'error': str(e)}, status=400)
    
    @action(detail=False, methods=['post'], permission_classes=[AllowAny])
    def submit_quiz_guest(self, request):
        """Submit quiz answers for guest (during registration)"""
        try:
            module_id = request.data.get('module_id')
            answers = request.data.get('answers', {})  # {quiz_id: answer}
            completed_contents = request.data.get('completed_contents', [])
            
            # Calculate points from quiz
            quizzes = TrainingQuiz.objects.filter(module_id=module_id)
            quiz_points = 0
            correct_answers = 0
            total_questions = quizzes.count()
            
            for quiz in quizzes:
                if str(quiz.id) in answers and answers[str(quiz.id)] == quiz.correct_answer:
                    correct_answers += 1
                    quiz_points += quiz.points
            
            # Calculate total points
            contents = TrainingContent.objects.filter(id__in=completed_contents)
            content_points = sum(c.points for c in contents)
            current_points = content_points + quiz_points
            
            all_contents = TrainingContent.objects.filter(module_id=module_id)
            all_quizzes = TrainingQuiz.objects.filter(module_id=module_id)
            total_points = sum(c.points for c in all_contents) + sum(q.points for q in all_quizzes)
            
            progress_percentage = (current_points / total_points * 100) if total_points > 0 else 0
            
            return Response({
                'quiz_points': quiz_points,
                'correct_answers': correct_answers,
                'total_questions': total_questions,
                'current_points': current_points,
                'total_points': total_points,
                'progress_percentage': progress_percentage,
                'completed': progress_percentage >= 100,
                'can_continue': progress_percentage >= 100
            })
        except Exception as e:
            return Response({'error': str(e)}, status=400)

@api_view(['POST'])
@permission_classes([IsAdminOnly])
def create_driver_account(request):
    """Create driver account by admin"""
    try:
        email = request.data.get('email')
        password = request.data.get('password')
        status = request.data.get('status', 'training')
        
        if not email or not password:
            return Response({
                'error': 'Email and password are required'
            }, status=400)
        
        # Check if user or driver already exists
        if User.objects.filter(username=email).exists():
            return Response({
                'error': 'User account with this email already exists'
            }, status=400)
        
        if Driver.objects.filter(email=email).exists():
            return Response({
                'error': 'Driver with this email already exists'
            }, status=400)
        
        # Create user account
        user = User.objects.create_user(
            username=email,
            email=email,
            password=password
        )
        
        # Create driver record
        driver = Driver.objects.create(
            nama='',  # Will be filled during registration
            email=email,
            no_hp='',
            alamat='',
            ttl=datetime.strptime('1990-01-01', '%Y-%m-%d').date(),
            nik='',
            no_sim='',
            jenis_sim='',
            no_bpjs='',
            nama_kontak_darurat='',
            nomor_kontak_darurat='',
            hubungan_kontak_darurat='',
            status=status
        )
        
        return Response({
            'id': driver.id_driver,
            'email': email,
            'status': status,
            'message': 'Driver account created successfully'
        }, status=201)
        
    except Exception as e:
        return Response({
            'error': str(e)
        }, status=400)

@api_view(['POST'])
@permission_classes([IsAdminOnly])
def update_driver_status(request, driver_id):
    """Update driver status via direct API call"""
    try:
        driver = Driver.objects.get(id_driver=driver_id)
        new_status = request.data.get('status')
        rejection_reason = request.data.get('rejection_reason', '')
        
        if new_status not in ['active', 'pending', 'training', 'suspended', 'rejected']:
            return Response({'error': 'Invalid status'}, status=400)
        
        driver.status = new_status
        
        if new_status == 'rejected' and rejection_reason:
            driver.alasan_penolakan = rejection_reason
        elif new_status != 'rejected':
            driver.alasan_penolakan = None
        
        driver.save()
        
        return Response({
            'status': new_status,
            'message': f'Driver status updated to {new_status}',
            'rejection_reason': driver.alasan_penolakan
        })
        
    except Driver.DoesNotExist:
        return Response({'error': 'Driver not found'}, status=404)
    except Exception as e:
        return Response({'error': str(e)}, status=400)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def update_rejected_documents(request):
    """Update specific documents for rejected driver"""
    try:
        driver = Driver.objects.get(email=request.user.email)
        
        if driver.status != 'rejected':
            return Response({'error': 'Driver is not in rejected status'}, status=400)
        
        data = request.data
        updated_fields = []
        
        # Update specific document fields
        if 'foto_ktp' in data:
            driver.foto_ktp = data['foto_ktp']
            updated_fields.append('KTP')
        if 'foto_sim' in data:
            driver.foto_sim = data['foto_sim']
            updated_fields.append('SIM')
        if 'foto_bpjs' in data:
            driver.foto_bpjs = data['foto_bpjs']
            updated_fields.append('BPJS')
        if 'foto_sertifikat' in data:
            driver.foto_sertifikat = data['foto_sertifikat']
            updated_fields.append('Sertifikat')
        if 'foto_profil' in data:
            driver.foto_profil = data['foto_profil']
            updated_fields.append('Foto Profil')
        
        # Update related data fields
        if 'nik' in data:
            driver.nik = data['nik']
        if 'nama' in data:
            driver.nama = data['nama']
        if 'ttl' in data:
            driver.ttl = datetime.strptime(data['ttl'], '%Y-%m-%d').date()
        if 'no_sim' in data:
            driver.no_sim = data['no_sim']
        if 'jenis_sim' in data:
            driver.jenis_sim = data['jenis_sim']
        if 'tanggal_kedaluarsa_sim' in data:
            driver.tanggal_kedaluarsa_sim = datetime.strptime(data['tanggal_kedaluarsa_sim'], '%Y-%m-%d').date()
        if 'no_bpjs' in data:
            driver.no_bpjs = data['no_bpjs']
        if 'tanggal_kedaluarsa_bpjs' in data:
            driver.tanggal_kedaluarsa_bpjs = datetime.strptime(data['tanggal_kedaluarsa_bpjs'], '%Y-%m-%d').date()
        if 'no_sertifikat' in data:
            driver.no_sertifikat = data['no_sertifikat']
        if 'tanggal_kedaluarsa_sertifikat' in data:
            driver.tanggal_kedaluarsa_sertifikat = datetime.strptime(data['tanggal_kedaluarsa_sertifikat'], '%Y-%m-%d').date()
        
        # Don't change status - keep as rejected until all documents are fixed
        driver.save()
        
        send_driver_event('driver_document_updated', driver.id_driver)
        
        return Response({
            'message': f'Document updated successfully: {", ".join(updated_fields)}',
            'status': 'rejected'
        })
        
    except Driver.DoesNotExist:
        return Response({'error': 'Driver not found'}, status=404)
    except Exception as e:
        return Response({'error': str(e)}, status=400)

@api_view(['POST'])
@permission_classes([IsAuthenticated])
def complete_rejected_documents(request):
    """Complete all rejected document fixes and change status to pending"""
    try:
        driver = Driver.objects.get(email=request.user.email)
        
        if driver.status != 'rejected':
            return Response({'error': 'Driver is not in rejected status'}, status=400)
        
        # Change status to pending and clear rejection reason
        driver.status = 'pending'
        driver.alasan_penolakan = None
        driver.save()
        
        send_driver_event('driver_documents_completed', driver.id_driver)
        
        return Response({
            'message': 'All documents completed successfully',
            'status': 'pending'
        })
        
    except Driver.DoesNotExist:
        return Response({'error': 'Driver not found'}, status=404)
    except Exception as e:
        return Response({'error': str(e)}, status=400)

@api_view(['POST'])
@permission_classes([AllowAny])
def complete_training(request):
    """Mark training as completed and update driver status"""
    try:
        email = request.data.get('email')
        driver = Driver.objects.get(email=email)
        
        # For guest users, create completed training progress records
        if driver.status == 'training':
            modules = TrainingModule.objects.filter(is_active=True)
            
            for module in modules:
                progress, created = DriverTrainingProgress.objects.get_or_create(
                    driver=driver,
                    module=module,
                    defaults={
                        'completed_contents': [],
                        'quiz_answers': {},
                        'current_points': 0,
                        'total_points': 0,
                        'is_completed': True,
                        'completed_at': timezone.now()
                    }
                )
                
                if not progress.is_completed:
                    # Calculate total points and mark as completed
                    progress.total_points = progress.calculate_total_points()
                    progress.current_points = progress.total_points
                    progress.is_completed = True
                    progress.completed_at = timezone.now()
                    progress.save()
        
        # Check if all modules are completed
        total_modules = TrainingModule.objects.filter(is_active=True).count()
        completed_modules = DriverTrainingProgress.objects.filter(
            driver=driver,
            is_completed=True
        ).count()
        
        if completed_modules >= total_modules:
            driver.status = 'pending'
            driver.save()
            
            send_driver_event('training_completed', driver.id_driver)
            
            return Response({
                'message': 'Training completed successfully',
                'status': 'pending'
            })
        else:
            return Response({
                'error': 'Not all training modules completed',
                'completed': completed_modules,
                'total': total_modules
            }, status=400)
            
    except Driver.DoesNotExist:
        return Response({'error': 'Driver not found'}, status=404)
    except Exception as e:
        return Response({'error': str(e)}, status=400)

@api_view(['POST'])
@permission_classes([IsAdminOnly])
def cleanup_orphaned_users(request):
    """Clean up user accounts that don't have corresponding driver records"""
    try:
        # Get all users except admin
        all_users = User.objects.exclude(is_staff=True)
        
        # Get all driver emails
        driver_emails = set(Driver.objects.values_list('email', flat=True))
        
        orphaned_users = []
        for user in all_users:
            if user.email not in driver_emails:
                orphaned_users.append(user)
        
        if orphaned_users:
            deleted_count = 0
            deleted_emails = []
            for user in orphaned_users:
                deleted_emails.append(user.email)
                # Delete auth tokens first
                Token.objects.filter(user=user).delete()
                # Then delete the user
                user.delete()
                deleted_count += 1
            
            print(f"Cleaned up {deleted_count} orphaned users: {deleted_emails}")
            return Response({
                'message': f'Cleaned up {deleted_count} orphaned user accounts: {", ".join(deleted_emails)}',
                'deleted_count': deleted_count,
                'deleted_emails': deleted_emails
            })
        else:
            return Response({
                'message': 'No orphaned users found',
                'deleted_count': 0,
                'deleted_emails': []
            })
            
    except Exception as e:
        return Response({'error': str(e)}, status=400)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_driver_statistics(request):
    """Get driver statistics for profile display"""
    try:
        driver = Driver.objects.get(email=request.user.email)
        
        # Get statistics
        avg_rating = driver.get_average_rating()
        total_trips = driver.get_total_trips()
        experience_years = driver.get_experience_years()
        
        # Get recent ratings
        recent_ratings = RatingDriver.objects.filter(id_driver=driver).order_by('-timestamp')[:5]
        ratings_data = []
        for rating in recent_ratings:
            ratings_data.append({
                'rating': rating.rating,
                'ulasan': rating.ulasan,
                'timestamp': rating.timestamp,
                'pelanggan': rating.id_pelanggan.nama
            })
        
        return Response({
            'id_driver': driver.id_driver,
            'nama': driver.nama,
            'kota': driver.kota,
            'foto_profil': driver.foto_profil,
            'average_rating': avg_rating,
            'total_trips': total_trips,
            'experience_years': experience_years,
            'recent_ratings': ratings_data,
            'wkt_daftar': driver.wkt_daftar
        })
        
    except Driver.DoesNotExist:
        return Response({'error': 'Driver not found'}, status=404)
    except Exception as e:
        return Response({'error': str(e)}, status=400)

@api_view(['GET'])
@permission_classes([IsAuthenticated])
def get_driver_trips(request):
    """Get trip history for authenticated driver"""
    try:
        driver = Driver.objects.get(email=request.user.email)
        
        # Get completed delivery orders for this driver
        trips = DeliveryOrder.objects.filter(
            id_driver=driver,
            status__in=['completed', 'delivered', 'selesai']
        ).select_related('id_sales_order', 'id_armada').order_by('-tanggal_kirim')
        
        trips_data = []
        for trip in trips:
            # Get sales order details
            sales_order = trip.id_sales_order
            
            trips_data.append({
                'id_delivery_order': trip.id_delivery_order,
                'tanggal_kirim': trip.tanggal_kirim,
                'status': trip.status,
                'alamat_pengiriman': sales_order.alamat_pengiriman if sales_order else 'Alamat tidak tersedia',
                'total_harga': float(sales_order.total_harga_order) if sales_order else 0,
                'armada': {
                    'nomor_polisi': trip.id_armada.nomor_polisi,
                    'jenis_armada': trip.id_armada.jenis_armada
                } if trip.id_armada else None,
                'pelanggan': sales_order.id_pelanggan.nama if sales_order and sales_order.id_pelanggan else 'Pelanggan tidak diketahui'
            })
        
        return Response(trips_data)
        
    except Driver.DoesNotExist:
        return Response({'error': 'Driver not found'}, status=404)
    except Exception as e:
        return Response({'error': str(e)}, status=400)

@api_view(['GET'])
@permission_classes([IsAdminOnly])
def check_database_sync(request):
    """Check database synchronization status"""
    try:
        # Get all users and drivers
        all_users = User.objects.exclude(is_staff=True)
        all_drivers = Driver.objects.all()
        
        # Get driver emails
        driver_emails = set(Driver.objects.values_list('email', flat=True))
        
        # Find orphaned users
        orphaned_users = []
        for user in all_users:
            if user.email not in driver_emails:
                orphaned_users.append({
                    'id': user.id,
                    'username': user.username,
                    'email': user.email
                })
        
        # Find drivers without users
        user_emails = set(User.objects.values_list('email', flat=True))
        drivers_without_users = []
        for driver in all_drivers:
            if driver.email not in user_emails:
                drivers_without_users.append({
                    'id': driver.id_driver,
                    'email': driver.email,
                    'nama': driver.nama
                })
        
        return Response({
            'total_users': all_users.count(),
            'total_drivers': all_drivers.count(),
            'orphaned_users_count': len(orphaned_users),
            'orphaned_users': orphaned_users,
            'drivers_without_users_count': len(drivers_without_users),
            'drivers_without_users': drivers_without_users,
            'is_synchronized': len(orphaned_users) == 0 and len(drivers_without_users) == 0
        })
        
    except Exception as e:
        return Response({'error': str(e)}, status=400)