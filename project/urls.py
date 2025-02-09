import os

from django.contrib.auth.views import LoginView, logout_then_login
from django.conf import settings
from django.conf.urls import url, include
from django.contrib import admin
from rest_framework.authtoken import views
from django.views.static import serve 


urlpatterns = [
    url(r'^admin/', admin.site.urls),
    url('login/', LoginView.as_view(template_name='core/login.html', redirect_authenticated_user=True,
                                    extra_context={'brand': settings.BRAND_NAME}), name='login'),
    url('logout/', logout_then_login, {'login_url': '/login/?next=/'}, name='logout'),

    url(r'^api-token-auth/$', views.obtain_auth_token),
    url(r'^tz_detect/', include('tz_detect.urls')),
    url(r'^', include('core.urls')),
    url(r'^media/(?P<path>.*)$', serve,{'document_root': settings.MEDIA_ROOT}),
    url(r'^static/(?P<path>.*)$', serve,{'document_root': settings.STATIC_ROOT}),
    url(r'^node_modules/(?P<path>.*)$', serve,{'document_root': os.path.join(settings.BASE_DIR, 'node_modules')}),
]

#from django.conf.urls.static import static

#urlpatterns += 
#urlpatterns += 
#urlpatterns += 

#urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)
#urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
#urlpatterns += static('node_modules', document_root=os.path.join(settings.BASE_DIR, 'node_modules'))
