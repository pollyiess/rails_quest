class RemoveSubmittedAtFromQuestProgresses < ActiveRecord::Migration[8.1]
  def change
    remove_column :quest_progresses, :submitted_at, :datetime, if_exists: true
  end
end
