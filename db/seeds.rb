# ============================================================
#  RailsOS — Quest Progress seeds
#  Initialise 5 quests: Quest 1 unlocked, 2-5 locked
# ============================================================

QuestProgress.find_or_create_by!(quest_number: 1) do |q|
  q.status      = "unlocked"
  q.unlocked_at = Time.current
end

(2..5).each do |n|
  QuestProgress.find_or_create_by!(quest_number: n) do |q|
    q.status = "locked"
  end
end

puts "Rails Quests initialised. Quest 1 — UNLOCKED. Quests 2-5 — LOCKED."
