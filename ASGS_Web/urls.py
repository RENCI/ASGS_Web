"""ASGS URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/2.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.conf.urls import url
from django.contrib import admin
from django.contrib.auth import views as auth_views
from django.urls import path

from ASGS_Mon import views as app_views

urlpatterns = [
   path('', app_views.custom_login),
   url(r'^about', app_views.about, name='about'),
   url(r'^admin/', admin.site.urls),
   url(r'^changepassword/$', app_views.change_password, name='change_password'),
   url(r'^changepasswordcomplete/$', app_views.change_password_complete, name='change_password_complete'),
   url(r'^dataReq', app_views.dataReq, name='dataReq'),
   url(r'^index', app_views.index, name='index'),
   url(r'^login/$', app_views.custom_login),
   url(r'^logout/$', auth_views.logout, {'template_name': 'core/logout.html'}, name='logout'),
]
