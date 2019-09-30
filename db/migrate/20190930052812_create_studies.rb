class CreateStudies < ActiveRecord::Migration[5.2]
  def change
    create_table :studies do |t|
      t.string :user_id
      t.string :name
      t.string :completionurl
      t.string :completioncode
      t.string :studyurl
      t.time :allowedtime
      t.time :estimatetime
      t.integer :submission
      t.text :description
      t.timestamps
    end
  end
end
