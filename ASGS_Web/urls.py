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

from ASGS_Mon import views as app_view

urlpatterns = [
   url(r'^login/$', app_view.custom_login),
   url(r'^index', app_view.index, name='index'),
   url(r'^dataReq', app_view.dataReq, name='dataReq'),
   url(r'^logout/$', auth_views.logout, {'template_name': 'core/logout.html'}, name='logout'),
   url(r'^admin/', admin.site.urls),
   url(r'^/ASGS_Mon', app_view.index),
]
