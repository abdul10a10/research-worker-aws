class AddResearchWorkerIdToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :research_worker_id, :string, limit: 30
    add_index :users, :research_worker_id, unique: true
  end
end
