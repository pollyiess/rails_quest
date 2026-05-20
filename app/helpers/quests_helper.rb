module QuestsHelper
  def quest_briefing_template(number)
    "quests/briefings/#{I18n.locale}/quest_#{number}"
  end
end
