class QuestsController < ApplicationController
  before_action :set_quest, only: %i[show]

  def index
    @quests = QuestProgress.ordered
    @test_results = load_test_results
  end

  def show
    @results = load_test_results[@quest.quest_number.to_s]
    redirect_to root_path, alert: t("quests.show.locked_alert") if @quest.locked?
  end


  private

  def set_quest
    @quest = QuestProgress.find_by!(quest_number: params[:number])
  end

  def load_test_results
    path = Rails.root.join("tmp/quest_status.json")
    return {} unless path.exist?

    JSON.parse(path.read)
  rescue JSON::ParserError
    {}
  end
end
