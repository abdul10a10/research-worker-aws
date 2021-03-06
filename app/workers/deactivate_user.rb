class DeactivateUser
  include Sidekiq::Worker

  def perform(user_id, reason)
    @user = User.find(user_id)
    @user.status = "deactive"
    @user.save
    @reason = reason
    UserMailer.with(user: @user, reason: @reason).rejection_email.deliver_later
  end
  
end