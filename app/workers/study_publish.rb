class StudyPublish
  include Sidekiq::Worker

  def perform(study_id)

    # send mail and notification to researcher
    @study = Study.find(study_id)
    @user = @study.user
    UserMailer.with(user: @user, study: @study).study_published_email.deliver_later
    @notification = Notification.new
    @notification.notification_type = "Study Published"
    @notification.user_id = @user.id
    @study_name = @study.name
    @notification.message = "Study " + @study_name +" has been published"
    @notification.redirect_url = "/studyactive"
    @notification.save

  end

end