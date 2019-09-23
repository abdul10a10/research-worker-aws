class User < ApplicationRecord
  # acts_as_token_authenticatable
  # def generate_jwt
  #   JWT.encode({ id: id,
  #                exp: 5.hours.from_now.to_i },
  #              Rails.application.secrets.secret_key_base)
  # end
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable

  def generate_password_token!
    self.reset_password_token = generate_token
    self.reset_password_sent_at = Time.now.utc
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

  def validateparams!
    (self.email != "") && (self.password != "") && (self.job_type != "") && (self.user_type != "") && (self.country != "") && (self.first_name != "") && (self.last_name != "")
  end
  
  private

  def generate_token
    SecureRandom.hex(10)
  end

  def generate_code
    SecureRandom.hex(5)
  end
end
