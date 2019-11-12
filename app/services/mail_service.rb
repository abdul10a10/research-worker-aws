class MailService

  def self.deactivate_user(user_id, reason)
    user = User.find(user_id)
    reason = reason
    UserMailer.with(user: user, reason: reason).rejection_email.deliver_later    
  end
  
  def self.share_referral_code(user_id, receiver)
    user = User.find(user_id)
    UserMailer.with(user: user, receiver: receiver).share_referral_code_email.deliver_later
  end

  def self.user_welcome_email(user_id)
    user = User.find(user_id)
    UserMailer.with(user: user).welcome_email.deliver_later
  end

  def self.user_registration_admin_email(user_id)
    user = User.find(user_id)
    UserMailer.with(user: @user).user_registration_admin_email.deliver_later
  end

  def self.new_study_invitation_email(user_id, study_id)
    user = User.find(user_id)
    study = Study.find(study_id)
    UserMailer.with(user: user, study: study).new_study_invitation_email.deliver_later
  end

  def self.study_published_email(study_id)
    study = Study.find(study_id)
    user = study.user
    UserMailer.with(user: user, study: study).study_published_email.deliver_later
  end

  def self.study_auto_activate_email(user_id, study_id)
    user = User.find(user_id)
    study = Study.find(study_id)
    StudyMailer.with(user: user, study: study).study_auto_activate_email.deliver_later
  end
  
  def self.new_study_creation_email(user_id, study_id)
    user = User.find(user_id)
    study = Study.find(study_id)
    UserMailer.with(user: user, study: study).new_study_creation_email.deliver_later
  end
  
  def self.study_reinvitation_email(user_id, study_id)
    user = User.find(user_id)
    study = Study.find(study_id)
    StudyMailer.with(user: user, study: study).study_reinvitation_email.deliver_later
  end
    
  def self.study_rejection_email(user_id, study_id)
    user = User.find(user_id)
    study = Study.find(study_id)
    UserMailer.with(user: user, study: study).study_rejection_email.deliver_later
  end
    
  def self.study_published_email(user_id, study_id)
    user = User.find(user_id)
    study = Study.find(study_id)
    UserMailer.with(user: user, study: study).study_published_email.deliver_later
  end
    
  def self.study_completion_email(study_id)
    study = Study.find(study_id)
    UserMailer.with(user: study.user, study: study).study_completion_email.deliver_later
  end

  def self.study_submission_accept_email(user_id, study_id)
    user = User.find(user_id)
    study = Study.find(study_id)
    UserMailer.with(user: user, study: study).study_submission_accept_email.deliver_now
  end

  def self.study_rejection_accept_email(user_id, study_id, eligible_candidate_id)
    user = User.find(user_id)
    study = Study.find(study_id)
    eligible_candidate = EligibleCandidate.find(eligible_candidate_id)
    UserMailer.with(user: user, study: study, eligible_candidate: eligible_candidate).study_rejection_accept_email.deliver_now
  end

  def self.message_email(user_id, message_id)
    user = User.find(user_id)
    message = Message.find(message_id)
    MessageMailer.with(user: user, message: message).message_email.deliver_later
  end

  def self.message_email(user_id)
    user = User.find(user_id)
    MessageMailer.with(user: user, message: message).message_email.deliver_later
  end

end