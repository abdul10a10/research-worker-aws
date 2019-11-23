class StudyService

  def self.admin_active_study_detail(study)
    required_participant = study.submission
    active_candidates = study.eligible_candidates.where(is_attempted: "1", deleted_at: nil)
    active_candidate = active_candidates.count
    active_candidate_list = Array.new
    active_candidates.each do |candidate|
      user = candidate.user
      active_candidate_list.push(user)
    end
    submitted_candidates = study.eligible_candidates.where(is_completed: "1", deleted_at: nil)
    submitted_candidate_count = submitted_candidates.count
    submitted_candidates_list = Array.new
    submitted_candidates.each do |candidate|
      user = candidate.user
      if (user.user_type == "Participant")
        submitted_candidates_list.push(user)
      end
    end

    accepted_candidates = study.eligible_candidates.where(is_completed: "1", is_accepted: "1", deleted_at: nil)
    accepted_candidate_count = accepted_candidates.count
    accepted_candidate_list = Array.new
    accepted_candidates.each do |candidate|
      user = candidate.user
      if (user.user_type == "Participant")
        accepted_candidate_list.push(user)
      end
    end

    rejected_candidates = study.eligible_candidates.where(is_completed: "1", is_accepted: "0", deleted_at: nil)
    rejected_candidate_count = rejected_candidates.count
    rejected_candidate_list = Array.new
    rejected_candidates.each do |candidate|
      user = candidate.user
      if (user.user_type == "Participant")
        rejected_candidate_list.push(user)
      end
    end

    admin_active_study_detail = { study: study, 
      required_participant: required_participant, 
      active_candidate: active_candidate, 
      active_candidate_list: active_candidate_list, 
      submitted_candidate_list: submitted_candidates_list,
      accepted_candidate_list: accepted_candidate_list,
      rejected_candidate_list: rejected_candidate_list,
      rejected_candidate_count: rejected_candidate_count,
      accepted_candidate_count: accepted_candidate_count,
      submitted_candidate_count: submitted_candidate_count
    }
    return admin_active_study_detail
  end

  def self.admin_new_study_list
    studies = Study.where(is_published: "1", is_complete: nil,deleted_at: nil).order(id: :desc)
    study_list = Array.new
    studies.each do |study|
      if study.is_active != "1"
        study_list.push(study)
      end
    end
    return study_list
  end
  
  def self.admin_inactive_study_list
    studies = Study.where(is_active: "0", is_complete: nil, deleted_at: nil).order(id: :desc)
    study_list = Array.new
    studies.each do |study|
      if study.is_published != "1"
        study_list.push(study)
      end
    end
    return study_list
  end

  def self.filtered_candidate(study)
    required_audience_list = Array.new
    if study.only_whitelisted == nil
      required_audience = User.where(user_type: "Participant", verification_status: '1', deleted_at: nil)
      required_audience.each do |required_audience|
        required_audience_list.push(required_audience)
      end
      if study.audiences.where(deleted_at: nil).present?
        study_audiences = study.audiences.select("DISTINCT question_id").where(deleted_at: nil)
        study_audiences.each do |study_audience|
          audiences = study.audiences.where(question_id: study_audience.question_id, deleted_at: nil)
          required_users_list = Array.new
          audiences.each do |audience|
            required_users = Array.new
            responses = Response.where(question_id: audience.question_id, answer_id: audience.answer_id, deleted_at: nil)
            responses.each do |response|
              required_users.push( response.user)
            end
            required_users_list = required_users_list | required_users
          end
          required_audience_list = required_users_list & required_audience_list
        end
      end
    end
    # blacklist user array
    blacklisted_user_list = Array.new
    blacklisted_users = study.blacklist_users.where(deleted_at: nil)
    blacklisted_users.each do |blacklisted_user|
      blacklisted_user_list.push(blacklisted_user.user)
    end
    # whitelist user array
    whitelisted_users = study.whitelist_users.where(deleted_at: nil)
    whitelisted_user_list = Array.new
    whitelisted_users.each do |whitelisted_user|
      whitelisted_user_list.push(whitelisted_user.user)
    end
    required_audience_list = required_audience_list | whitelisted_user_list
    required_audience_list = required_audience_list - blacklisted_user_list
    return required_audience_list
  end

  def self.find_audience(study)
    required_audience_list = StudyService.filtered_candidate(study)
    required_audience_list.each do |user|
      # send mail
      MailService.new_study_invitation_email(user.id, study.id)
      # send notification
      NotificationService.create_notification("Study Invitation", user.id, "Invitation to participate in #{study.name} study", "/participantstudy")
      eligible_candidate = EligibleCandidate.new(user_id: user.id, study_id: study.id)
      eligible_candidate.save
    end
  end

  # Auto activate study after 1 hours of study publish
  def self.auto_activate_study(study)
    if study.is_active != "1"
      study.is_active = 1
      study.save
      StudyService.find_audience(study)
      # send mail and notification to researcher
      user = study.user
      MailService.study_published_email(study.id)
      NotificationService.create_notification("Study Published", user.id, 
        "Study #{study.name} has been published", "/studyactive")
      # send mail and notification to Admin
      user = User.where(user_type: "Admin").first
      MailService.study_auto_activate_email(user.id, study.id)
      NotificationService.create_notification("Study Published", user.id, 
        "Study #{study.name} has been published", "/adminactivestudy")
    end
  end

  def self.pay_for_study(study, razorpay_payment_id, razorpay_order_id)
    # calculation
    amount = study.reward.to_i * study.submission
    tax = amount* 0.20
    commision = amount* 0.10
    total_amount = amount + tax + commision
    total_amount = sprintf('%.2f', total_amount)
    study_wallet = sprintf('%.2f', amount)
    study.is_paid = 1
    study.study_wallet = study_wallet
    study.save
    user = User.where(user_type: "Admin").first
    user.wallet = user.wallet + commision
    user.save
    study_name = study.name
    # track transaction for study
    transaction = Transaction.new
    transaction.transaction_id = razorpay_payment_id
    transaction.order_id = razorpay_order_id
    transaction.study_id = study.id
    transaction.payment_type = "Study Payment"
    transaction.sender_id = study.user_id
    transaction.amount = total_amount
    transaction.description = "Amount #{total_amount} has been paid for #{study_name} study"
    transaction.save
    # track transaction for Admin commision
    transaction = Transaction.new
    transaction.transaction_id = "pay_#{SecureRandom.hex(7)}"
    transaction.study_id = study.id
    transaction.payment_type = "Admin commision"
    transaction.sender_id = study.user_id
    transaction.receiver_id = user.id
    transaction.amount = commision
    transaction.description = "Payment for study #{study_name} of #{commision} has been added to your wallet"
    transaction.save
    NotificationService.create_notification("Study Payment commision", user.id, 
      "Payment for study #{study.name } of #{commision} has been added to your wallet", "/")
  end

  def self.publish_study(study)
    study.is_published = 1
    study.save
    # StudyPublish.perform_async(study.id)
    user = User.where(user_type: "Admin").first
    MailService.new_study_creation_email(user.id, study.id)
    NotificationService.create_notification("Study Created", user.id, 
      "New study #{study.name} created by #{user.first_name}", "/adminnewstudy")
    StudyService.delay(run_at: 1.hours.from_now).auto_activate_study(study)
  end

  def self.researcher_active_study_detail(study)
    required_participant = study.submission
    active_candidates = study.eligible_candidates.where(is_attempted: "1", deleted_at: nil)
    active_candidate = active_candidates.count
    submitted_candidates = study.eligible_candidates.where(is_completed: "1", deleted_at: nil)
    submitted_candidate_count = submitted_candidates.count
    accepted_candidates = study.eligible_candidates.where(is_completed: "1", is_accepted: "1", deleted_at: nil)
    accepted_candidate_count = accepted_candidates.count
    rejected_candidates = study.eligible_candidates.where(is_completed: "1", is_accepted: "0", deleted_at: nil)
    rejected_candidate_count = rejected_candidates.count
    data = { study: study, 
      required_participant: required_participant, 
      active_candidate: active_candidate, 
      rejected_candidate_count: rejected_candidate_count,
      accepted_candidate_count: accepted_candidate_count,
      submitted_candidate_count: submitted_candidate_count
    }
    return data
  end

  def self.republish(study)
    study.is_republish = 1
    study.save
    # StudyRepublish.perform_async(study.id)
    eligible_candidates = study.eligible_candidates.where(is_seen: "1", is_attempted: nil, deleted_at: nil)
    eligible_candidates.each do |eligible_candidate|
      user = eligible_candidate.user
      MailService.study_reinvitation_email(user.id, study.id)
      NotificationService.create_notification("Study reactivated", eligible_candidate.user.id, 
        "Study #{study.name} has been published", "/participantstudy")
    end
  end

  def self.accepted_candidate_list(study)
    accepted_candidates = study.eligible_candidates.where( is_completed: "1", is_accepted: "1", deleted_at: nil)
    accepted_candidate_count = accepted_candidates.count
    accepted_candidate_list = Array.new
    accepted_candidates.each do |candidate|
      user = candidate.user
      if (user.user_type == "Participant")
        accepted_candidate_list.push(user)
      end
    end
    rejected_candidates = study.eligible_candidates.where(is_completed: "1", is_accepted: "0", deleted_at: nil)
    rejected_candidate_count = rejected_candidates.count
    rejected_candidate_list = Array.new
    rejected_candidates.each do |candidate|
      user = candidate.user
      if (user.user_type == "Participant")
        rejected_candidate_list.push(user)
      end
    end
    data = { accepted_candidate_list: accepted_candidate_list, rejected_candidate_list: rejected_candidate_list}
    return data
    
  end

  def self.track_active_study_list(user)
    studies = user.studies.where(is_active: "1", is_complete: nil, deleted_at: nil).order(id: :desc)
    study_list = Array.new
    studies.each do |study|
      seen_candidates = study.eligible_candidates.where(is_seen: "1", deleted_at: nil)
      attempted_candidates = study.eligible_candidates.where(is_attempted: "1", deleted_at: nil)
      submitted_candidates = study.eligible_candidates.where(is_completed: "1", deleted_at: nil)
      accepted_candidates = study.eligible_candidates.where(is_accepted: "1", deleted_at: nil)
      rejected_candidates = study.eligible_candidates.where(is_accepted: "0", deleted_at: nil)
      study_list.push(
        study: study,
        seen_candidates: seen_candidates.count,
        attempted_candidates: attempted_candidates.count,
        submitted_candidates: submitted_candidates.count,
        accepted_candidates: accepted_candidates.count,
        rejected_candidates: rejected_candidates.count
      )
    end
    return study_list
  end

  def self.participant_active_study_list(user)
    eligible_candidates = user.eligible_candidates.where(deleted_at: nil).order(id: :desc)
    studies = Array.new
    eligible_candidates.each do |eligible_candidate|
      eligible_study = eligible_candidate.study
      if eligible_study.is_complete == nil && eligible_study.is_active == "1" && eligible_study.deleted_at == nil && eligible_study.max_participation_date == nil
        if eligible_candidate.is_attempted == "1"
          studies.push( eligible_study: eligible_study, is_attempted: "yes" )
        else
          studies.push( eligible_study: eligible_study, is_attempted: "no" )
        end    
      elsif eligible_study.is_complete == nil && eligible_study.is_active == "1" && eligible_study.deleted_at == nil && (eligible_study.max_participation_date + 1.days) >= Time.now.utc 
        if eligible_candidate.is_attempted == "1"
          studies.push( eligible_study: eligible_study, is_attempted: "yes" )
        else
          studies.push( eligible_study: eligible_study, is_attempted: "no" )
        end
      end
    end
    data = { studies: studies.uniq}
    return data
  end

  def self.participant_active_study_detail(study, user)
    required_participant = study.submission
    active_candidates = study.eligible_candidates.where(is_attempted: "1", deleted_at: nil)
    rejected_candidates = study.eligible_candidates.where(is_accepted: "0", deleted_at: nil)
    if study.eligible_candidates.where(user_id: user.id ,is_attempted: "1", submit_time: nil, deleted_at: nil).present?
      eligible_candidate = study.eligible_candidates.where(user_id: user.id ,is_attempted: "1", submit_time: nil, deleted_at: nil).first
      estimatetime = study.estimatetime
      if ((eligible_candidate.start_time + estimatetime.to_i.minutes) > Time.now.utc)
        timer = eligible_candidate.start_time + estimatetime.to_i.minutes
        is_attempted = "yes"
      else
        is_attempted = "time-out"
      end
    elsif study.eligible_candidates.where(user_id: user.id ,is_completed: "1", deleted_at: nil).present?
      is_attempted = "completed"
    else
      is_attempted = "no"
    end
    active_candidate_count = active_candidates.count - rejected_candidates.count
    if active_candidate_count < required_participant
      study_status = "active"
    else
    study_status = "finished"
    end
    data = { study: study, required_participant: required_participant, active_candidate: active_candidate_count, 
      is_attempted: is_attempted, timer: timer, study_status: study_status}
    return data
  end

  def self.active_candidate_list(study)
    active_candidates = study.eligible_candidates.where(is_attempted: "1", deleted_at: nil)
    active_candidate = active_candidates.count
    active_candidate_list = Array.new
    active_candidates.each do |candidate|
      user = candidate.user
      active_candidate_list.push(user)
    end
    data = { active_candidate_list: active_candidate_list}
    return data
  end

  def self.submitted_candidate_list(study)
    submitted_candidates = study.eligible_candidates.where(is_completed: "1", deleted_at: nil)
    submitted_candidate_count = submitted_candidates.count
    submitted_candidate_list = Array.new
    submitted_candidates.each do |candidate|
      user = candidate.user
      if (user.user_type == "Participant")
        # completion_time = helpers.distance_of_time_in_words(candidate.submit_time , candidate.start_time)
        time_difference = candidate.submit_time - candidate.start_time
        completion_time = Time.at(time_difference.to_i.abs).utc.strftime("%H:%M:%S")
        estimate_min_time = candidate.start_time + study.allowedtime.to_i.minutes
        estimate_max_time = candidate.start_time + study.estimatetime.to_i.minutes

        if candidate.submit_time < estimate_min_time
          submission_status = "before-time"
        elsif candidate.submit_time > estimate_min_time && candidate.submit_time < estimate_max_time
          submission_status = "within-time"
        else
          submission_status = "after-time"
        end

        if candidate.is_accepted = "0"
          status = "rejected"
        elsif candidate.is_accepted = "1"
          status = "accepted"
        end
        submission = candidate.is_completed
        submitted_candidate_list.push(user: user, completion_time: completion_time, start_time: candidate.start_time,
          submission: submission, submission_status: submission_status, status: status)
      end
    end
    data = { submitted_candidate_list: submitted_candidate_list}
    return data
  end

  def self.reject_study(study,deactivate_reason )
    study.deactivate_reason = deactivate_reason
    study.is_active = 0
    study.is_published = 0
    study.save
    # StudyReject.perform_async(study.id)
    user = study.user
    MailService.study_rejection_email(user.id, study.id)
    NotificationService.create_notification("Study Rejected", user.id, "Study #{study.name} has been rejected", "/studypublished/#{study.id}")
  end

  def self.activate_study(study)
    study.is_active = "1"
    study.save
    # StudyActivate.perform_async(study.id)
    StudyService.find_audience(study)
    user = study.user
    MailService.study_published_email(user.id, study.id)
    NotificationService.create_notification("Study Published", user.id, 
      "Study #{study.name.upcase} has been activated", "/studyactive")
  end
end