json.extract! notification, :id, :message, :redirect_url, :created_at
json.message_123 notification_url(notification, format: :json)
