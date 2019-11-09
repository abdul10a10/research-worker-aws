class StudyActivate
  include Sidekiq::Worker

  def perform(study_id)

    @study = Study.find(study_id)

    # send mail to researcher
    @user = @study.user
    UserMailer.with(user: @user, study: @study).study_published_email.deliver_later
    @notification = Notification.new
    @notification.notification_type = "Study Published"
    @notification.user_id = @user.id
    @study_name = @study.name
    @notification.message = "Study " + @study_name +" has been published"
    @notification.redirect_url = "/studyactive"
    @notification.save

    # Find audience
    @required_audience_list = Array.new
    @required_audience = User.where(user_type: "Participant", deleted_at: nil)
    @required_audience.each do |required_audience|
    @required_audience_list.push(required_audience.id)
    end

    if Audience.where(study_id: @study_id, deleted_at: nil).present?
      @study_audience = Audience.select("DISTINCT question_id").where(study_id: @study_id, deleted_at: nil)

      @study_audience.each do |study_audience|
        @audience = Audience.where(question_id: study_audience.question_id, study_id: @study_id, deleted_at: nil)
        @required_users_list = Array.new

        @audience.each do |audience|
          @required_users = Array.new
          @users = Response.where(question_id: audience.question_id, answer_id: audience.answer_id, deleted_at: nil)

          @users.each do |user|
            @required_users.push( user.user_id)
          end

          @required_users_list = @required_users_list + @required_users
        end

        @required_audience_list = @required_users_list & @required_audience_list

      end

    end

    @required_audience_list.each do |user_id|
      
      # send mail
      @user = User.find(user_id)
      UserMailer.with(user: @user, study: @study).new_study_invitation_email.deliver_later
      
      # send notification
      @notification = Notification.new
      @notification.notification_type = "Study Invitation"
      @notification.user_id = @user.id
      @study_name = @study.name
      @notification.message = "Invitation to participate in " + @study_name +" study"
      @notification.redirect_url = "/participantstudy"
      @notification.save
      
      #  update eligible candidate list
      @eligible_candidate = EligibleCandidate.new
      @eligible_candidate.user_id = @user.id
      @eligible_candidate.study_id = @study_id
      @eligible_candidate.save
    end

  end
end