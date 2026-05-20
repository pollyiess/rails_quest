require "test_helper"

# Base helper for all Quest tests.
# Each quest test file inherits from QuestTestCase.
class QuestTestCase < ActionDispatch::IntegrationTest
  # Pretty header when tests run
  def self.quest_number
    name.match(/Quest(\d)/i)&.captures&.first&.to_i || 0
  end

  def self.module_name
    QuestProgress.module_name_for(quest_number) || "Unknown"
  end

  puts "\n\e[36m⚡ Quest #{quest_number} // #{module_name}\e[0m" if quest_number > 0
end
