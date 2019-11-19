class EligibleCandidatesService

  def self.attempt_study(user_id, study_id)
    @eligible_candidate = EligibleCandidate.where(user_id: user_id, study_id: study_id).first
    @eligible_candidate.start_time!
    # send mail if maximum attempt limit reached
    study = @eligible_candidate.study
    eligible_candidates = study.eligible_candidates.where(is_attempted: '1', deleted_at: nil)
    attempted_candidate_count = eligible_candidates.count
    if attempted_candidate_count >= study.submission
      MailService.delay.study_completion_email(study.id)
      NotificationService.create_notification("Study Completion", study.user.id, 
        "Maximum attempt has been done for #{study.name}", "/candidatesubmissionlist/#{study.id}")
    end
  end
  
  # auto accept study after 21 days
  def self.auto_accept_study_submission(user_id, study_id)
    eligible_candidate = EligibleCandidate.where(user_id: user_id, study_id: study_id).first
    eligible_candidate.is_accepted = 1
    eligible_candidate.save
    # send mail
    study = eligible_candidate.study
    user = eligible_candidate.user
    MailService.delay.study_submission_accept_email(user.id, study.id)
    # send notification
    NotificationService.create_notification("Study Submission Accepted", user.id, 
      "Response of #{study.name} study has accepted", "/")
    # send reward after 4 days
    EligibleCandidatesService.delay(run_at: 4.days.from_now).send_accept_study_reward(user.id, study.id)
  end

  # method to send money for accepted studies
  def self.send_accept_study_reward(user_id, study_id)
    eligible_candidate = EligibleCandidate.where(user_id: user_id, study_id: study_id).first
    eligible_candidate.is_paid = 1
    eligible_candidate.save
    study = eligible_candidate.study
    user = eligible_candidate.user
    study.study_wallet = study.study_wallet - study.reward.to_i
    user.wallet = user.wallet + study.reward.to_i
    user.save
    study_name = study.name
    # track transaction
    transaction = Transaction.new
    transaction.transaction_id = SecureRandom.hex(10)
    transaction.study_id = study.id
    transaction.payment_type = "Participant study reward"
    transaction.sender_id = study.user_id
    transaction.receiver_id = user.id
    transaction.amount = study.reward.to_i
    transaction.description = "Study reward for " + study_name
    transaction.save
    # send notification
    NotificationService.create_notification("Study payment completed", user.id, 
      "Payment for #{study_name } study of #{study.reward} has been credited in your account", "/")
  end

  def referral_program(user)
    if User.find_by(user_referral_code: user.referral_code, deleted_at: nil).present?
      referring_user = User.find_by(user_referral_code: user.referral_code, deleted_at: nil)
      # send referral money to both account
      user.recieve_participant_reffer_amount!
      referring_user.recieve_participant_reffer_amount!
    end
  end
end