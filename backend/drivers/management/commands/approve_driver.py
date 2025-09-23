from django.core.management.base import BaseCommand
from django.contrib.auth.models import User
from drivers.models import Driver

class Command(BaseCommand):
    help = 'Approve pending driver registration'

    def add_arguments(self, parser):
        parser.add_argument('email', type=str, help='Driver email to approve')

    def handle(self, *args, **options):
        email = options['email']
        
        try:
            driver = Driver.objects.get(email=email, status='pending')
            user = User.objects.get(username=email)
            
            # Activate user and driver
            user.is_active = True
            user.save()
            
            driver.status = 'active'
            driver.save()
            
            self.stdout.write(
                self.style.SUCCESS(f'Driver {email} has been approved and activated')
            )
            
        except Driver.DoesNotExist:
            self.stdout.write(
                self.style.ERROR(f'No pending driver found with email {email}')
            )
        except User.DoesNotExist:
            self.stdout.write(
                self.style.ERROR(f'No user found with email {email}')
            )