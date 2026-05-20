class CreateQuestProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :quest_progresses do |t|
      t.integer :quest_number, null: false
      t.string  :status,       null: false, default: "locked"
      t.datetime :unlocked_at
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :quest_progresses, :quest_number, unique: true
  end
end
