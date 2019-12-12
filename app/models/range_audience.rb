class RangeAudience < ApplicationRecord
  belongs_to :study
  belongs_to :question

  def deleted_at!
    self.deleted_at = Time.now.utc
    save!
  end
end
