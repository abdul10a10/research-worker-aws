class ForgetPasswordMailer < ApplicationMailer
  default from: "10a10khan@gmail.com"

  def forget_password_email
    @user = params[:user]
    @link = "www.abcd.com/#{@user.id}"
    mail(to: @user.email, subject: "Forget password link")
  end
end
