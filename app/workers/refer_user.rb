class ReferUser
  include Sidekiq::Worker

  def perform(user_id, reciever_mail)
    @user = User.find(user_id)
    @receiver = reciever_mail
    UserMailer.with(user: @user, receiver: @receiver).share_referral_code_email.deliver_later    
  end

end