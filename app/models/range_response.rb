class RangeResponse < ApplicationRecord
  belongs_to :user
  belongs_to :question

  def deleted_at!
    self.deleted_at = Time.now.utc
    save!
  end
end
