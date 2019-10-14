class UserMailer < ApplicationMailer
  default from: "10a10khan@gmail.com"

  def welcome_email
    @user = params[:user]
    @link = "http://winpowerllc.karyonsolutions.com/#/pages/verifyemail/#{@user.confirmation_token}"
    mail(to: @user.email, subject: "Welcome to Research Work")
  end

  def user_registration_admin_email
    @user = params[:user]
    @admin_mail = "amisha.farkya@codoxysolutions.com"
    @user_type = @user.user_type
    if @user_type == "Participant"
      @link = "http://winpowerllc.karyonsolutions.com/#/dashboards/overviewuser/#{@user.id}"
    else
      @link = "http://winpowerllc.karyonsolutions.com/#/dashboards/overviewresearcheruser/#{@user.id}"
    end
    mail(to: @admin_mail, subject: "New "+ @user_type +" registered")
  end

  def rejection_email
    @user = params[:user]
    @reason = params[:reason]
    mail(to: @user.email, subject: "Participation cancellation mail")
  end

  def share_referral_code_email
    @user = params[:user]
    @receiver = params[:receiver]
    @link = "http://winpowerllc.karyonsolutions.com/#/pages/signup"
    mail(to: @receiver, subject: "Refer code for Research work")
  end

  def new_study_invitation_email
    @user = params[:user]
    @study = params[:study]
    mail(to: @user.email, subject: "Invitation for new study")
  end

  def new_study_creation_email
    @user = params[:user]
    @study = params[:study]
    mail(to: @user.email, subject: "New study created")
  end
end
