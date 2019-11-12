class StudyMailer < ApplicationMailer
  def study_reinvitation_email
    @user = params[:user]
    @study = params[:study]
    @link = "http://winpowerllc.karyonsolutions.com/#/participantstudy"
    mail(to: @user.email, subject: "Exclusive invitation for new study")
  end

  def study_auto_activate_email
    @user = params[:user]
    @study = params[:study]
    mail(to: @user.email, subject: "Study Published")
  end

end
