Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # ======== LOBBY ========
  root "quests#index"
  patch "locale/:locale", to: "locales#update", as: :locale

  # Quest briefing pages (teacher's code — don't modify)
  scope :quests do
    get ":number", to: "quests#show",   as: :quest,        constraints: { number: /[1-5]/ }
  end

  # ======== QUEST 1: ========
  # Первый квест посвящён моделям, миграциям, связям и валидациям.
  # Здесь ничего добавлять не нужно — вся работа будет в app/models и db/migrate.

  # ======== QUEST 2: ========
  # Тут тоже ничего не нужно добавлять, вся работа будет в app/models и app/helpers.
end
