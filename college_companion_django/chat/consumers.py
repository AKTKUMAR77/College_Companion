import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from .models import ChatGroup, Message, User

class ChatConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.group_id = self.scope['url_route']['kwargs']['group_id']
        self.group_name = f'chat_{self.group_id}'
        
        await self.channel_layer.group_add(
            self.group_name,
            self.channel_name
        )
        
        await self.accept()
    
    async def disconnect(self, close_code):
        await self.channel_layer.group_discard(
            self.group_name,
            self.channel_name
        )
    
    async def receive(self, text_data):
        data = json.loads(text_data)
        message_type = data.get('type', 'message')
        
        if message_type == 'message':
            message = data.get('message', '')
            user = self.scope['user']
            
            if user.is_anonymous:
                await self.send(text_data=json.dumps({
                    'type': 'error',
                    'message': 'Authentication required'
                }))
                return
            
            message_obj = await self.save_message(user, message)
            
            await self.channel_layer.group_send(
                self.group_name,
                {
                    'type': 'chat_message',
                    'message': {
                        'id': message_obj.id,
                        'sender': user.username,
                        'text': message,
                        'timestamp': message_obj.timestamp.isoformat(),
                    }
                }
            )
    
    async def chat_message(self, event):
        message = event['message']
        
        await self.send(text_data=json.dumps({
            'type': 'message',
            'message': message
        }))
    
    @database_sync_to_async
    def save_message(self, user, message_text):
        try:
            group = ChatGroup.objects.get(id=self.group_id, members=user)
            return Message.objects.create(
                group=group,
                sender=user,
                text=message_text
            )
        except ChatGroup.DoesNotExist:
            return None
