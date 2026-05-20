require "securerandom"
require_relative "quest_helper"


class Quest1AgentArchiveTest < QuestTestCase
  test "модель Agent и таблица agents существуют" do
    agent_class = assert_model_exists("Agent")
    assert agent_class < ApplicationRecord, "Agent должен наследоваться от ApplicationRecord"

    assert ActiveRecord::Base.connection.table_exists?(:agents),
      "Создай миграцию для таблицы agents и выполни её"

    assert_column :agents, :codename, :string
    assert_column :agents, :level, :integer
    assert_column :agents, :active, :boolean
  end

  test "модель Skill и таблица skills существуют" do
    skill_class = assert_model_exists("Skill")
    assert skill_class < ApplicationRecord, "Skill должен наследоваться от ApplicationRecord"

    assert ActiveRecord::Base.connection.table_exists?(:skills),
      "Создай миграцию для таблицы skills и выполни её"

    assert_column :skills, :name, :string
    assert_column :skills, :category, :string
  end

  test "модели Mission и AgentSkill существуют, таблицы созданы" do
    mission_class = assert_model_exists("Mission")
    agent_skill_class = assert_model_exists("AgentSkill")

    assert mission_class < ApplicationRecord, "Mission должен наследоваться от ApplicationRecord"
    assert agent_skill_class < ApplicationRecord, "AgentSkill должен наследоваться от ApplicationRecord"

    assert ActiveRecord::Base.connection.table_exists?(:missions),
      "Создай миграцию для таблицы missions и выполни её"
    assert ActiveRecord::Base.connection.table_exists?(:agent_skills),
      "Создай миграцию для таблицы agent_skills и выполни её"

    assert_column :missions, :title, :string
    assert_column :missions, :status, :string
    assert_column :missions, :agent_id, :integer

    assert_column :agent_skills, :agent_id, :integer
    assert_column :agent_skills, :skill_id, :integer
  end

  test "ассоциации между моделями настроены" do
    agent_class = assert_model_exists("Agent")
    skill_class = assert_model_exists("Skill")
    mission_class = assert_model_exists("Mission")
    agent_skill_class = assert_model_exists("AgentSkill")

    assert_association agent_class, :missions, :has_many
    assert_association agent_class, :agent_skills, :has_many
    assert_association agent_class, :skills, :has_many

    assert_association skill_class, :agent_skills, :has_many
    assert_association skill_class, :agents, :has_many

    assert_association mission_class, :agent, :belongs_to

    assert_association agent_skill_class, :agent, :belongs_to
    assert_association agent_skill_class, :skill, :belongs_to

    skills_reflection = agent_class.reflect_on_association(:skills)
    assert_equal :agent_skills, skills_reflection.options[:through],
      "Agent должен связываться со skills через :agent_skills"

    agents_reflection = skill_class.reflect_on_association(:agents)
    assert_equal :agent_skills, agents_reflection.options[:through],
      "Skill должен связываться с agents через :agent_skills"
  end

  test "в базе есть внешние ключи и уникальные индексы" do
    connection = ActiveRecord::Base.connection

    assert connection.table_exists?(:agents), "Сначала создай и примени миграцию для agents"
    assert connection.table_exists?(:skills), "Сначала создай и примени миграцию для skills"
    assert connection.table_exists?(:missions), "Сначала создай и примени миграцию для missions"
    assert connection.table_exists?(:agent_skills), "Сначала создай и примени миграцию для agent_skills"

    assert_includes connection.foreign_keys(:missions).map(&:to_table), "agents",
      "Для missions.agent_id нужен внешний ключ на agents"

    assert_equal [ "agents", "skills" ].sort,
      connection.foreign_keys(:agent_skills).map(&:to_table).sort,
      "Для agent_skills нужны внешние ключи на agents и skills"

    assert_has_unique_index :agents, [ :codename ]
    assert_has_unique_index :skills, [ :name ]
    assert_has_unique_index :agent_skills, [ :agent_id, :skill_id ]
  end

  test "Agent проверяет свои поля" do
    agent_class = assert_model_exists("Agent")

    blank_agent = agent_class.new(level: 1, active: true)
    assert_not blank_agent.valid?, "Agent без codename не должен быть валидным"
    assert blank_agent.errors.added?(:codename, :blank), "Ожидаются ошибки валидации :codename (blank)"

    existing_agent = agent_class.create!(codename: unique_value("agent"), level: 3, active: true)
    duplicate_agent = agent_class.new(codename: existing_agent.codename, level: 2, active: false)
    assert_not duplicate_agent.valid?, "codename должен быть уникальным"
    assert duplicate_agent.errors.details[:codename].any? { |h| h[:error] == :taken }, "Ожидается ошибка уникальности для :codename"

    low_level_agent = agent_class.new(codename: unique_value("rookie"), level: 0, active: true)
    assert_not low_level_agent.valid?, "level должен быть не меньше 1"
    assert low_level_agent.errors[:level].any?, "Добавь проверку минимального уровня для Agent"

    high_level_agent = agent_class.new(codename: unique_value("veteran"), level: 11, active: true)
    assert_not high_level_agent.valid?, "level должен быть не больше 10"
    assert low_level_agent.errors[:level].any?, "Добавь проверку максимального уровня для Agent"
  end

  test "Skill проверяет свои поля" do
    skill_class = assert_model_exists("Skill")


    blank_skill = skill_class.new(category: "stealth")
    assert_not blank_skill.valid?, "Skill без name не должен быть валидным"
    assert blank_skill.errors.added?(:name, :blank), "Ожидаются ошибки валидации :name (blank)"

    existing_skill = skill_class.create!(name: unique_value("skill"), category: "ops")
    duplicate_skill = skill_class.new(name: existing_skill.name, category: "ops")
    assert_not duplicate_skill.valid?, "name должен быть уникальным"
    assert duplicate_skill.errors.details[:name].any? { |h| h[:error] == :taken }, "Ожидается ошибка уникальности для :name"
  end

  test "Mission проверяет свои поля" do
    mission_class = assert_model_exists("Mission")
    agent_class = assert_model_exists("Agent")

    agent = agent_class.create!(codename: unique_value("handler"), level: 5, active: true)

    blank_mission = mission_class.new(agent: agent)
    assert_not blank_mission.valid?, "Mission без title и status не должна быть валидной"
    assert blank_mission.errors.added?(:title, :blank), "Ожидаются ошибки валидации :title (blank)"
    assert blank_mission.errors.added?(:status, :blank), "Ожидаются ошибки валидации :status (blank)"

    assert_raises(ArgumentError, "Assigning unknown status should raise ArgumentError") do
      mission_class.new(title: "Silent Echo", status: "queued", agent: agent)
    end
  end

  private

  def assert_model_exists(class_name)
    klass = class_name.safe_constantize
    assert klass, "Создай модель #{class_name}"
    klass
  end

  def assert_column(table_name, column_name, expected_type)
    column = ActiveRecord::Base.connection.columns(table_name).find { |item| item.name == column_name.to_s }
    assert column, "В таблице #{table_name} должна быть колонка #{column_name}"
    assert_equal expected_type, column.type,
      "Колонка #{table_name}.#{column_name} должна иметь тип #{expected_type}"
  end

  def assert_association(model_class, association_name, expected_macro)
    reflection = model_class.reflect_on_association(association_name)
    assert reflection, "У #{model_class.name} должна быть ассоциация #{association_name}"
    assert_equal expected_macro, reflection.macro,
      "Ассоциация #{model_class.name}.#{association_name} должна быть типа #{expected_macro}"
  end

  def assert_has_unique_index(table_name, columns)
    normalized_columns = columns.map(&:to_s)
    index = ActiveRecord::Base.connection.indexes(table_name).find do |item|
      item.unique && item.columns == normalized_columns
    end

    assert index, "В таблице #{table_name} нужен уникальный индекс на #{normalized_columns.join(', ')}"
  end

  def unique_value(prefix)
    "#{prefix}_#{SecureRandom.hex(4)}"
  end
end
