class MailService

  def self.deactivate_user(user_id, reason)
    user = User.find(user_id)
    reason = reason
    UserMailer.with(user: user, reason: reason).rejection_email.deliver_later    
  end
  
  def self.share_referral_code(user_id, receiver)
    user = User.find(user_id)
    UserMailer.with(user: user, receiver: receiver).share_referral_code_email.deliver_later
  end

  def user_welcome_email(user_id)
    user = User.find(user_id)
    UserMailer.with(user: user).welcome_email.deliver_later
  end

  def user_registration_admin_email(user_id)
    user = User.find(user_id)
    UserMailer.with(user: @user).user_registration_admin_email.deliver_later
  end
end