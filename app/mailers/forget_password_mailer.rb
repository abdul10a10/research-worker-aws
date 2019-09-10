class ForgetPasswordMailer < ApplicationMailer
  default from: "10a10khan@gmail.com"

  def forget_password_email
    @user = params[:user]
    @link = "https://research-worker-backend.herokuapp.com/forgetpassword"
    mail(to: @user.email, subject: "Forget password link")
  end
end
