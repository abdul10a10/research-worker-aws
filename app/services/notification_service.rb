class NotificationService

  def self.create_notification(notification_type, user_id, message, redirect_url)
    notification = Notification.new
    notification.notification_type = notification_type
    notification.user_id = user_id
    notification.message = message
    notification.redirect_url = redirect_url
    notification.save
  end
  
end