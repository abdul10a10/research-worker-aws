class MessageMailer < ApplicationMailer
  def message_email
    @user = params[:user]
    @message = params[:message]
    mail(to: @user.email, subject: @message.subject)
  end
end
