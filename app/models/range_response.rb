class RangeResponse < ApplicationRecord
  belongs_to :user
  belongs_to :question
  belongs_to :range_answer

  def deleted_at!
    self.deleted_at = Time.now.utc
    save!
  end
end
