class StudyReject
  include Sidekiq::Worker

  def perform(study_id)
    @study = Study.find(study_id)
    @user = @study.user

    UserMailer.with(user: @user, study: @study).study_rejection_email.deliver_later
    @notification = Notification.new
    @notification.notification_type = "Study Rejected"
    @notification.user_id = @user.id
    @study_name = @study.name
    @notification.message = "Study " + @study_name +" has been rejected"
    @notification.redirect_url = "/studypublished/#{@study.id}"
    @notification.save
    
  end
end