from rest_framework import serializers
from .models import User, ChatGroup, Message, GroupMembership

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'roll_number', 'branch', 'year', 'section', 'group', 'is_cr', 'is_club_head', 'is_secretary']
        read_only_fields = ['id']

class MessageSerializer(serializers.ModelSerializer):
    sender = UserSerializer(read_only=True)
    reply_to = serializers.SerializerMethodField()
    
    class Meta:
        model = Message
        fields = ['id', 'group', 'sender', 'text', 'timestamp', 'is_edited', 'reply_to']
        read_only_fields = ['id', 'sender', 'timestamp']

    def get_reply_to(self, obj):
        if obj.reply_to:
            return {
                'id': obj.reply_to.id,
                'sender': obj.reply_to.sender.username,
                'text': obj.reply_to.text[:50] + '...' if len(obj.reply_to.text) > 50 else obj.reply_to.text
            }
        return None

class ChatGroupSerializer(serializers.ModelSerializer):
    members = UserSerializer(many=True, read_only=True)
    member_count = serializers.SerializerMethodField()
    last_message = serializers.SerializerMethodField()
    
    class Meta:
        model = ChatGroup
        fields = ['id', 'name', 'group_type', 'members', 'member_count', 'last_message', 'created_at', 'is_active']
        read_only_fields = ['id', 'created_at']

    def get_member_count(self, obj):
        return obj.members.count()

    def get_last_message(self, obj):
        last_message = obj.messages.last()
        if last_message:
            return {
                'text': last_message.text[:50] + '...' if len(last_message.text) > 50 else last_message.text,
                'sender': last_message.sender.username,
                'timestamp': last_message.timestamp
            }
        return None

class GroupMembershipSerializer(serializers.ModelSerializer):
    user = UserSerializer(read_only=True)
    group = ChatGroupSerializer(read_only=True)
    
    class Meta:
        model = GroupMembership
        fields = ['id', 'user', 'group', 'joined_at', 'is_admin', 'is_muted']
        read_only_fields = ['id', 'joined_at']
