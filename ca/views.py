from django.shortcuts import render


def index(request):
    return render(request, 'ca/index.html')


def has_root_key(request):
    return render(request, 'ca/has_root_key.html')


def no_root_key(request):
    return render(request, 'ca/no_root_key.html')
