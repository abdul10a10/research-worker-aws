class EligibleCandidate < ApplicationRecord

    def start_time!
        self.is_attempted = 1
        self.start_time = Time.now.utc
        save!
    end   
     
    def submit_time!
        self.submit_time = Time.now.utc
        save!
    end   
     
    def deleted_at!
        self.deleted_at = Time.now.utc
        save!
    end   
     
end
