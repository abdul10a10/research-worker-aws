class UserMailer < ApplicationMailer
  default from: "10a10khan@gmail.com"

  def welcome_email
    @user = params[:user]
    @link = "https://research-worker-backend.herokuapp.com/welcome/#{@user.confirmation_token}"
    mail(to: @user.email, subject: "Welcome to Research Worker")
  end
end
