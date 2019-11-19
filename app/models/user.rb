class User < ApplicationRecord
  
  has_many :responses 
  has_many :notifications
  has_many :studies
  has_many :eligible_candidates
  has_many :whitelist_users
  has_many :blacklist_users
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable
  
  def generate_unique_id!
    self.research_worker_id = generate_token
    save!
  end

  def generate_password_token!
    self.reset_password_token = generate_token
    self.reset_password_sent_at = Time.now.utc
    save!
  end

  def send_accept_study_reward(reward)
    self.wallet = self.wallet + reward
    save!
  end

  def password_token_valid?
    (self.reset_password_sent_at + 3.hours) > Time.now.utc
  end

  def reset_password!(password)
    self.reset_password_token = nil
    self.password = password
    save!
  end

  def generate_email_confirmation_token!
    self.confirmation_token = generate_token
    self.confirmation_sent_at = Time.now.utc
    save!
  end

  def email_confirmation_valid?
    (self.confirmation_sent_at + 2.days) > Time.now.utc
  end

  def generate_referral_code!
    self.user_referral_code = generate_code
    save!
  end

  def validateparamsparticipant!
    (self.email != "") && (self.password != "") && (self.user_type != "") && (self.country != "") && (self.first_name != "") && (self.last_name != "")
  end

  def validateparamsresearcher!
    (self.email != "") && (self.password != "") && (self.user_type != "") && (self.country != "") && (self.first_name != "") && (self.last_name != "")&& (self.job_type != "")&& (self.password != "") && (self.university != "") && (self.department != "")&& (self.department != "") 
  end
  
  def recieve_participant_reffer_amount!
    self.wallet = self.wallet + 10
    save!
  end
  private

  def generate_token
    SecureRandom.hex(10)
  end

  def generate_code
    SecureRandom.hex(5)
  end
end
