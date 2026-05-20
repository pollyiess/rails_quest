# Этот класс является частью системы проверки квестов.
# Редактировать его не нужно, изменения могут нарушить работу системы проверки.

class QuestProgress < ApplicationRecord
  QUEST_NUMBERS = (1..5).freeze

  STATUSES = %w[locked unlocked accepted].freeze

  validates :quest_number, presence: true,
    numericality: { only_integer: true, in: 1..5 },
    uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  scope :ordered, -> { order(:quest_number) }

  def locked?   = status == "locked"
  def unlocked? = status == "unlocked"
  def accepted? = status == "accepted"

  def completed?
    accepted?
  end

  def meta(locale: I18n.locale)
    self.class.meta_for(quest_number, locale:)
  end

  def self.meta_for(number, locale: I18n.locale)
    scope = [ :quests, :meta, number ]

    {
      number: number,
      module_name: I18n.t(:module_name, scope:, locale:),
      title: I18n.t(:title, scope:, locale:),
      symptom: I18n.t(:symptom, scope:, locale:)
    }
  end

  def self.module_name_for(number, locale: I18n.default_locale)
    meta_for(number, locale:)[:module_name]
  end

  def self.unlock_next_after(number)
    next_quest = find_by(quest_number: number + 1)
    return unless next_quest&.locked?

    next_quest.update!(status: "unlocked", unlocked_at: Time.current)
  end
end
