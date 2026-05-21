class Quest2StudentService
  class << self
    # @return [String]
    def all_agents
      Agent.pluck(:codename).join("\n")
    end

    # @return [String]
    def all_missions
      Mission.order(:title).pluck(:title).join("\n")
    end

    # @return [String]
    def agents_with_missions
      agents = Agent.includes(:missions).order(:codename, "missions.title")

      agents.map do |agent|
        mission_titles = agent.missions.map(&:title).join(", ")
        "#{agent.codename}: #{mission_titles}"
      end.join("\n")
    end

    # @return [String]
    def agents_with_missions_sorted_by_mission_count
      agents = Agent
                .left_joins(:missions)
                .group(:id)
                .select("agents.*, COUNT(missions.id) AS missions_count")
                .order("missions_count DESC, agents.codename ASC")
                .includes(:missions)

      agents.map do |agent|
        mission_titles = agent.missions.sort_by(&:title).map(&:title).join(", ")
        "#{agent.codename} (#{agent.missions.size}): #{mission_titles}"
      end.join("\n")
    end

    # @return [String]
    def agents_with_skills
      agents = Agent.includes(:skills).order(:codename, "skills.name")

      agents.map do |agent|
        skill_names = agent.skills.map(&:name).join(", ")
        "#{agent.codename}: #{skill_names}"
      end.join("\n")
    end

    # @return [String]
    def skills_by_agent_count
      skills = Skill
                .left_joins(:agents)
                .group(:id)
                .select("skills.*, COUNT(agents.id) AS agents_count")
                .order("agents_count DESC, skills.name ASC")
                .includes(:agents)

      skills.map do |skill|
        agent_names = skill.agents.sort_by(&:codename).map(&:codename).join(", ")
        "#{skill.name} (#{skill.agents.size}): #{agent_names}"
      end.join("\n")
    end
  end
end
