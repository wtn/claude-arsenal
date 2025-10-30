require 'json'
require 'fileutils'

module Claude
  module Arsenal
    module Config
      # Manages skill-rules.json configuration
      class SkillRules
        DEFAULT_CONFIG_PATH = '.claude/config/skill-rules.json'

        attr_reader :config_path, :rules

        def initialize(config_path: DEFAULT_CONFIG_PATH)
          @config_path = config_path
          @rules = load_rules
        end

        def add_skill(name, config)
          @rules[name] = normalize_config(config)
        end

        def remove_skill(name)
          @rules.delete(name)
        end

        def get_skill(name)
          @rules[name]
        end

        def save
          FileUtils.mkdir_p(File.dirname(config_path))
          File.write(config_path, JSON.pretty_generate(rules))
        end

        def reload
          @rules = load_rules
        end

        private

        def load_rules
          return {} unless File.exist?(config_path)

          JSON.parse(File.read(config_path))
        rescue JSON::ParserError => e
          raise Error, "Invalid JSON in #{config_path}: #{e.message}"
        end

        def normalize_config(config)
          {
            'type' => (config[:type] || config['type']).to_s,
            'enforcement' => (config[:enforcement] || config['enforcement'] || 'suggest').to_s,
            'priority' => (config[:priority] || config['priority'] || 'medium').to_s,
            'promptTriggers' => normalize_triggers(config[:promptTriggers] || config['promptTriggers']),
            'fileTriggers' => normalize_triggers(config[:fileTriggers] || config['fileTriggers'])
          }.compact
        end

        def normalize_triggers(triggers)
          return nil if triggers.nil?

          {
            'keywords' => triggers[:keywords] || triggers['keywords'] || [],
            'intentPatterns' => triggers[:intentPatterns] || triggers['intentPatterns'] || [],
            'pathPatterns' => triggers[:pathPatterns] || triggers['pathPatterns'] || [],
            'contentPatterns' => triggers[:contentPatterns] || triggers['contentPatterns'] || []
          }.reject { |_k, v| v.empty? }
        end
      end
    end
  end
end
