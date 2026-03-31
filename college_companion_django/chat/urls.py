from django.urls import path, include
from rest_framework.routers import DefaultRouter
from .views import ChatGroupViewSet, MessageViewSet, UserRegistrationView, AutoGroupAllocationView

router = DefaultRouter()
router.register(r'groups', ChatGroupViewSet, basename='chatgroup')
router.register(r'groups/(?P<group_pk>[^/.]+)/messages', MessageViewSet, basename='message')

urlpatterns = [
    path('register/', UserRegistrationView.as_view(), name='user-register'),
    path('auto-allocate/', AutoGroupAllocationView.as_view(), name='auto-allocate'),
    path('', include(router.urls)),
]
