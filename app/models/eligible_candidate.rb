class EligibleCandidate < ApplicationRecord
  belongs_to :user
  belongs_to :study
  
  def start_time!
    self.is_attempted = 1
    self.start_time = Time.now.utc
    save!
  end   
    
  def submit_time!
    self.is_completed = 1
    self.submit_time = Time.now.utc
    save!
  end   
    
  def deleted_at!
    self.deleted_at = Time.now.utc
    save!
  end   
     
  # def is_allowed_time?
  #   (self.start_time + self.estimatetime.to_i.minutes) > Time.now.utc
  # end

end
