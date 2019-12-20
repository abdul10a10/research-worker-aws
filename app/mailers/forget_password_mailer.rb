class ForgetPasswordMailer < ApplicationMailer
  def forget_password_email
    @user = params[:user]
    @link = "http://winpowerllc.karyonsolutions.com/#/pages/updatepassword/#{@user.reset_password_token}"
    mail(to: @user.email, subject: "Forget password link")
  end

  def password_change_email
    @user = params[:user]
    mail(to: @user.email, subject: "Password Changed")
  end
end
