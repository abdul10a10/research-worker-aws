class StudyRepublish
  include Sidekiq::Worker

  def perform(study_id)
    @study = Study.find(study_id)
    @eligible_candidates = @study.eligible_candidates.where(is_seen: "1", is_attempted: nil, deleted_at: nil)
    
    # send notification and mail
    @eligible_candidates.each do |eligible_candidate|
      # send email
      @user = eligible_candidate.user
      StudyMailer.with(user: @user, study: @study).study_reinvitation_email.deliver_later
      # send notification
      @notification = Notification.new
      @notification.notification_type = "Study has been activated again"
      @notification.user_id = eligible_candidate.user.id
      @study_name = @study.name
      @notification.message = "Study " + @study_name +" has been published"
      @notification.redirect_url = "/participantstudy"
      @notification.save
    end

  end
  
end