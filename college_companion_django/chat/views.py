from rest_framework import viewsets, status, permissions
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from django.db.models import Q
from django.shortcuts import get_object_or_404
from .models import User, ChatGroup, Message, GroupMembership
from .serializers import UserSerializer, ChatGroupSerializer, MessageSerializer, GroupMembershipSerializer
from .utils import decode_roll_number

class UserRegistrationView(APIView):
    permission_classes = [permissions.AllowAny]
    
    def post(self, request):
        username = request.data.get('username')
        password = request.data.get('password')
        email = request.data.get('email')
        roll_number = request.data.get('roll_number')
        
        if not all([username, password, email, roll_number]):
            return Response({'error': 'All fields are required'}, status=status.HTTP_400_BAD_REQUEST)
        
        if User.objects.filter(username=username).exists():
            return Response({'error': 'Username already exists'}, status=status.HTTP_400_BAD_REQUEST)
        
        if User.objects.filter(roll_number=roll_number).exists():
            return Response({'error': 'Roll number already registered'}, status=status.HTTP_400_BAD_REQUEST)
        
        try:
            user_info = decode_roll_number(roll_number)
            if 'error' in user_info:
                return Response({'error': user_info['error']}, status=status.HTTP_400_BAD_REQUEST)
        except Exception as e:
            return Response({'error': 'Invalid roll number format'}, status=status.HTTP_400_BAD_REQUEST)
        
        user = User.objects.create_user(
            username=username,
            password=password,
            email=email,
            roll_number=roll_number,
            branch=user_info['branch'],
            year=user_info['year'],
            section=user_info.get('section'),
            group=user_info.get('group')
        )
        
        return Response(UserSerializer(user).data, status=status.HTTP_201_CREATED)

class ChatGroupViewSet(viewsets.ModelViewSet):
    serializer_class = ChatGroupSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        return ChatGroup.objects.filter(members=self.request.user, is_active=True)
    
    def perform_create(self, serializer):
        group = serializer.save(created_by=self.request.user)
        group.members.add(self.request.user)
        GroupMembership.objects.create(user=self.request.user, group=group, is_admin=True)
    
    @action(detail=True, methods=['post'])
    def join(self, request, pk=None):
        group = self.get_object()
        if group.members.filter(id=request.user.id).exists():
            return Response({'error': 'Already a member'}, status=status.HTTP_400_BAD_REQUEST)
        
        group.members.add(request.user)
        GroupMembership.objects.create(user=request.user, group=group)
        return Response({'message': 'Joined group successfully'})
    
    @action(detail=True, methods=['post'])
    def leave(self, request, pk=None):
        group = self.get_object()
        if not group.members.filter(id=request.user.id).exists():
            return Response({'error': 'Not a member'}, status=status.HTTP_400_BAD_REQUEST)
        
        group.members.remove(request.user)
        GroupMembership.objects.filter(user=request.user, group=group).delete()
        return Response({'message': 'Left group successfully'})
    
    @action(detail=False, methods=['get'])
    def my_groups(self, request):
        groups = self.get_queryset()
        serializer = self.get_serializer(groups, many=True)
        return Response(serializer.data)

class MessageViewSet(viewsets.ModelViewSet):
    serializer_class = MessageSerializer
    permission_classes = [permissions.IsAuthenticated]
    
    def get_queryset(self):
        group_id = self.kwargs.get('group_pk')
        if group_id:
            group = get_object_or_404(ChatGroup, id=group_id, members=self.request.user)
            return Message.objects.filter(group=group)
        return Message.objects.none()
    
    def perform_create(self, serializer):
        group_id = self.kwargs.get('group_pk')
        group = get_object_or_404(ChatGroup, id=group_id, members=self.request.user)
        serializer.save(sender=self.request.user, group=group)
    
    def create(self, request, *args, **kwargs):
        group_id = kwargs.get('group_pk')
        if not group_id:
            return Response({'error': 'Group ID is required'}, status=status.HTTP_400_BAD_REQUEST)
        
        group = get_object_or_404(ChatGroup, id=group_id, members=request.user)
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save(sender=request.user, group=group)
        
        return Response(serializer.data, status=status.HTTP_201_CREATED)

class AutoGroupAllocationView(APIView):
    permission_classes = [permissions.IsAuthenticated]
    
    def post(self, request):
        user = request.user
        
        if not user.section or not user.year or not user.branch:
            return Response({'error': 'Insufficient information for auto-allocation'}, status=status.HTTP_400_BAD_REQUEST)
        
        class_group_name = f"{user.year}_{user.branch}_{user.section}"
        
        group, created = ChatGroup.objects.get_or_create(
            name=class_group_name,
            group_type='class',
            defaults={'is_active': True}
        )
        
        if not group.members.filter(id=user.id).exists():
            group.members.add(user)
            GroupMembership.objects.get_or_create(user=user, group=group)
        
        all_classmates = User.objects.filter(
            year=user.year,
            branch=user.branch,
            section=user.section
        )
        
        for classmate in all_classmates:
            if not group.members.filter(id=classmate.id).exists():
                group.members.add(classmate)
                GroupMembership.objects.get_or_create(user=classmate, group=group)
        
        serializer = ChatGroupSerializer(group)
        return Response({
            'message': 'Auto-allocation completed',
            'group': serializer.data,
            'was_created': created
        })
