class UserMailer < ApplicationMailer
  default from: "10a10khan@gmail.com"

  def welcome_email
    @user = params[:user]
    @link = "http://karyonsolutions.com/research_work_front-end/#/welcome/#{@user.confirmation_token}"
    mail(to: @user.email, subject: "Welcome to Research Worker")
  end

  def user_registration_admin_email
    @user = params[:user]
    @admin_mail = "amisha.farkya@codoxysolutions.com"
    if @user.user_type = "participant"
      @link = "http://karyonsolutions.com/research_workAdmin_front-end/#/participantlist"
    else
      @link = "http://karyonsolutions.com/research_workAdmin_front-end/#/researcherlist"
    end
    mail(to: @admin_mail, subject: "New user registered")
  end

  def rejection_email
    @user = params[:user]
    @reason = params[:reason]
    mail(to: @user.email, subject: "Participation cancellation mail")
  end

  def share_referral_code_email
    @user = params[:user]
    @receiver = params[:receiver]
    @link = "registrationlink.com"
    mail(to: @receiver, subject: "Refer code for Research worker")

  end
end
