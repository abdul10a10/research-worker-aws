class UserService

  def self.verify_user(user)
    user = user
    user.status = "active"
    user.verification_status = "1"
    user.save
    user.generate_referral_code!
    MailService.user_registration_admin_email(user.id)
    notification = Notification.new
    notification.notification_type = "Registration"
    admin = User.where(user_type: "Admin").first
    notification.user_id = admin.id
    user_type = user.user_type
    notification.message = "New " + user_type +" has registered"

    if user.user_type == "Participant"
      notification.redirect_url = "/dashboards/overviewuser/#{user.id}"
    elsif user.user_type == "Researcher"
      notification.redirect_url = "/dashboards/overviewresearcheruser/#{user.id}"
    end
    notification.save
  end

  def self.report
    total_paid_amount = 0
    end_time = Time.now.utc
    start_time = Time.now.beginning_of_month
    participant = Array.new
    researcher = Array.new
    month = Array.new
    study = Array.new
    indian_studies = Array.new
    uae_studies = Array.new
    other_country_studies = Array.new
    monthly_payment = Array.new
    i = 0

    loop do
      participant_user = User.where(created_at: start_time..end_time, user_type: "Participant",
        verification_status: '1', deleted_at: nil)
      researcher_user = User.where(created_at: start_time..end_time, user_type: "Researcher", 
        verification_status: '1', deleted_at: nil)
      studies = Study.where(created_at: start_time..end_time, deleted_at: nil)
      paid_studies = Study.where(created_at: start_time..end_time, is_paid: "1").order(id: :desc)
      paid_amount = 0
      paid_studies.each do |study|
        transaction = study.transactions.where(payment_type: "Study Payment").first
        if transaction.present?
          paid_amount = paid_amount + transaction.try(:amount)
        end
      end
      total_paid_amount += paid_amount

      indian_study = 0
      uae_study = 0
      other_country_study = 0
      studies.each do |study|
        if study.user.country == "India"
          indian_study += 1
        elsif study.user.country == "United Arab Emirates" || study.user.country == "UAE"
          uae_study += 1
        else
          other_country_study += 1
        end
      end
      participant.push(participant_user.count)
      researcher.push(researcher_user.count)
      study.push(studies.count)
      month.push(start_time.strftime("%B"))
      indian_studies.push(indian_study)
      uae_studies.push(uae_study)
      other_country_studies.push(other_country_study)
      monthly_payment.push(sprintf('%.2f', paid_amount))

      end_time = start_time
      start_time = start_time-1.month

      i += 1
      if i == 12
        break       
      end
      
    end

    report = { participant: participant.reverse, researcher:researcher.reverse, study: study.reverse, 
      month: month.reverse, UAE_studies: uae_studies.reverse, indian_studies: indian_studies.reverse, 
      monthly_payment: monthly_payment.reverse
    }
    return report
  end

  def self.participant_overview(user)
    user = user
    if Response.where(user_id: user.id, deleted_at: nil).present?
      demographics = Array.new
      question_ids = user.responses.select("DISTINCT question_id").where(deleted_at: nil).map(&:question_id)
      question_ids.each do |question_id|
        response = Response.where(user_id: user.id, question_id: question_id, deleted_at: nil)
        question = Question.find(question_id)
        answers = Array.new
        response.each do |response|
          answer = Answer.find(response.answer_id)
          answers.push(answer.description)
        end
        demographics.push({
          question: question,
          answer: answers
        })
      end
    end
    seen_studies = user.eligible_candidates.where(is_seen: "1", deleted_at: nil)
    attempted_studies = user.eligible_candidates.where(is_attempted: "1", deleted_at: nil)
    accepted_studies = user.eligible_candidates.where(is_accepted: "1", deleted_at: nil)
    rejected_studies = user.eligible_candidates.where(is_accepted: "0", deleted_at: nil)
    submitted_studies = user.eligible_candidates.where(is_completed: "1", deleted_at: nil)
    result = {user: user, demographics: demographics, seen_studies: seen_studies.count, 
      attempted_studies: attempted_studies.count, accepted_studies: accepted_studies.count,
      rejected_studies: rejected_studies.count, submitted_studies: submitted_studies.count
    }
    return result
  end

  def self.researcher_overview(user)
    total_studies = user.studies.where(deleted_at: nil)
    active_studies = user.studies.where(is_active: "1", deleted_at: nil)
    studies = user.studies.where(is_paid: "1").order(id: :desc)
    transactions = Array.new
    studies.each do |study|
      transaction = study.transactions.where(payment_type: "Study Payment").first
      if transaction.present?        
        transactions.push(study: study,transaction: transaction)
      end
    end

    # report of researcher
    total_paid_amount = 0
    end_time = Time.now.utc
    start_time = Time.now.beginning_of_month
    month = Array.new
    monthly_study = Array.new
    monthly_payment = Array.new
    monthly_paid_study = Array.new
    i = 0
    loop do
      studies = user.studies.where(created_at: start_time..end_time, deleted_at: nil)
      paid_studies = user.studies.where(created_at: start_time..end_time, is_paid: "1").order(id: :desc)
      paid_amount = 0
      paid_studies.each do |study|
        transaction = study.transactions.where(payment_type: "Study Payment").first
        if transaction.present?
          paid_amount = paid_amount + transaction.try(:amount)
        end
      end
      total_paid_amount += paid_amount

      monthly_study.push(studies.count)
      monthly_paid_study.push(paid_studies.count)
      monthly_payment.push(sprintf('%.2f', paid_amount))
      month.push(start_time.strftime("%B"))
      end_time = start_time
      start_time = start_time-1.month

      # increment month
      i += 1
      if i == 12
        break       
      end
    end

    data = {user: user,total_paid_amount: sprintf('%.2f', total_paid_amount), month: month.reverse, monthly_study: monthly_study.reverse, 
      monthly_paid_study: monthly_paid_study.reverse, monthly_payment: monthly_payment.reverse, transactions: transactions,
      studies: user.studies.where(is_published: "1", deleted_at: nil).order(id: :desc)
    }
    return data
  end

end