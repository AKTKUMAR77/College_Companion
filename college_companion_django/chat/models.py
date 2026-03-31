from django.db import models
from django.contrib.auth.models import AbstractUser
import json

class User(AbstractUser):
    roll_number = models.CharField(max_length=20, unique=True)
    branch = models.CharField(max_length=100)
    year = models.CharField(max_length=10)
    section = models.CharField(max_length=10, null=True, blank=True)
    group = models.CharField(max_length=10, null=True, blank=True)
    is_cr = models.BooleanField(default=False)
    is_club_head = models.BooleanField(default=False)
    is_secretary = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.username} ({self.roll_number})"

    def get_class_group(self):
        if self.section and self.year:
            return f"{self.year}_{self.branch}_{self.section}"
        return None

class ChatGroup(models.Model):
    name = models.CharField(max_length=200)
    group_type = models.CharField(max_length=50, choices=[
        ('class', 'Class Group'),
        ('club', 'Club'),
        ('council', 'Council'),
        ('general', 'General')
    ])
    members = models.ManyToManyField(User, related_name='chat_groups')
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, related_name='created_groups')
    created_at = models.DateTimeField(auto_now_add=True)
    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.name} ({self.group_type})"

class Message(models.Model):
    group = models.ForeignKey(ChatGroup, on_delete=models.CASCADE, related_name='messages')
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name='sent_messages')
    text = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)
    is_edited = models.BooleanField(default=False)
    reply_to = models.ForeignKey('self', on_delete=models.SET_NULL, null=True, blank=True, related_name='replies')

    class Meta:
        ordering = ['timestamp']

    def __str__(self):
        return f"{self.sender.username}: {self.text[:50]}..."

class GroupMembership(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    group = models.ForeignKey(ChatGroup, on_delete=models.CASCADE)
    joined_at = models.DateTimeField(auto_now_add=True)
    is_admin = models.BooleanField(default=False)
    is_muted = models.BooleanField(default=False)

    class Meta:
        unique_together = ['user', 'group']

    def __str__(self):
        return f"{self.user.username} in {self.group.name}"
