from django.contrib import admin
from .models import User, ChatGroup, Message, GroupMembership

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ['username', 'roll_number', 'branch', 'year', 'section', 'is_cr', 'is_club_head', 'is_secretary']
    list_filter = ['branch', 'year', 'section', 'is_cr', 'is_club_head', 'is_secretary']
    search_fields = ['username', 'roll_number']

@admin.register(ChatGroup)
class ChatGroupAdmin(admin.ModelAdmin):
    list_display = ['name', 'group_type', 'member_count', 'created_at', 'is_active']
    list_filter = ['group_type', 'is_active', 'created_at']
    search_fields = ['name']
    
    def member_count(self, obj):
        return obj.members.count()
    member_count.short_description = 'Members'

@admin.register(Message)
class MessageAdmin(admin.ModelAdmin):
    list_display = ['sender', 'group', 'text_preview', 'timestamp', 'is_edited']
    list_filter = ['timestamp', 'is_edited', 'group']
    search_fields = ['sender__username', 'text']
    
    def text_preview(self, obj):
        return obj.text[:50] + '...' if len(obj.text) > 50 else obj.text
    text_preview.short_description = 'Message'

@admin.register(GroupMembership)
class GroupMembershipAdmin(admin.ModelAdmin):
    list_display = ['user', 'group', 'joined_at', 'is_admin', 'is_muted']
    list_filter = ['is_admin', 'is_muted', 'joined_at']
    search_fields = ['user__username', 'group__name']
