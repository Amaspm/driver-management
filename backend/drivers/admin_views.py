from django.shortcuts import render, redirect, get_object_or_404
from django.contrib.auth import authenticate, login, logout
from django.contrib.auth.decorators import login_required, user_passes_test
from django.contrib import messages
from django.http import JsonResponse
from django.urls import reverse
from .models import Driver, TrainingModule, TrainingContent, TrainingQuiz

def is_admin(user):
    return user.is_staff and user.is_superuser

def admin_login(request):
    if request.method == 'POST':
        username = request.POST.get('username')
        password = request.POST.get('password')
        
        user = authenticate(request, username=username, password=password)
        if user and user.is_staff and user.is_superuser:
            login(request, user)
            return redirect('/dashboard/')
        else:
            messages.error(request, 'Akses ditolak. Hanya admin yang dapat mengakses sistem ini.')
    
    return render(request, 'admin/simple_login.html')

@login_required
@user_passes_test(is_admin)
def admin_dashboard(request):
    drivers = Driver.objects.all().order_by('-wkt_daftar')
    return render(request, 'admin/dashboard.html', {'drivers': drivers})

@login_required
@user_passes_test(is_admin)
def admin_logout(request):
    logout(request)
    return redirect('/login/')

@login_required
@user_passes_test(is_admin)
def driver_detail(request, driver_id):
    driver = Driver.objects.get(id_driver=driver_id)
    return render(request, 'admin/driver_detail.html', {'driver': driver})

@login_required
@user_passes_test(is_admin)
def update_driver_status(request, driver_id):
    if request.method == 'POST':
        driver = Driver.objects.get(id_driver=driver_id)
        action = request.POST.get('action')
        alasan_penolakan = request.POST.get('alasan_penolakan', '')
        rejection_reasons = request.POST.getlist('rejection_reasons')
        
        if action == 'activate':
            driver.status = 'active'
            driver.alasan_penolakan = None
        elif action == 'suspend':
            driver.status = 'suspended'
        elif action == 'accept':
            driver.status = 'active'
            driver.alasan_penolakan = None
        elif action == 'reject':
            driver.status = 'rejected'
            # Combine checkbox reasons with additional text
            reasons = []
            if rejection_reasons:
                reasons.extend(rejection_reasons)
            if alasan_penolakan:
                reasons.append(alasan_penolakan)
            driver.alasan_penolakan = '; '.join(reasons) if reasons else None
        
        driver.save()
        messages.success(request, f'Status driver {driver.nama} berhasil diubah')
    
    return redirect('/dashboard/')

@login_required
@user_passes_test(is_admin)
def delete_driver(request, driver_id):
    if request.method == 'POST':
        try:
            driver = Driver.objects.get(id_driver=driver_id)
            driver_name = driver.nama
            
            # Delete related User account
            from django.contrib.auth.models import User
            try:
                user = User.objects.get(email=driver.email)
                user.delete()
            except User.DoesNotExist:
                pass
            
            # Delete driver
            driver.delete()
            messages.success(request, f'Driver {driver_name} berhasil dihapus')
        except Driver.DoesNotExist:
            messages.error(request, 'Driver tidak ditemukan')
    
    return redirect('/dashboard/')

# Training Content Management Views
@login_required
@user_passes_test(is_admin)
def training_management(request):
    modules = TrainingModule.objects.all().extra(
        select={'level_order': "CASE WHEN level='pemula' THEN 1 WHEN level='lanjutan' THEN 2 WHEN level='expert' THEN 3 ELSE 4 END"}
    ).order_by('level_order', 'created_at')
    return render(request, 'admin/training_management.html', {'modules': modules})

@login_required
@user_passes_test(is_admin)
def training_module_detail(request, module_id):
    module = get_object_or_404(TrainingModule, id=module_id)
    contents = module.contents.all().order_by('created_at')
    quizzes = module.quizzes.all().order_by('created_at')
    return render(request, 'admin/training_module_detail.html', {
        'module': module,
        'contents': contents,
        'quizzes': quizzes
    })

@login_required
@user_passes_test(is_admin)
def create_training_module(request):
    if request.method == 'POST':
        title = request.POST.get('title')
        description = request.POST.get('description')
        level = request.POST.get('level')
        instructor = request.POST.get('instructor')
        thumbnail = request.POST.get('thumbnail')
        module = TrainingModule.objects.create(
            title=title,
            description=description,
            level=level,
            instructor=instructor,
            thumbnail=thumbnail
        )
        
        messages.success(request, f'Modul training "{title}" berhasil dibuat')
        return redirect('training_module_detail', module_id=module.id)
    
    return render(request, 'admin/create_training_module.html')

