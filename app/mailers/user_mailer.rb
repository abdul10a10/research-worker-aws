class UserMailer < ApplicationMailer
  default from: "10a10khan@gmail.com"

  def welcome_email
    @user = params[:user]
    @link = "http://localhost:4200/#/welcome/#{@user.confirmation_token}"
    mail(to: @user.email, subject: "Welcome to Research Worker")
  end

  def user_registration_admin_email
    @user = params[:user]
    @admin_mail = "amisha.farkya@codoxysolutions.com"
    if @user.user_type = "participant"
      @link = "http://localhost:4200/#/participantlist"
    else
      @link = "http://localhost:4200/#/researcherlist"
    end
    mail(to: @admin_mail, subject: "New user registered")
  end
end