@login_required
@user_passes_test(is_admin)
def add_training_content(request, module_id):
    module = get_object_or_404(TrainingModule, id=module_id)
    
    if request.method == 'POST':
        title = request.POST.get('title')
        content_type = request.POST.get('content_type')
        text_content = request.POST.get('text_content')
        media_content = request.POST.get('media_content')
        TrainingContent.objects.create(
            module=module,
            title=title,
            content_type=content_type,
            text_content=text_content,
            media_content=media_content,
            points=int(request.POST.get('points', 10))
        )
        
        messages.success(request, f'Konten "{title}" berhasil ditambahkan')
        return redirect('training_module_detail', module_id=module.id)
    
    return render(request, 'admin/add_training_content.html', {'module': module})

@login_required
@user_passes_test(is_admin)
def add_training_quiz(request, module_id):
    module = get_object_or_404(TrainingModule, id=module_id)
    
    if request.method == 'POST':
        question = request.POST.get('question')
        option_a = request.POST.get('option_a')
        option_b = request.POST.get('option_b')
        option_c = request.POST.get('option_c')
        option_d = request.POST.get('option_d')
        correct_answer = request.POST.get('correct_answer')
        explanation = request.POST.get('explanation')
        TrainingQuiz.objects.create(
            module=module,
            question=question,
            option_a=option_a,
            option_b=option_b,
            option_c=option_c,
            option_d=option_d,
            correct_answer=correct_answer,
            explanation=explanation,
            points=int(request.POST.get('points', 20))
        )
        
        messages.success(request, 'Quiz berhasil ditambahkan')
        return redirect('training_module_detail', module_id=module.id)
    
    return render(request, 'admin/add_training_quiz.html', {'module': module})

@login_required
@user_passes_test(is_admin)
def delete_training_module(request, module_id):
    if request.method == 'POST':
        module = get_object_or_404(TrainingModule, id=module_id)
        module.delete()
        messages.success(request, f'Modul "{module.title}" berhasil dihapus')
    return redirect('training_management')

@login_required
@user_passes_test(is_admin)
def delete_training_content(request, content_id):
    if request.method == 'POST':
        content = get_object_or_404(TrainingContent, id=content_id)
        module_id = content.module.id
        content.delete()
        messages.success(request, 'Konten berhasil dihapus')
        return redirect('training_module_detail', module_id=module_id)
    return redirect('training_management')

@login_required
@user_passes_test(is_admin)
def delete_training_quiz(request, quiz_id):
    if request.method == 'POST':
        quiz = get_object_or_404(TrainingQuiz, id=quiz_id)
        module_id = quiz.module.id
        quiz.delete()
        messages.success(request, 'Quiz berhasil dihapus')
        return redirect('training_module_detail', module_id=module_id)
    return redirect('training_management')

@login_required
@user_passes_test(is_admin)
def edit_training_content(request, content_id):
    content = get_object_or_404(TrainingContent, id=content_id)
    
    if request.method == 'POST':
        content.title = request.POST.get('title')
        content.content_type = request.POST.get('content_type')
        content.text_content = request.POST.get('text_content')
        content.media_content = request.POST.get('media_content')

        content.points = int(request.POST.get('points', 10))
        content.save()
        
        messages.success(request, 'Konten berhasil diupdate')
        return redirect('training_module_detail', module_id=content.module.id)
    
    return render(request, 'admin/edit_training_content.html', {'content': content})

@login_required
@user_passes_test(is_admin)
def edit_training_quiz(request, quiz_id):
    quiz = get_object_or_404(TrainingQuiz, id=quiz_id)
    
    if request.method == 'POST':
        quiz.question = request.POST.get('question')
        quiz.option_a = request.POST.get('option_a')
        quiz.option_b = request.POST.get('option_b')
        quiz.option_c = request.POST.get('option_c')
        quiz.option_d = request.POST.get('option_d')
        quiz.correct_answer = request.POST.get('correct_answer')
        quiz.explanation = request.POST.get('explanation')

        quiz.points = int(request.POST.get('points', 20))
        quiz.save()
        
        messages.success(request, 'Quiz berhasil diupdate')
        return redirect('training_module_detail', module_id=quiz.module.id)
    
    return render(request, 'admin/edit_training_quiz.html', {'quiz': quiz})